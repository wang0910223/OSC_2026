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

int boot_hart_id;

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

    uart_puts("\nKernel Starting...\n\n");

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
    asm volatile("csrs sie, %0" :: "r"(SIE_SEIE));
    asm volatile("csrs sstatus, %0" :: "r"(SSTATUS_SIE));
    uart_puts("[PLIC] UART0 interrupt routing enabled.\n");

    shell();

    return;
}