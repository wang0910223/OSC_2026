#include "timer.h"
#include "sbi.h"
#include "riscv.h"
#include "uart.h"

#ifdef QEMU
#define SYS_CLOCK_FREQ 10000000
#else
#define SYS_CLOCK_FREQ 24000000
#endif

// 2 seconds
#define TIMER_INTERVAL (SYS_CLOCK_FREQ * 2)

static unsigned long boot_seconds = 0;

static inline unsigned long get_cycles(void) {
    unsigned long cycles;
    asm volatile ("rdtime %0" : "=r" (cycles));
    return cycles;
}

void core_timer_enable(void) {
    // 1. Calculate the target time by adding twice the CPU’s frequency to the current time (this represents 2 seconds).
    unsigned long target = get_cycles() + TIMER_INTERVAL;
    
    // 2. Call sbi_set_timer(target_time) to schedule the interrupt.
    sbi_set_timer(target);

    // 3. Set the STIE bit in the sie register to enable timer interrupts.
    asm volatile("csrs sie, %0" :: "r"(SIE_STIE));

    // 4. Set the SIE bit in sstatus to enable global interrupts.
    asm volatile("csrs sstatus, %0" :: "r"(SSTATUS_SIE));
    
    uart_puts("[Timer] Core timer generated.\n");
}

void core_timer_handler(void) {
    boot_seconds += 2;
    
    uart_puts("[Timer] Boot time: ");
    uart_dec(boot_seconds);
    uart_puts(" \n");

    // Reprogram the timer for the next 2 seconds
    unsigned long target = get_cycles() + TIMER_INTERVAL;
    sbi_set_timer(target);
}
