#include "trap.h"
#include "riscv.h"
#include "task.h"
#include "timer.h"
#include "types.h"
#include "uart.h"
#include "utils.h"
#include "syscall.h"

#include "plic.h"
#include "thread.h"
#include "vm.h"
#include "buddy.h"

_Static_assert(sizeof(struct trap_frame) == TF_SIZE,
               "struct trap_frame size must match TF_SIZE in trap.h");

/*
 * Absolute load address of the running user program. Updated by
 * run_user_program() right before enter_user_mode(); consumed by
 * trap_handler() so diagnostic output shows offsets relative to the
 * program image rather than raw kmalloc() pointers.
 */
static uintptr_t g_user_base = 0;

void trap_set_user_base(uintptr_t base) { g_user_base = base; }

/** ----------------------------------------------------------------------
 * @brief trap_init() – Install the S-mode trap vector.
 *
 * Writes trap_entry into stvec in direct mode (mode bits = 00) and
 * clears sscratch. A zero sscratch is the sentinel used by trap_entry
 * to detect "trap from kernel"; enter_user_mode() later writes the
 * kernel sp into sscratch so that a U→S trap finds a valid stack.
 * -------------------------------------------------------------------- */
void trap_init(void) {
    extern char trap_entry[];

    uintptr_t vec = (uintptr_t)trap_entry;

    // 把 trap_entry 寫進 stvect，stvec 是發生中斷時 CPU 會去執行的位置
    asm volatile("csrw stvec, %0" ::"r"(vec));

    // 把 sscratch 清 0 ，用來判斷是否發生 Nested Trap
    // trap_entry.S 的第一行 csrrw sp, sscratch, sp
    // 如果一進入 trap，sscratch 是 0，代表發生 Trap 時已經在 S-mode（發生了
    // Nested Trap） 如果不是 0，代表是從 User mode 進來的，可以安全使用 sscratch
    // 中存的 Kernel Stack
    asm volatile("csrw sscratch, %0" ::"r"(0UL));
}

/** ----------------------------------------------------------------------
 * @brief trap_handler() – Top-level S-mode trap dispatcher.
 *
 * Prints the diagnostic CSR trio (scause / sepc / stval). For an
 * ecall taken from U-mode (scause = 8), advances sepc by 4 so that
 * the eventual sret resumes at the instruction after ecall.
 * @param tf Pointer to the trap frame saved by trap_entry.
 * -------------------------------------------------------------------- */
void trap_handler(struct trap_frame *tf) {
  uintptr_t cause = tf->scause;

  /* The first bit in scause means asynchronize interrupt (1) or synchronize exception (0) */

    // 只在發生真正異常（非中斷且非系統呼叫）時才在最開頭進行輸出，以避免 Timer 中斷頻率過高導致 UART 印不完而當機
    if (!(cause & SCAUSE_INTR_BIT) && cause != EXC_ECALL_U) {
        // uart_disable_async();
        uart_puts("=== S-Mode trap ===\n");
        uart_puts("scause: ");
        uart_hex(cause);
        uart_puts("\n");
        uart_puts("stval: ");
        uart_hex(tf->stval);
        uart_puts("\n");
    }

    // Case: Asynchronous Interrupts  (first bit is 1)
    if (cause & SCAUSE_INTR_BIT) {

        // clear the MSB to get the real IRQ number
        uintptr_t irq = cause & ~SCAUSE_INTR_BIT;  

        if (irq == INTR_S_TIMER) {
            core_timer_handler();

        } else if (irq == INTR_S_EXT) {

            /* S-mode External Interrupt (PLIC) */
            int plic_irq = plic_claim();

            if (plic_irq == UART0_IRQ) {
                uart_interrupt_handler();
            } else if (plic_irq) {
                uart_puts("Unhandled PLIC IRQ: ");
                uart_dec(plic_irq);
                uart_puts("\n");
            }

            if (plic_irq) {
                plic_complete(plic_irq);
            }
        }

        /* Process decouple/deferred tasks before exiting trap handler */
        run_tasks();
        signal_check(tf); // dispatch any pending signal before returning to U-mode

        return;
    }

    if (cause == EXC_ECALL_U) {
        /* Skip the ecall instruction (always 4 bytes in RV64I). 
         * 必須在 syscall_handler 之前跳過 ecall，否則 fork 複製 trap frame 時
         * child 的 sepc 會指回 ecall，導致無限 fork。
         */
        tf->sepc += 4;
        // Update current task's trap frame pointer so syscall handlers can use it
        get_current()->tf = tf;
        syscall_handler(tf);
        signal_check(tf); // dispatch any pending signal before returning to U-mode
        return;
    }

    /*
    * Display sepc as an offset from the user program base so that
    * students can correlate it with the prog.bin disassembly without
    * worrying about where kmalloc() happened to place the image.
    */
    uintptr_t rel_sepc = tf->sepc - g_user_base;

    // uart_puts("=== S-Mode trap ===\n");
    // uart_puts("scause: ");
    // uart_hex(cause);
    // uart_puts("\n");
    // uart_puts("sepc: ");
    // uart_hex(tf->sepc);
    // uart_puts(" (relative: ");
    // uart_hex((unsigned long)rel_sepc);
    // uart_puts(")\n");
    // uart_puts("stval: ");
    // uart_hex(tf->stval);
    // uart_puts("\n");

    // 根據 Advanced Exercise 2 規格：當 User Mode 發生 Page Fault 時，實作 Demand Paging
    if (cause == 12 || cause == 13 || cause == 15) {
        struct task_struct *curr = get_current();
        struct vm_area_struct *vma = curr->vma_list;
        struct vm_area_struct *target_vma = 0;

        // 1. Check if the faulting address belongs to any VMA (regardless of user/kernel mode)
        while (vma) {
            if (tf->stval >= vma->vm_start && tf->stval < vma->vm_end) {
                target_vma = vma;
                break;
            }
            vma = vma->vm_next;
        }

        // 2. If matched, dynamically allocate and map it
        if (target_vma) {
            unsigned long fault_page_va = tf->stval & ~(PAGE_SIZE - 1);
            unsigned long *pte_ptr = walk_pte(curr->pgd, fault_page_va);

            // A. Copy-On-Write Check
            if (pte_ptr && (*pte_ptr & PAGE_PRESENT)) {
                if (cause == 15 && (*pte_ptr & PAGE_USER) && !(*pte_ptr & PAGE_WRITE)) {
                    if (target_vma->vm_prot & 2) { // PROT_WRITE allowed
                        // Copy-On-Write event confirmed!
                        uart_puts("[Permission fault]: ");
                        uart_hex(tf->stval);
                        uart_puts("\n");

                        unsigned long old_pa = (*pte_ptr >> 10) << 12;
                        void *old_page_va = (void *)__va(old_pa);

                        if (get_page_ref_count(old_page_va) > 1) {
                            // Shared frame, need reallocation & clone
                            void *new_page = alloc_page();
                            if (!new_page) {
                                uart_puts("COW: Out of memory!\n");
                                thread_exit();
                            }
                            memcpy(new_page, old_page_va, PAGE_SIZE);

                            // Update PTE to point to new page with PAGE_WRITE
                            unsigned long flags = (*pte_ptr & 0x3FF) | PAGE_WRITE;
                            *pte_ptr = ((__pa(new_page) >> 12) << 10) | flags;

                            // Decrement reference count on the original frame
                            buddy_free(old_page_va);
                        } else {
                            // Exclusive owner, simply restore the write flag in-place
                            *pte_ptr |= PAGE_WRITE;
                        }

                        // Invalidate the TLB for the modified address
                        asm volatile("sfence.vma %0, zero" : : "r"(fault_page_va) : "memory");
                        return; // Re-run instruction successfully
                    }
                }
            }

            // B. Standard Demand Paging Check
            int perm_ok = 1;
            if (cause == 15 && !(target_vma->vm_prot & 2)) perm_ok = 0; // PROT_WRITE
            if (cause == 13 && !(target_vma->vm_prot & 1)) perm_ok = 0; // PROT_READ
            if (cause == 12 && !(target_vma->vm_prot & 4)) perm_ok = 0; // PROT_EXEC

            if (perm_ok) {
                void *page = alloc_page();
                if (page) {
                    memset(page, 0, PAGE_SIZE);
                    
                    uart_puts("[Translation fault]: ");
                    uart_hex(tf->stval);
                    uart_puts("\n");

                    unsigned long page_prot = PAGE_USER;
                    if (target_vma->vm_prot & 1) page_prot |= PAGE_READ;
                    if (target_vma->vm_prot & 2) page_prot |= PAGE_WRITE;
                    if (target_vma->vm_prot & 4) page_prot |= PAGE_EXEC;
                    if (page_prot & PAGE_WRITE) page_prot |= PAGE_READ;

                    // 向下對齊頁面邊界
                    unsigned long fault_page_va = tf->stval & ~(PAGE_SIZE - 1);
                    map_pages(curr->pgd, fault_page_va, PAGE_SIZE, __pa(page), page_prot);
                    asm volatile("sfence.vma zero, zero" : : : "memory");
                    return; // 順利排除分頁錯誤，重試執行
                }
            }
        }

        // 3. If no VMA found OR permission check failed:
        int from_user = !(tf->sstatus & (1UL << 8));
        if (from_user) {
            uart_puts("[Segmentation fault]: Kill Process\n");
            thread_exit(); 
        }
        // 若來自核心態且查無 VMA，直接向下流到 Kernel Panic，確保安全
    }

    uart_puts("[trap] unhandled exception, halting.\n");
    for (;;) {
        asm volatile("wfi");
    }
}


