
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
    struct task_struct* next = prev->next;

    while (next->state != THREAD_RUNNING && next != prev) {
        next = next->next;
    }

    if (prev != next) {
        switch_to(prev, next);
    }
    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
}

void thread_exit() {

    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

    struct task_struct* current = get_current();
    current->state = THREAD_ZOMBIE;

    // Reparenting：把所有以此 thread 為 parent 的 thread 的 ppid 都改成 0
    if (run_queue) {
        struct task_struct *curr = run_queue;
        do {
            if (curr->ppid == current->pid) {
                curr->ppid = 0; // turn this thread into orphan thread and handover to idle thread
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
    struct task_struct* zombie_to_free = NULL; 
    
    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));
    
    struct task_struct* curr = run_queue;
    do {
        struct task_struct* next = curr->next;
        if (next->state == THREAD_ZOMBIE && next->ppid == 0) {
            
            dequeue(&run_queue, next);
            zombie_to_free = next;   
            
            break; // when found one, we stop traverse for shorten interrupt disable time
        }
        curr = curr->next;
    } while (curr != run_queue);

    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));

    if (zombie_to_free) {
        if (zombie_to_free->user_space_base) {
            kfree((void*)zombie_to_free->user_space_base);
        }
        kfree((void*)zombie_to_free->stack);
        kfree(zombie_to_free);
    }
}
void idle() {
    while (1) {
        kill_zombies();
        schedule();
    }
}

struct task_struct* thread_create(void (*threadfn)()) {
    struct task_struct* task = kmalloc(sizeof(struct task_struct));
    task->user_space_base = 0;
    task->user_space_size = 0;
    task->tf = 0;

    task->pid = nr_threads++;
    task->ppid = 0;
    task->state = THREAD_RUNNING;
    task->stack = (unsigned long)kmalloc(STACK_SIZE);  // kernel stack
    task->thread.ra = (unsigned long)threadfn;
    task->thread.sp = task->stack + STACK_SIZE;   // kernel sp

    // Initialize signal fields
    for (int i = 0; i < SIGNAL_MAX; i++)
        task->signal_handlers[i] = 0;
    task->pending_signals = 0;
    task->is_handling_signal = 0;
    task->signal_stack = 0;

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
    // idle();
    schedule();
}

static void byte_copy(void *dst, const void *src, unsigned long n) {
    unsigned char *d = (unsigned char *)dst;
    const unsigned char *s = (const unsigned char *)src;
    while (n--) {
        *d++ = *s++;
    }
}

int do_exec(const char *path) {
    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

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
    if (curr->user_space_base) {
        kfree((void *)curr->user_space_base);
    }
    
    curr->user_space_base = (unsigned long)buf;
    curr->user_space_size = total;
    
    uintptr_t entry = (uintptr_t)buf;
    uintptr_t user_sp = ((uintptr_t)buf + total) & ~0xfUL;
    
    // Update trap frame
    curr->tf->sepc = entry;
    curr->tf->sp = user_sp;
    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));

    return 0;
}


static void user_program_start() {
    struct task_struct *curr = get_current();
    uintptr_t entry   = curr->user_space_base;
    uintptr_t user_sp = (curr->user_space_base + curr->user_space_size) & ~0xfUL;
    
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
    task->user_space_base = (unsigned long)buf;
    task->user_space_size = total;
    
    return task->pid;
}

long do_fork(struct trap_frame *tf) {
    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

    struct task_struct *parent = get_current();
    struct task_struct *child = thread_create(0); // 0 because we will overwrite context
    
    // Copy user stack
    if (parent->user_space_base) {
        child->user_space_base = (unsigned long)kmalloc(parent->user_space_size);
        child->user_space_size = parent->user_space_size;
        byte_copy((void *)child->user_space_base, (void *)parent->user_space_base, parent->user_space_size);
    }

    // record parent pid
    child->ppid = parent->pid;
    
    // Copy the trap frame to the child's kernel stack
    struct trap_frame *child_tf = (struct trap_frame *)(child->stack + STACK_SIZE - sizeof(struct trap_frame));
    byte_copy(child_tf, tf, sizeof(struct trap_frame));
    child->tf = child_tf;
    
    // Child's fork() return value is 0
    child_tf->a0 = 0;
    
    child_tf->tp = (unsigned long)child;

    // Adjust child's user stack pointer: same offset within child's allocation
    if (parent->user_space_base) {
        /* run on parent's memory */
        // unsigned long sp_offset = child_tf->sp - parent->user_space_base;
        // child_tf->sp = child->user_space_base + sp_offset;

        /* run on child's memory */
        unsigned long offset = child->user_space_base - parent->user_space_base;
        child_tf->sp += offset;
        child_tf->sepc += offset;
        child_tf->s0 += offset;  
        child_tf->gp += offset;  
        child_tf->ra += offset;
    }
    
    // Set child's kernel thread context:
    // When scheduler picks the child, switch_to returns into _ret_from_fork,
    // which restores the trap frame and srets back to U-mode.
    extern void _ret_from_fork();
    child->thread.ra = (unsigned long)_ret_from_fork;
    child->thread.sp = (unsigned long)child_tf;

    // Inherit parent's signal handlers
    for (int i = 0; i < SIGNAL_MAX; i++)
        child->signal_handlers[i] = parent->signal_handlers[i];
    child->pending_signals = 0;  // don't inherit pending signals
    child->is_handling_signal = 0;
    child->signal_stack = 0;

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

                        dequeue(&run_queue, curr);
                        if (curr->user_space_base) {
                            kfree((void *)curr->user_space_base);
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

int do_stop(long pid) {
    if (!run_queue) return -1;

    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));
    
    struct task_struct *curr = run_queue;
    do {
        if (curr->pid == pid) {
            curr->state = THREAD_ZOMBIE;

            asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2)); 
            
            if (curr == get_current()) {
                schedule(); 
            }
            return 0;
        }
        curr = curr->next;
    } while (curr != run_queue);

    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
    
    return -1;
}
static void wakeup_callback(void *arg) {
    struct task_struct *task = (struct task_struct *)arg;

    if (task->state == THREAD_SLEEPING) {
        task->state = THREAD_RUNNING;
    }
}


int do_usleep(unsigned int usec) {
    if (usec == 0) {
        return -1;
    }
    
    struct task_struct *curr = get_current();
    curr->state = THREAD_SLEEPING;
    
    // Calculate ticks. freq is ticks per second.
    // ticks = usec * freq / 1000000
    unsigned long ticks = ((unsigned long)usec * get_timer_freq()) / 1000000;
    if (ticks == 0) ticks = 1; // Sleep at least one tick if usec is very small
    
    add_timer_ticks(wakeup_callback, curr, ticks);
    schedule();
    return 0;
}
// -----------------------------------------------------------------------
// POSIX Signal implementation
// -----------------------------------------------------------------------

void do_signal(int sig, void (*handler)()) {
    if (sig < 0 || sig >= SIGNAL_MAX) return;
    struct task_struct *curr = get_current();
    curr->signal_handlers[sig] = handler;
}

int do_kill(int pid, int sig) {
    if (sig < 0 || sig >= SIGNAL_MAX) return -1;
    if (!run_queue) return -1;

    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

    struct task_struct *curr = run_queue;
    do {
        if (curr->pid == pid) {
            if (curr->signal_handlers[sig]) {
                // Registered handler: set the pending bit
                curr->pending_signals |= (1u << sig);
            } else {
                // Default action: terminate the process
                curr->state = THREAD_ZOMBIE;
                curr->ppid = 0; // orphan -> idle will reap
            }
            return 0;
        }
        curr = curr->next;
    } while (curr != run_queue);

    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));

    return -1; // pid not found
}

void do_sigreturn(struct trap_frame *tf) {
    struct task_struct *curr = get_current();

    uart_puts("[sigreturn] signal handler finished, pid: ");
    uart_dec(curr->pid);
    uart_puts("\n");

    // Restore original user context (deep copy back into the live trap frame)
    byte_copy(tf, &curr->signal_saved_tf, sizeof(struct trap_frame));

    // Free the temporary signal stack
    if (curr->signal_stack) {
        kfree(curr->signal_stack);
        curr->signal_stack = 0;
    }

    curr->is_handling_signal = 0;
    // tf is now pointing at the restored context; trap_handler returns normally
    // and sret will resume the original user execution.
}

/*
 * signal_check() – called by trap_handler before returning to U-mode.
 *
 * If there is a pending signal with a registered handler, redirect
 * execution to the handler by modifying the live trap frame in-place.
 * A small trampoline (li a7, SYS_sigreturn; ecall) is injected into the
 * bottom of the newly allocated signal stack so the handler auto-calls
 * sigreturn when it returns.
 */
void signal_check(struct trap_frame *tf) {
    // Only act when returning to U-mode (SPP == 0)
    // signal can only happen in U-mode
    if (tf->sstatus & (1UL << 8)) return;

    struct task_struct *curr = get_current();
    if (!curr->pending_signals) return;
    if (curr->is_handling_signal) return;

    // Find the lowest-numbered pending signal
    int sig = -1;
    for (int i = 0; i < SIGNAL_MAX; i++) {
        if (curr->pending_signals & (1u << i)) {
            sig = i;
            break;
        }
    }
    if (sig < 0) return;


    void (*handler)() = curr->signal_handlers[sig];
    if (!handler) {
        // No registered handler: clear bit and terminate
        curr->pending_signals &= ~(1u << sig);
        curr->state = THREAD_ZOMBIE;
        curr->ppid = 0;
        return;
    }

    // Deep-copy the current trap frame so we can restore it in sigreturn
    byte_copy(&curr->signal_saved_tf, tf, sizeof(struct trap_frame));

    // Allocate a stack for the signal handler
    curr->signal_stack = kmalloc(STACK_SIZE);
    curr->is_handling_signal = 1;
    curr->pending_signals &= ~(1u << sig);

    /*
     * Inject the sigreturn trampoline at the bottom of the signal stack:
     *   li   a7, 11          # SYS_sigreturn = 11  -> encoding: 0x00B00893
     *   ecall                #                     -> encoding: 0x00000073
     *
     * Place it at stack_base so the user-mode handler returns to it via ra.
     */
    unsigned int *trampoline = (unsigned int *)curr->signal_stack;
    trampoline[0] = 0x00B00893u; /* li a7, 11  */
    trampoline[1] = 0x00000073u; /* ecall      */
    unsigned long trampoline_addr = (unsigned long)trampoline;

    // New user stack top: top of signal stack, 16-byte aligned
    unsigned long new_sp = ((unsigned long)curr->signal_stack + STACK_SIZE) & ~0xfUL;

    // Redirect trap frame to the handler
    tf->sepc = (unsigned long)handler;
    tf->sp   = new_sp;
    tf->s0   = new_sp;   // frame pointer = sp for a fresh frame
    tf->ra   = trampoline_addr;
    tf->a0   = (unsigned long)sig;
}
