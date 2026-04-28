#include "task.h"
#include "kmalloc.h"
#include "uart.h"
#include "riscv.h"
#include "types.h"

struct task {
    task_callback_t callback;
    void *arg;
    int priority;
    struct task *next;
};

/* Ordered Linked list, highest priority number first */
static struct task *task_head = NULL;

/* Tracks the priority of the currently running task, -1 = no task currently running */
static int current_priority = -1;

void add_task(task_callback_t callback, void *arg, int priority)
{
    struct task *new_task = (struct task *)kmalloc(sizeof(struct task));
    if (!new_task) {
        uart_puts("add_task: kmalloc failed\n");
        return;
    }
    new_task->callback = callback;
    new_task->arg = arg;
    new_task->priority = priority;
    new_task->next = NULL;

    /* Enter critical section */
    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

    if (!task_head || new_task->priority > task_head->priority) {
        new_task->next = task_head;
        task_head = new_task;
    } else {
        struct task *curr = task_head;
        while (curr->next && curr->next->priority >= new_task->priority) {
            curr = curr->next;
        }
        new_task->next = curr->next;
        curr->next = new_task;
    }

    /* Leave critical section */
    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
}

void run_tasks(void)
{
    while (1) {
        /* Safely check the task list */
        unsigned long saved_sstatus;
        asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

        if (!task_head || task_head->priority <= current_priority) {
            /* No more tasks, or tasks are of lower/equal priority 
               than the one we are already handling. Wait for it. */
            asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
            break;
        }

        struct task *curr = task_head;
        task_head = task_head->next;

        int prev_priority = current_priority;
        current_priority = curr->priority;

        /* Enable global interrupts to allow nested interrupts and higher-priority preemption */
        asm volatile("csrs sstatus, 2");

        if (curr->callback) {
            curr->callback(curr->arg);
        }

        /* Disable global interrupts to wrap up */
        asm volatile("csrc sstatus, 2");

        current_priority = prev_priority;
        kfree(curr);

        /* Restore original interrupt state for the while loop evaluation */
        asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
    }
}
