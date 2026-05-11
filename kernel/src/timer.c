#include "timer.h"
#include "kmalloc.h"
#include "riscv.h"
#include "sbi.h"
#include "types.h"
#include "uart.h"
#include "thread.h"

#ifdef QEMU
#define SYS_CLOCK_FREQ 10000000
#else
#define SYS_CLOCK_FREQ 24000000
#endif

// 2 seconds
#define TIMER_INTERVAL (SYS_CLOCK_FREQ * 2)

static unsigned long boot_seconds = 0;
static int need_resched = 0;

struct timer_event {
  unsigned long expire_cycles;
  timer_callback_t callback;
  void *arg;
  struct timer_event *next;
};

// List 依照 expire_cycles 由小到大排序
static struct timer_event *timer_head = NULL;  

unsigned long get_timer_freq(void) { return SYS_CLOCK_FREQ; }

unsigned long get_cycles(void) {
	unsigned long cycles;
	// RISC-V 指令，用來讀取 CPU 內建的計時器（從開機到現在總共過了幾個 cycle）
	asm volatile("rdtime %0" : "=r"(cycles));
	return cycles;
}

void add_timer_ticks(timer_callback_t callback, void *arg, unsigned long ticks) {
    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

    struct timer_event *new_event = (struct timer_event *)kmalloc(sizeof(struct timer_event));
	if (!new_event) {
		uart_puts("add_timer: kmalloc failed\n");
		goto out;
	}

	/* fill the info. to struct timer_event */
	new_event->expire_cycles = get_cycles() + ticks;
	new_event->callback = callback;
	new_event->arg = arg;
	new_event->next = NULL;

	if (!timer_head || new_event->expire_cycles < timer_head->expire_cycles) {
		new_event->next = timer_head;
		timer_head = new_event;
		sbi_set_timer(timer_head->expire_cycles);
	} 
	else {
		struct timer_event *curr = timer_head;
		while (curr->next && curr->next->expire_cycles <= new_event->expire_cycles) {
			curr = curr->next;
		}
		new_event->next = curr->next;
		curr->next = new_event;
	}

out:
	asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
}

void add_timer(timer_callback_t callback, void *arg, int sec) {
    add_timer_ticks(callback, arg, (unsigned long)sec * SYS_CLOCK_FREQ);
}

static void boot_time_cb(void *arg) {
  boot_seconds += 2;
  uart_puts("[Timer] Boot time: ");
  uart_dec(boot_seconds);
  uart_puts(" \n");
  /* Re-register for another 2 seconds */
  add_timer(boot_time_cb, NULL, 2);
}

static void preempt_callback(void *arg) {
    // Re-register for the next 1/32 second
    add_timer_ticks(preempt_callback, NULL, SYS_CLOCK_FREQ / 32);
    // Give up CPU
    // schedule();
    need_resched = 1;
}

void core_timer_enable(void) {
  // 1. Set the STIE bit in the sie register to enable timer interrupts.
  asm volatile("csrs sie, %0" ::"r"(SIE_STIE));
  uart_puts("[Timer] Core timer generated.\n");

  // Start the periodic preemption timer (1/32 second)
  add_timer_ticks(preempt_callback, NULL, SYS_CLOCK_FREQ / 32);

  // Start the periodic boot time timer using software timer multiplexer
//   add_timer(boot_time_cb, NULL, 2);
}

void core_timer_handler(void) {
  need_resched = 0;

  /* Process all expired timers */
  while (timer_head && timer_head->expire_cycles <= get_cycles()) {
    struct timer_event *event = timer_head;
    timer_head = timer_head->next;

    /* Execute callback */
    if (event->callback) {
      event->callback(event->arg);
    }

    /* Free the event struct */
    kfree(event);
  }

  /* Reprogram the next timer interrupt if there's any pending event */
  if (timer_head) {
    sbi_set_timer(timer_head->expire_cycles);
  } else {
    /* Set timer to very large value so it doesn't trigger immediately again */
    sbi_set_timer(0xFFFFFFFFFFFFFFFFUL);
  }

  if (need_resched) {
    schedule();
  }
}
