#ifndef __PLIC_H__
#define __PLIC_H__

#include "vm.h"

#ifdef QEMU
    #define PLIC_BASE       (0x0c000000UL + PAGE_OFFSET)
    #define UART0_IRQ       10
#else
    #define PLIC_BASE       (0xe0000000UL + PAGE_OFFSET)
    #define UART0_IRQ       42
#endif

/* PLIC Priority Register Array (4 bytes per IRQ) */
#define PLIC_PRIORITY(irq)   (PLIC_BASE + (irq) * 4)   // plic p.12 (Interrupt source 1 priority)

/* PLIC Pending Register Array (32 IRQs per word) */
#define PLIC_PENDING(irq)    (PLIC_BASE + 0x1000 + ((irq) / 32) * 4)   // p.12 (base + 0x001000: Interrupt Pending bit 0-31)

/* PLIC Enable Array.
 * Context 1 corresponds to Hart 0 S-mode based on standard bindings
 * and SpacemiT K1 Device Tree. 
 */
#define PLIC_HART0_S_CONTEXT 1
#define PLIC_ENABLE(ctx)     (PLIC_BASE + 0x2000 + (ctx) * 0x80)  // base + 0x002000 for context 0, base + 0x002080 for context 1

/* PLIC Priority Threshold and Claim/Complete */
#define PLIC_THRESHOLD(ctx)  (PLIC_BASE + 0x200000 + (ctx) * 0x1000)   // p.12 base + 0x200000: Priority threshold for context 0
#define PLIC_CLAIM(ctx)      (PLIC_BASE + 0x200004 + (ctx) * 0x1000)   // p.12 base + 0x200004: Claim/complete for context 0

void plic_init(void);
int plic_claim(void);
void plic_complete(int irq);

#endif /* __PLIC_H__ */
