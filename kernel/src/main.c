#include "../include/uart.h"
#include "../include/shell.h"
#include "../include/dtb.h"

int boot_hart_id;

void main(int hart_id, void *dtb_ptr)
{
    boot_hart_id = hart_id;

    /* Step 1: Register the DTB address so the parser can use it. */
    dtb_set_addr(dtb_ptr);

    /* Step 2: Resolve UART base address from the devicetree.
     *  OrangePi RV2 : /soc/serial
     *      we can use "dtc -I dtb -O dts -o x1_orangepi-rv2.dts x1_orangepi-rv2.dtb" to check the info in dts format
     *  QEMU virt    : /soc/serial  (node name "serial@10000000")
     */
    unsigned long u_base = dtb_get_reg("/soc/serial");
    if (u_base == 0)
        u_base = dtb_get_reg("/soc/uart");

    /* Step 3: Override the UART driver's base address before first use. */
    uart_set_base((unsigned long)u_base);
    /* Resolve initrd address and print the address*/
    dtb_load_initrd_addr();

#ifdef DEBUG
    /* Print the address of DTB and UART */
    uart_puts("\ndtb base=");
    uart_hex((unsigned long)dtb_ptr);
    uart_puts("\nUART base=");
    uart_hex((unsigned long)u_base);
    uart_puts("\n");

    uart_puts("\ninitrd base=");
    uart_hex((unsigned long)cpio_addr);
#endif

    uart_puts("\nKernel Starting...\n");

    shell();

    return;
}