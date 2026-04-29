#ifndef __SYSCALL_H__
#define __SYSCALL_H__

#include "trap.h"

#define SYS_getpid 0
#define SYS_uart_read 1
#define SYS_uart_write 2
#define SYS_exec 3
#define SYS_fork 4
#define SYS_waitpid 5
#define SYS_exit 6
#define SYS_stop 7

void syscall_handler(struct trap_frame *tf);

#endif /* __SYSCALL_H__ */
