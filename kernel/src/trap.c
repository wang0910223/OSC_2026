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
        return;
    }

    /*
    * Display sepc as an offset from the user program base so that
    * students can correlate it with the prog.bin disassembly without
    * worrying about where kmalloc() happened to place the image.
    */
    uintptr_t rel_sepc = tf->sepc - g_user_base;

    uart_puts("=== S-Mode trap ===\n");
    uart_puts("scause: ");
    uart_dec(cause);
    uart_puts("\n");
    uart_puts("sepc: ");
    uart_hex((unsigned long)rel_sepc);
    uart_puts("\n");
    uart_puts("stval: ");
    uart_dec(tf->stval);
    uart_puts("\n");

    uart_puts("[trap] unhandled exception, halting.\n");
    for (;;) {
        asm volatile("wfi");
    }
}


