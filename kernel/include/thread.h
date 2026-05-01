#ifndef __THREAD_H__
#define __THREAD_H__

#include "trap.h"
#include "timer.h"

#define STACK_SIZE 4096

enum thread_state {
    THREAD_RUNNING,
    THREAD_ZOMBIE,
    THREAD_SLEEPING,
};

struct task_struct {
    struct thread_struct {
        unsigned long ra;
        unsigned long sp;
        unsigned long s[12];
    } thread;
    int pid;
    int ppid;
    enum thread_state state;
    unsigned long kernel_sp;
    unsigned long user_sp;
    unsigned long stack;          // Kernel stack base
    struct task_struct* next;
    
    // User process specific
    unsigned long user_space_base;
    unsigned long user_space_size;
    struct trap_frame *tf;
};

void idle();
void test_threads();
struct task_struct* get_current();
struct task_struct* thread_create(void (*threadfn)());
void thread_exit();
void schedule();

int user_program_execute(const char *path);
int do_exec(const char *path);
long do_fork(struct trap_frame *tf);
long do_waitpid(long pid);
int do_stop(long pid);
int do_usleep(unsigned int usec);

#endif /* __THREAD_H__ */
