#include "uart.h"
#include "shell.h"
#include "dtb.h"
#include "buddy.h"
#include "types.h"
#include "trap.h"
#include "kmalloc.h"
#include "timer.h"
#include "plic.h"
#include "riscv.h"
#include "thread.h"
#include "video.h"
#include "bird.h"

int boot_hart_id;

void video_animation_thread() {
    while (1) {
        for (int i = 0; i < FRAME_COUNT; i++) {
            video_bmp_display(&FRAME_PIXEL(i, 0, 0), FRAME_WIDTH, FRAME_HEIGHT);
            for (int j = 0; j < 500000; j++) asm volatile("nop");
            schedule();
            // do_usleep(50000);
        }
    }
}

void main(int hart_id, void *dtb_ptr)
{
    boot_hart_id = hart_id;

    /* Step 1: Register the DTB address so the parser can use it. */
    dtb_set_addr(dtb_ptr);

    /* Step 2: Resolve UART base address from the devicetree. */
    unsigned long u_base = dtb_get_reg("/soc/serial");
    if (u_base == 0)
        u_base = dtb_get_reg("/soc/uart");

    /* Step 3: Override the UART driver's base address before first use.
     * At this point uart_puts uses synchronous polling (no IRQ yet). */
    uart_set_base((unsigned long)u_base);
    dtb_load_initrd_addr();

#ifdef DEBUG
    uart_puts("\ndtb base=");
    uart_hex((unsigned long)dtb_ptr);
    uart_puts("\nUART base=");
    uart_hex((unsigned long)u_base);
    uart_puts("\n");
    uart_puts("\ninitrd base=");
    uart_hex((unsigned long)cpio_addr);
#endif

    /* Step 3.5: Initialize Video (reserve FB memory if needed) */
    video_init();

    /* Step 4: Initialize the buddy page-frame allocator. */
    buddy_init();

    /* Step 5: Initialize the dynamic memory allocator (chunk pools). */
    kmalloc_init();

    /* Step 6: Install trap vector BEFORE enabling any interrupts. */
    trap_init();
    uart_puts("[Trap] stvec installed.\n");

    /* Step 7: Start core timer. */
    core_timer_enable();

    /* Step 8: Now safe to initialize PLIC and switch UART to async mode.
     * The trap vector is already pointing at our handler,
     * so any UART IRQ that fires will be caught correctly. */
     
    plic_init();
    uart_intr_enable();

    /* Step 9: Open global S-mode interrupts (timer + external). */
    asm volatile("csrs sie, %0" :: "r"(SIE_SEIE));   //  enable external, 9th bit
    asm volatile("csrs sstatus, %0" :: "r"(SSTATUS_SIE));   // enable global interrupt
    uart_puts("[PLIC] UART0 interrupt routing enabled.\n");
    
    // shell();

    // Bootstrap: create idle task for current context (main), set tp
    struct task_struct *idle_thread = thread_create(idle);
    asm volatile("mv tp, %0" : : "r"(idle_thread));

    // Create shell as a separate thread
    thread_create(shell);

    // Create video animation thread
    // thread_create(video_animation_thread);

    // main becomes the idle loop
    idle();

    return;
}