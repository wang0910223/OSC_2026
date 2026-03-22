#include "../include/uart.h"
#include "../include/shell.h"
#include "../include/dtb.h"

#ifdef QEMU
char *_relocate_addr = (char *)0x82000000UL;
#else
char *_relocate_addr = (char *)0x20000000UL;
#endif // QEMU

extern char *const _code_start;
extern unsigned long long _code_size;
void code_relocate(int hart_id, void *dtb_ptr);
int boot_hart_id;

static int had_relocated = -1;

unsigned long get_current_pc(void)
{
    unsigned long pc;
    __asm__ volatile("auipc %0, 0" : "=r"(pc));
    return pc;
}

void main(int hart_id, void *dtb_ptr)
{
    /* Step 1: Register the DTB address so the parser can use it. */
    dtb_set_addr(dtb_ptr);

    /* Step 2: Resolve UART base address from the devicetree.
     *
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
    uart_puts("\ninitrd base=");
    uart_hex((unsigned long)cpio_addr);
    uart_puts("\n");
#endif

    if (had_relocated == -1)
    {
        uart_puts("\n[Before Relocation] PC: ");
        uart_hex(get_current_pc());
        uart_puts("\n");

        had_relocated = 1;
        code_relocate(hart_id, dtb_ptr);
    }
    else
    {
        uart_puts("Run in new place!\n");
        uart_puts("[After Relocation] PC: ");
        uart_hex(get_current_pc());
        uart_puts("\n");
    }

    uart_puts("\nBootloader starting...\n");

    boot_hart_id = hart_id;
    shell();

    return;
}

void code_relocate(int hart_id, void *dtb_ptr)
{
    uart_puts("\nStart relocating!\n");
    char *relocate_addr = _relocate_addr;
    char *const code_start = (char *)&_code_start;
    unsigned long long loader_size = (unsigned long long)&_code_size;

    for (unsigned long long i = 0; i < loader_size; ++i)
        relocate_addr[i] = code_start[i];

    uart_puts("Relocating completed!\n");
    register unsigned long a0 asm("a0") = hart_id;
    register unsigned long a1 asm("a1") = (unsigned long)dtb_ptr;

    __asm__ volatile("fence.i");
    __asm__ volatile(
        "jr %0"
        :
        : "r"(relocate_addr), "r"(a0), "r"(a1));
}