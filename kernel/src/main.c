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
#include "vm.h"

int boot_hart_id;

void main(int hart_id, void *dtb_ptr)
{
    boot_hart_id = hart_id;

    dtb_ptr = __va(dtb_ptr);

    /* Step 1: Register the DTB address so the parser can use it. */
    dtb_set_addr(dtb_ptr);

    /* Step 2: Resolve UART base address from the devicetree. */
    unsigned long u_base = dtb_get_reg("/soc/serial");
    if (u_base == 0)
        u_base = dtb_get_reg("/soc/uart");

    /* Step 3: Override the UART driver's base address before first use.
     * At this point uart_puts uses synchronous polling (no IRQ yet). */
    uart_set_base((unsigned long)__va(u_base));
    uart_puts("Entered main!\n");
    dtb_load_initrd_addr();
    if (cpio_addr)
        cpio_addr = (char *)__va(cpio_addr);

    drop_identity_map();
        // 讀取 satp 控制暫存器
    // unsigned long satp_val;
    // asm volatile("csrr %0, satp" : "=r"(satp_val));

    // uart_puts("\n[MMU Test] Current satp register value: ");
    // uart_hex(satp_val);
    // uart_puts("\n");

    // // 解析 satp 欄位
    // unsigned long mode = satp_val >> 60; // 取得最高 4 位的 MODE 欄位
    // unsigned long ppn = satp_val & 0xfffffffffffUL; // 取得低位的分頁表實體頁框號 (PPN)

    // if (mode == 8) {
    //     uart_puts("[MMU Test] SUCCESS: MMU is actively running in Sv39 (3-level) mode!\n");
    // } else if (mode == 0) {
    //     uart_puts("[MMU Test] FAILED: MMU is turned off (Bare Mode).\n");
    // } else {
    //     uart_puts("[MMU Test] Running in another mode.\n");
    // }

    // uart_puts("[MMU Test] Root Page Table physical address (PPN * 4KB): ");
    // uart_hex(ppn << 12);
    // uart_puts("\n\n");


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
    
    // Bootstrap: create idle task for current context (main), set tp
    struct task_struct *idle_thread = thread_create(idle);
    asm volatile("mv tp, %0" : : "r"(idle_thread));

    // Create shell as a separate thread
    thread_create(shell);

    // main becomes the idle loop
    idle();

    return;
}