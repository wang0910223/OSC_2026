#include "../include/syscall.h"
#include "../include/uart.h"
#include "../include/thread.h"
#include "../include/video.h"
#include "../include/vm.h"
#include "../include/kmalloc.h"

long do_mmap(void *addr, unsigned long length, int prot, int flags) {
    if (length == 0) return -1;
    length = (length + PAGE_SIZE - 1) & ~(PAGE_SIZE - 1);

    struct task_struct *curr = get_current();
    unsigned long vm_start = (unsigned long)addr;
    
    // case 1: User 沒給位址、位址沒對齊、或給的位址太低
    // method: 從 0x1000000000 開始，不斷往上推到所有現有 VMA 的最高點。
    if (!vm_start || (vm_start & (PAGE_SIZE - 1)) || vm_start < 0x1000000000) {
        vm_start = 0x1000000000;
    }
    
    // Check if vm_start + length overlaps with any existing VMA
    // If so, move vm_start past the overlapping VMA and check again
    int overlap;
    do {
        overlap = 0;
        struct vm_area_struct *vma = curr->vma_list;
        while (vma) {
            if (vm_start < vma->vm_end && (vm_start + length) > vma->vm_start) {
                vm_start = (vma->vm_end + PAGE_SIZE - 1) & ~(PAGE_SIZE - 1);
                overlap = 1;
                break; // Restart check with new vm_start
            }
            vma = vma->vm_next;
        }
    } while (overlap);

    if (flags & MAP_ANONYMOUS) {
        unsigned long page_prot = PAGE_USER;
        if (prot & PROT_READ) page_prot |= PAGE_READ;
        if (prot & PROT_WRITE) page_prot |= PAGE_WRITE;
        if (prot & PROT_EXEC) page_prot |= PAGE_EXEC;

        // RISC-V 不支援單獨寫入權限 (R=0, W=1 是保留組合會引發 Page Fault)。
        // 為了與架構相容，有 Write 就必須強制開啟 Read 權限。
        if (page_prot & PAGE_WRITE) {
            page_prot |= PAGE_READ;
        }

        if (flags & MAP_POPULATE) {
            for (unsigned long i = 0; i < length; i += PAGE_SIZE) {
                void *page = alloc_page();
                if (!page) return -1;
                map_pages(curr->pgd, vm_start + i, PAGE_SIZE, __pa(page), page_prot);
            }
        }
    }

    struct vm_area_struct *new_vma = kmalloc(sizeof(struct vm_area_struct));
    if (!new_vma) return -1;
    new_vma->vm_start = vm_start;
    new_vma->vm_end = vm_start + length;
    new_vma->vm_prot = prot;
    new_vma->vm_flags = flags;
    new_vma->vm_file_data = 0;
    new_vma->vm_file_size = 0;
    new_vma->vm_next = curr->vma_list;
    curr->vma_list = new_vma;


    // 修改分頁表後必須執行 sfence.vma 以清空舊的 TLB Cache，確保硬體立刻認得新對應的實體空間
    asm volatile("sfence.vma zero, zero" : : : "memory");

    return vm_start;
}

void syscall_handler(struct trap_frame *tf) {
    // asm volatile("csrs sstatus, 2");
    long syscall_num = tf->a7;
    long ret = -1;


    switch (syscall_num) {
        case SYS_getpid:
            ret = get_current()->pid;
            break;
        case SYS_uart_read: {
            char *buf = (char *)tf->a0;
            long count = tf->a1;
            long bytes_read = 0;
            
            unsigned long saved_sstatus;

            // enable interrupt
            asm volatile("csrr %0, sstatus" : "=r"(saved_sstatus));
            asm volatile("csrs sstatus, 2");
            for (long i = 0; i < count; i++) {
                char c = uart_getc();
                buf[i] = c;
                bytes_read++;
            }
            asm volatile("csrw sstatus, %0" :: "r"(saved_sstatus));

            ret = bytes_read;
            break;
        }
        case SYS_uart_write: {
            const char *buf = (const char *)tf->a0;
            long count = tf->a1;
            long bytes_written = 0;

            unsigned long saved_sstatus;
            asm volatile("csrr %0, sstatus" : "=r"(saved_sstatus));
            asm volatile("csrs sstatus, 2");
            for (long i = 0; i < count; i++) {
                uart_putc(buf[i]);
                bytes_written++;
            }
            asm volatile("csrw sstatus, %0" :: "r"(saved_sstatus));

            ret = bytes_written;
            break;
        }
        case SYS_exec: {
            const char *path = (const char *)tf->a0;
            ret = do_exec(path);
            break;
        }
        case SYS_fork:
            ret = do_fork(tf);
            break;
        case SYS_waitpid: {
            long pid = tf->a0;
            ret = do_waitpid(pid);
            break;
        }
        case SYS_exit: {
            thread_exit(); // Doesn't return
            break;
        }
        case SYS_stop: {
            
            long pid = tf->a0;
            ret = do_stop(pid);
            break;
        }
        case SYS_display: {
            unsigned int *bmp_image = (unsigned int *)tf->a0;
            unsigned int width = (unsigned int)tf->a1;
            unsigned int height = (unsigned int)tf->a2;
            video_bmp_display(bmp_image, width, height);
            ret = 0;
            break;
        }
        case SYS_usleep: {
            unsigned int usec = (unsigned int)tf->a0;
            ret = do_usleep(usec);
            break;
        }
        case SYS_signal: {
            int sig = (int)tf->a0;
            void (*handler)() = (void (*)())tf->a1;
            do_signal(sig, handler);
            ret = 0;
            break;
        }
        case SYS_sigreturn: {
            do_sigreturn(tf);
            // do_sigreturn restores tf in-place; ret is already set inside it
            return; // skip the tf->a0 = ret at the bottom
        }
        case SYS_kill: {
            int pid = (int)tf->a0;
            int sig = (int)tf->a1;
            ret = do_kill(pid, sig);
            break;
        }
        case SYS_mmap: {
            void *addr = (void *)tf->a0;
            unsigned long length = tf->a1;
            int prot = (int)tf->a2;
            int flags = (int)tf->a3;
            ret = do_mmap(addr, length, prot, flags);
            break;
        }
        default:
            uart_puts("Unknown syscall: ");
            uart_dec(syscall_num);
            uart_puts("\n");
            break;
    }

    tf->a0 = ret;
}
