#ifndef __THREAD_H__
#define __THREAD_H__

#include "trap.h"
#include "timer.h"

#define SIGNAL_MAX 32

#define STACK_SIZE 4096

enum thread_state {
    THREAD_RUNNING,
    THREAD_ZOMBIE,
    THREAD_SLEEPING,
};

struct vm_area_struct {
    unsigned long vm_start;         // Start address of the mapped region
    unsigned long vm_end;           // End address (vm_start + length)
    int vm_prot;                    // Protection flags
    int vm_flags;                   // Map flags
    struct vm_area_struct *vm_next; // Pointer to the next VMA
    
    // BACKING STORAGE FOR DEMAND PAGING FILE SEGMENTS
    const void *vm_file_data;       // Pointer to file data in kernel memory
    unsigned long vm_file_size;     // Size of file data
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
    unsigned long *pgd;
    struct trap_frame *tf;
    struct vm_area_struct *vma_list;

    // POSIX Signal
    void (*signal_handlers[SIGNAL_MAX])();
    unsigned int pending_signals;       // bitmask of pending signals
    int is_handling_signal;
    void *signal_stack;                 // temporary stack for handler
    struct trap_frame signal_saved_tf;  // deep copy of original user context
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

// Signal
void do_signal(int sig, void (*handler)());
int do_kill(int pid, int sig);
void do_sigreturn(struct trap_frame *tf);
void signal_check(struct trap_frame *tf);

#endif /* __THREAD_H__ */
