#ifndef TIMER_H
#define TIMER_H

typedef void (*timer_callback_t)(void *arg);

void core_timer_enable(void);
void core_timer_handler(void);

void add_timer(timer_callback_t callback, void *arg, int sec);
unsigned long get_cycles(void);
unsigned long get_timer_freq(void);

#endif
