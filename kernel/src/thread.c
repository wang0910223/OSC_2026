
#include "kmalloc.h"
#include "buddy.h"
#include "uart.h"
#include "thread.h"

extern void switch_to(struct task_struct* prev, struct task_struct* next);

#define STACK_SIZE 4096

enum thread_state {
    THREAD_RUNNING,
    THREAD_ZOMBIE,
};

struct task_struct {
    struct thread_struct {
        unsigned long ra;
        unsigned long sp;
        unsigned long s[12];
    } thread;
    int pid;
    enum thread_state state;
    unsigned long kernel_sp;
    unsigned long user_sp;
    unsigned long stack;
    struct task_struct* next;
};

static int nr_threads = 0;
static struct task_struct* run_queue = 0;

static void enqueue(struct task_struct** queue, struct task_struct* task) {
    if (*queue == 0) {
        *queue = task;
        task->next = task;
    } else {
        struct task_struct* tail = (*queue)->next;
        (*queue)->next = task;
        task->next = tail;
    }
}

static void dequeue(struct task_struct** queue, struct task_struct* task) {
    if (*queue == 0) return;
    
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
}

struct task_struct* get_current() {
    register struct task_struct* current asm("tp");
    return current;
}



void schedule() {
    struct task_struct* prev = get_current();
    struct task_struct* next = prev->next;

    while (next->state == THREAD_ZOMBIE && next != prev) {
        next = next->next;
    }

    if (prev != next) {
        switch_to(prev, next);
    }
}

void thread_exit() {
    struct task_struct* current = get_current();
    current->state = THREAD_ZOMBIE;
    schedule();
    while (1);  // Just in case accidentally return
}

void kill_zombies() {
    if (!run_queue) return;
    
    struct task_struct* curr = run_queue;
    do {
        struct task_struct* next = curr->next;
        if (next->state == THREAD_ZOMBIE) {
            dequeue(&run_queue, next);
            kfree((void*)next->stack);
            kfree(next);
            curr = run_queue;
            if (!curr) break;
            continue;
        }
        curr = curr->next;
    } while (curr != run_queue);
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
    struct task_struct *idle_thread = thread_create(idle);
    asm volatile("mv tp, %0" : : "r"(idle_thread));
    
    for (int i = 0; i < 3; i++) {
        thread_create(foo);
    }
    idle();
}