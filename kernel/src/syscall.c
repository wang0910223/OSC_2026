#include "../include/syscall.h"
#include "../include/uart.h"
#include "../include/thread.h"
#include "../include/video.h"

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
        default:
            uart_puts("Unknown syscall: ");
            uart_dec(syscall_num);
            uart_puts("\n");
            break;
    }

    tf->a0 = ret;
}
