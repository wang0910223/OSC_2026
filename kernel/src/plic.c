#include "plic.h"
#include "types.h"

// 引入 main.c 幫你存好的 hart_id
extern int boot_hart_id; 

/* Helper to read 32-bit register */
static inline uint32_t plic_read32(unsigned long addr)
{
    return *(volatile uint32_t *)addr;
}

/* Helper to write 32-bit register */
static inline void plic_write32(unsigned long addr, uint32_t val)
{
    *(volatile uint32_t *)addr = val;
}

/* 動態計算當前 CPU 的 S-mode Context ID */
static inline int get_current_s_context(void) {
    return 2 * boot_hart_id + 1; 
}

void plic_init(void)
{
    int ctx = get_current_s_context();

    /* 1. Set priority for UART0 IRQ to 1 */
    plic_write32(PLIC_PRIORITY(UART0_IRQ), 1);

    /* 2. Enable UART0 IRQ for THE CURRENT HART S-mode */
    unsigned long enable_reg = PLIC_ENABLE(ctx) + (UART0_IRQ / 32) * 4;
    uint32_t enable_bits = plic_read32(enable_reg);
    enable_bits |= (1 << (UART0_IRQ % 32));
    plic_write32(enable_reg, enable_bits);

    /* 3. Set priority threshold for current Hart to 0 */
    plic_write32(PLIC_THRESHOLD(ctx), 0);
}

int plic_claim(void)
{
    return plic_read32(PLIC_CLAIM(get_current_s_context()));
}

void plic_complete(int irq)
{
    plic_write32(PLIC_CLAIM(get_current_s_context()), irq);
}