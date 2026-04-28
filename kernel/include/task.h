#ifndef __TASK_H__
#define __TASK_H__

typedef void (*task_callback_t)(void *arg);

void add_task(task_callback_t callback, void *arg, int priority);
void run_tasks(void);

#endif /* __TASK_H__ */
