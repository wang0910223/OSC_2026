#include "../include/uart.h"
#include "../include/shell.h"
#include "../include/dtb.h"

int boot_hart_id;

void main(int hart_id, void *dtb_ptr){
    boot_hart_id = hart_id;

    // uart_init(dtb_addr);

    /* Step 1: Register the DTB address so the parser can use it. */
    dtb_set_addr(dtb_ptr);
    uart_puts("\ndtb base=");
    uart_hex((unsigned long)dtb_ptr);

    /* Step 1b: Resolve initrd address from /chosen so cpio commands work. */
    dtb_load_initrd_addr();
    uart_puts("\ninitrd base=");
    uart_hex((unsigned long)CPIO_DEFAULT_ADDR);

    /* Step 2: Resolve UART base address from the devicetree.
     *
     *  OrangePi RV2 : /soc/serial
     *  QEMU virt    : /soc/serial  (node name "serial@10000000")
     *
     * Both boards use the same logical path; node_name_match() in dtb.c
     * handles the "@<unit-addr>" suffix transparently.
     *
     * We also try /soc/uart as a fallback for non-standard boards.
     */
    uintptr_t u_base = dtb_get_reg("/soc/serial");
    if (u_base == 0)
        u_base = dtb_get_reg("/soc/uart");

    /* Step 3: Override the UART driver's base address before first use. */
    uart_set_base((unsigned long)u_base);

    /* Step 4: Announce the resolved address (sanity check). */
    uart_puts("\nUART base=");
    uart_hex(u_base);
    uart_puts("\n");
    
    uart_puts("\nKernel Starting 14:06...\n");
    
    shell();


    // while(1){
    //     uart_putc(uart_getc());
    // }
    return;
}