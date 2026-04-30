
#include "kmalloc.h"
#include "buddy.h"
#include "uart.h"
#include "thread.h"
#include "cpio.h"
#include "dtb.h"
#include "trap.h"

extern void switch_to(struct task_struct* prev, struct task_struct* next);

static int nr_threads = 0;
static struct task_struct* run_queue = 0;

static void enqueue(struct task_struct** queue, struct task_struct* task) {
    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus)); 
    
    if (*queue == 0) {
        *queue = task;
        task->next = task;
    } else {
        struct task_struct* tail = (*queue)->next;
        (*queue)->next = task;
        task->next = tail;
    }

    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
}

static void dequeue(struct task_struct** queue, struct task_struct* task) {
    
    
    if (*queue == 0) return;

    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus)); // 上鎖
    
    struct task_struct* curr = *queue;
    struct task_struct* prev = 0;
    
    do {
        if (curr->next == task) {
            prev = curr;
            break;
        }
        curr = curr->next;
    } while (curr != *queue);
    
    if (prev != 0) {
        if (task->next == task) {
            *queue = 0;
        } else {
            prev->next = task->next;
            if (*queue == task) {
                *queue = task->next;
            }
        }
    }

    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
}

struct task_struct* get_current() {
    register struct task_struct* current asm("tp");
    return current;
}

void schedule() {
    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

    struct task_struct* prev = get_current();
    // uart_puts("schedule: prev->pid = ");
    // uart_dec(prev->pid);
    // uart_puts("  ");    
    struct task_struct* next = prev->next;

    while (next->state == THREAD_ZOMBIE && next != prev) {
        next = next->next;
    }

    if (prev != next) {
        // uart_puts("schedule: next->pid = ");
        // uart_dec(next->pid);
        // uart_puts("\n");   
        switch_to(prev, next);
    }
    // asm volatile("csrs sstatus, 2");   // 重要！！解決第一
    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
}

void thread_exit() {

    uart_puts("Thread exit: pid ");
    uart_dec(get_current()->pid);
    uart_puts("\n");    

    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

    struct task_struct* current = get_current();
    current->state = THREAD_ZOMBIE;

    // Reparenting：把所有以我為 ppid 的小孩，ppid 都改成 0
    if (run_queue) {
        struct task_struct *curr = run_queue;
        do {
            if (curr->ppid == current->pid) {
                curr->ppid = 0; // 變成孤兒，以後交給 idle 處理
            }
            curr = curr->next;
        } while (curr != run_queue);
    }

    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
    schedule();
    while (1);  // Just in case accidentally return
}

void kill_zombies() {
    if (!run_queue) return;

    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));
    
    struct task_struct* curr = run_queue;
    do {
        struct task_struct* next = curr->next;
        if (next->state == THREAD_ZOMBIE && next->ppid == 0) {
            uart_puts("kill_zombies: pid ");
           
            uart_dec(next->pid);
            uart_puts("\n");
            dequeue(&run_queue, next);
            kfree((void*)next->stack);
            kfree(next);
            curr = run_queue;
            if (!curr) break;
            continue;
        }
        curr = curr->next;
    } while (curr != run_queue);

    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
}

void idle() {
    while (1) {
        kill_zombies();
        schedule();
    }
}

struct task_struct* thread_create(void (*threadfn)()) {
    struct task_struct* task = kmalloc(sizeof(struct task_struct));
    task->pid = nr_threads++;
    task->ppid = 0;
    task->state = THREAD_RUNNING;
    task->stack = (unsigned long)kmalloc(STACK_SIZE);
    task->thread.ra = (unsigned long)threadfn;
    task->thread.sp = task->stack + STACK_SIZE;
    enqueue(&run_queue, task);
    return task;
}

void foo() {
    for (int i = 0; i < 5; i++) {
        uart_puts("Thread id: ");
        uart_dec(get_current()->pid);
        uart_puts(" ");
        uart_dec(i);
        uart_puts("\n");
        for (int j = 0; j < 10000000; j++);
        schedule();
    }
    thread_exit();
}

void test_threads() {
    uart_puts("Testing threads...\n");
    // struct task_struct *idle_thread = thread_create(idle);
    // asm volatile("mv tp, %0" : : "r"(idle_thread));
    
    for (int i = 0; i < 3; i++) {
        thread_create(foo);
    }
    idle();
    // schedule();
}

static void byte_copy(void *dst, const void *src, unsigned long n) {
    unsigned char *d = (unsigned char *)dst;
    const unsigned char *s = (const unsigned char *)src;
    while (n--) {
        *d++ = *s++;
    }
}

int do_exec(const char *path) {
    struct task_struct *curr = get_current();
    
    const void *initrd = (const void *)dtb_getprop("/chosen", "linux,initrd-start", NULL);
    if (!initrd) return -1;
    
    const void *src = NULL;
    unsigned long src_size = 0;
    if (cpio_find(initrd, path, &src, &src_size) != 0) return -1;
    
    // Allocate new user space (no MMU, just kmalloc)
    unsigned long total = src_size + 16 * 1024; // 16 KiB user stack
    void *buf = kmalloc(total);
    if (!buf) return -1;
    
    byte_copy(buf, src, src_size);
    
    // Free old user space if it exists
    if (curr->user_stack_base) {
        kfree((void *)curr->user_stack_base);
    }
    
    curr->user_stack_base = (unsigned long)buf;
    curr->user_stack_size = total;
    
    uintptr_t entry = (uintptr_t)buf;
    uintptr_t user_sp = ((uintptr_t)buf + total) & ~0xfUL;
    
    // Update trap frame
    curr->tf->sepc = entry;
    curr->tf->sp = user_sp;
    
    // Set user mode base for debugging offsets in trap handler
    extern void trap_set_user_base(uintptr_t base);
    trap_set_user_base(entry);
    
    return 0;
}

/* Trampoline: called when a newly-created user process thread is scheduled
 * for the first time. Reads entry/sp from task_struct and drops to U-mode. */
static void user_program_start() {
    struct task_struct *curr = get_current();
    uintptr_t entry   = curr->user_stack_base;
    uintptr_t user_sp = (curr->user_stack_base + curr->user_stack_size) & ~0xfUL;
    
    enter_user_mode(entry, user_sp); // Does not return; executes sret into U-mode
}

int user_program_execute(const char *path) {
    const void *initrd = (const void *)dtb_getprop("/chosen", "linux,initrd-start", NULL);
    if (!initrd) {
        uart_puts("user_program_execute: initrd not found\n");
        return -1;
    }
    
    const void *src = NULL;
    unsigned long src_size = 0;
    if (cpio_find(initrd, path, &src, &src_size) != 0) {
        uart_puts("user_program_execute: ");
        uart_puts((char *)path);
        uart_puts(": not found\n");
        return -1;
    }
    
    unsigned long total = src_size + 16 * 1024; // 16 KiB user stack
    void *buf = kmalloc(total);
    if (!buf) {
        uart_puts("user_program_execute: out of memory\n");
        return -1;
    }
    byte_copy(buf, src, src_size);
    
    // thread_create sets ra = user_program_start, so when the scheduler
    // first picks this task, it calls user_program_start() which drops
    // into U-mode via enter_user_mode().
    struct task_struct *task = thread_create(user_program_start);
    task->ppid = get_current()->pid; // Set parent PID so do_waitpid can reap it
    task->user_stack_base = (unsigned long)buf;
    task->user_stack_size = total;
    
    return task->pid;
}

long do_fork(struct trap_frame *tf) {
    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

    struct task_struct *parent = get_current();
    struct task_struct *child = thread_create(0); // 0 because we will overwrite context
    
    // Copy user stack
    if (parent->user_stack_base) {
        child->user_stack_base = (unsigned long)kmalloc(parent->user_stack_size);
        child->user_stack_size = parent->user_stack_size;
        byte_copy((void *)child->user_stack_base, (void *)parent->user_stack_base, parent->user_stack_size);
    }

    // record parent pid
    child->ppid = parent->pid;
    
    // Copy the trap frame to the child's kernel stack
    struct trap_frame *child_tf = (struct trap_frame *)(child->stack + STACK_SIZE - sizeof(struct trap_frame));
    byte_copy(child_tf, tf, sizeof(struct trap_frame));
    child->tf = child_tf;
    
    // Child's fork() return value is 0
    child_tf->a0 = 0;

    // CRITICAL: tp (x4) is used by get_current() in kernel mode.
    // After _ret_from_fork, tp is restored from the trap frame.
    // But trap_entry.S restores tp only to go to U-mode (user's tp).
    // The actual kernel tp is set by switch_to via "mv tp, a1".
    // So child's kernel tp is correctly set by switch_to when it picks the child.
    // However, we must store the child's task_struct pointer into tp
    // so that if the child ever calls get_current() while still in kernel context
    // (e.g., during waitpid scheduling), it returns the correct task.
    child_tf->tp = (unsigned long)child;

    // Adjust child's user stack pointer: same offset within child's allocation
    if (parent->user_stack_base) {
        unsigned long sp_offset = child_tf->sp - parent->user_stack_base;
        child_tf->sp = child->user_stack_base + sp_offset;
    }
    
    // Set child's kernel thread context:
    // When scheduler picks the child, switch_to returns into _ret_from_fork,
    // which restores the trap frame and srets back to U-mode.
    extern void _ret_from_fork();
    child->thread.ra = (unsigned long)_ret_from_fork;
    child->thread.sp = (unsigned long)child_tf;

    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
    
    return child->pid;
}

long do_waitpid(long pid) {
    while (1) {
        int found = 0;
        struct task_struct *curr = run_queue;
        struct task_struct* par = get_current();

        unsigned long saved_sstatus;
        asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

        if (curr) {
            do {
                if (curr->pid == pid) {
                    found = 1;
                    if (curr->state == THREAD_ZOMBIE) {
                        // uart_puts("waitpid: ");
                        // uart_dec(par->pid);
                        // uart_puts(" found zombie ");
                        // uart_dec(curr->pid);
                        // uart_puts("\n");

                        dequeue(&run_queue, curr);
                        if (curr->user_stack_base) {
                            kfree((void *)curr->user_stack_base);
                        }
                        kfree((void *)curr->stack);
                        kfree(curr);
                        
                        asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
                        return pid;
                    }
                    break;
                }
                curr = curr->next;
            } while (curr != run_queue);
        }

        asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));

        // child process not found
        if (!found) return -1; 
        
        // Found the child process but not zombie, schedule other process
        schedule();
    }
}

int do_kill(long pid) {
    if (!run_queue) return -1;
    
    struct task_struct *curr = run_queue;
    do {
        if (curr->pid == pid) {
            curr->state = THREAD_ZOMBIE;
            return 0;
        }
        curr = curr->next;
    } while (curr != run_queue);
    
    return -1;
}