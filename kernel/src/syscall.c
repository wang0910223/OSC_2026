#include "../include/syscall.h"
#include "../include/uart.h"
#include "../include/thread.h"

void syscall_handler(struct trap_frame *tf) {
    long syscall_num = tf->a7;
    long ret = -1;

    switch (syscall_num) {
        case SYS_getpid:
            ret = get_current()->pid;
            break;
        case SYS_uart_read: {
            // uart_puts("SYS_uart_read called\n");
            char *buf = (char *)tf->a0;
            long count = tf->a1;
            long bytes_read = 0;
            /* RISC-V 進 Trap 時硬體自動清 sstatus.SIE，
             * 必須在這裡重新打開，UART 中斷才能填 rx buffer */
            asm volatile("csrs sstatus, 2"); // SIE = 1
            for (long i = 0; i < count; i++) {
                char c = uart_getc();
                buf[i] = c;
                bytes_read++;
            }
            asm volatile("csrc sstatus, 2"); // SIE = 0
            ret = bytes_read;
            break;
        }
        case SYS_uart_write: {
            const char *buf = (const char *)tf->a0;
            long count = tf->a1;
            long bytes_written = 0;
            for (long i = 0; i < count; i++) {
                uart_putc(buf[i]);
                bytes_written++;
            }
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
            uart_puts("waitpid end\n");
            break;
        }
        case SYS_exit: {
            uart_puts("exit syscall: pid ");
            uart_dec(get_current()->pid);
            uart_puts("\n");
            // int status = tf->a0; (not required to handle)
            thread_exit(); // Doesn't return
            break;
        }
        case SYS_stop: {
            long pid = tf->a0;
            ret = do_kill(pid);
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
