#include "vm.h"

unsigned long __attribute__((section(".bss"), aligned(PAGE_SIZE))) pg_dir[512];

static unsigned long early_alloc_page(void) {
    static unsigned long __attribute__((section(".bss"), aligned(PAGE_SIZE))) early_pages[64][512];
    static int idx = 0;
    if (idx >= 64) {
        while (1) {} // Out of early memory
    }
    return (unsigned long)early_pages[idx++];
}

void map_pages_4k(unsigned long *pgd, unsigned long va, unsigned long size, unsigned long pa, unsigned long prot) {
    unsigned long a = va & ~(PAGE_SIZE - 1);
    unsigned long last = (va + size - 1) & ~(PAGE_SIZE - 1);

    for (;;) {
        int vpn2 = (a >> 30) & 0x1ff;
        int vpn1 = (a >> 21) & 0x1ff;
        int vpn0 = (a >> 12) & 0x1ff;
        unsigned long *pmd, *pte;

        if (pgd[vpn2] & PAGE_PRESENT) {
            pmd = (unsigned long *)((pgd[vpn2] >> 10) << 12);
        } else {
            unsigned long new_page = early_alloc_page();
            pgd[vpn2] = ((new_page >> 12) << 10) | PAGE_PRESENT;
            pmd = (unsigned long *)new_page;
        }

        if (pmd[vpn1] & PAGE_PRESENT) {
            pte = (unsigned long *)((pmd[vpn1] >> 10) << 12);
        } else {
            unsigned long new_page = early_alloc_page();
            pmd[vpn1] = ((new_page >> 12) << 10) | PAGE_PRESENT;
            pte = (unsigned long *)new_page;
        }

        pte[vpn0] = ((pa >> 12) << 10) | prot | PAGE_PRESENT | PAGE_ACCESSED | PAGE_DIRTY;

        if (a == last) break;
        a += PAGE_SIZE;
        pa += PAGE_SIZE;
    }
}

void map_pages_2m(unsigned long *pgd, unsigned long va, unsigned long size, unsigned long pa, unsigned long prot) {
    unsigned long a = va & ~(HPAGE_SIZE - 1);
    unsigned long last = (va + size - 1) & ~(HPAGE_SIZE - 1);

    for (;;) {
        int vpn2 = (a >> 30) & 0x1ff;
        int vpn1 = (a >> 21) & 0x1ff;
        unsigned long *pmd;

        if (pgd[vpn2] & PAGE_PRESENT) {
            pmd = (unsigned long *)((pgd[vpn2] >> 10) << 12);
        } else {
            unsigned long new_page = early_alloc_page();
            pgd[vpn2] = ((new_page >> 12) << 10) | PAGE_PRESENT;
            pmd = (unsigned long *)new_page;
        }

        pmd[vpn1] = ((pa >> 12) << 10) | prot | PAGE_PRESENT | PAGE_ACCESSED | PAGE_DIRTY;

        if (a == last) break;
        a += HPAGE_SIZE;
        pa += HPAGE_SIZE;
    }
}

void setup_vm(void) {
#ifdef QEMU
    // Identity mapping for RAM (Map 2GB to cover DTB/initrd correctly)
    map_pages_2m(pg_dir, 0x80000000, 0x80000000, 0x80000000, PAGE_READ | PAGE_WRITE | PAGE_EXEC | PAGE_GLOBAL);
    // Higher half for RAM (2GB)
    map_pages_2m(pg_dir, PAGE_OFFSET + 0x80000000, 0x80000000, 0x80000000, PAGE_READ | PAGE_WRITE | PAGE_EXEC | PAGE_GLOBAL);

    unsigned long mmio_prot = PAGE_READ | PAGE_WRITE | PAGE_GLOBAL;
    
    // QEMU UART
    map_pages_4k(pg_dir, 0x10000000, 0x1000, 0x10000000, mmio_prot);
    map_pages_4k(pg_dir, PAGE_OFFSET + 0x10000000, 0x1000, 0x10000000, mmio_prot);
    
    // QEMU PLIC
    map_pages_4k(pg_dir, 0x0c000000, 0x400000, 0x0c000000, mmio_prot);
    map_pages_4k(pg_dir, PAGE_OFFSET + 0x0c000000, 0x400000, 0x0c000000, mmio_prot);
    
    // QEMU CLINT
    map_pages_4k(pg_dir, 0x02000000, 0x10000, 0x02000000, mmio_prot);
    map_pages_4k(pg_dir, PAGE_OFFSET + 0x02000000, 0x10000, 0x02000000, mmio_prot);
    
    // QEMU VIRTIO
    map_pages_4k(pg_dir, 0x10001000, 0x1000, 0x10001000, mmio_prot);
    map_pages_4k(pg_dir, PAGE_OFFSET + 0x10001000, 0x1000, 0x10001000, mmio_prot);

    // QEMU FW_CFG
    map_pages_4k(pg_dir, 0x10100000, 0x1000, 0x10100000, mmio_prot);
    map_pages_4k(pg_dir, PAGE_OFFSET + 0x10100000, 0x1000, 0x10100000, mmio_prot);
#else

    // map_pages_2m(pg_dir, 0x00000000, 0x8000000, 0x00000000, PAGE_READ | PAGE_WRITE | PAGE_EXEC | PAGE_GLOBAL);
    // map_pages_2m(pg_dir, PAGE_OFFSET + 0x00000000, 0x8000000, 0x00000000, PAGE_READ | PAGE_WRITE | PAGE_EXEC | PAGE_GLOBAL);

    map_pages_2m(pg_dir, 0x00000000, 0x80000000, 0x00000000, PAGE_READ | PAGE_WRITE | PAGE_EXEC | PAGE_GLOBAL);
    map_pages_2m(pg_dir, PAGE_OFFSET + 0x00000000, 0x80000000, 0x00000000, PAGE_READ | PAGE_WRITE | PAGE_EXEC | PAGE_GLOBAL);
    
    
    unsigned long mmio_prot = PAGE_READ | PAGE_WRITE | PAGE_GLOBAL;
    // Board UART (0x09000000)
    // map_pages_4k(pg_dir, 0x09000000, 0x1000, 0x09000000, mmio_prot);
    // map_pages_4k(pg_dir, PAGE_OFFSET + 0x09000000, 0x1000, 0x09000000, mmio_prot);
    map_pages_4k(pg_dir, 0xD4017000, 0x1000, 0xD4017000, mmio_prot);
    map_pages_4k(pg_dir, PAGE_OFFSET + 0xD4017000, 0x1000, 0xD4017000, mmio_prot);

    // Board PLIC
    map_pages_4k(pg_dir, 0xe0000000, 0x400000, 0xe0000000, mmio_prot);
    map_pages_4k(pg_dir, PAGE_OFFSET + 0xe0000000, 0x400000, 0xe0000000, mmio_prot);
#endif

    // Write satp and flush TLB
    unsigned long satp = SATP_MODE_SV39 | ((unsigned long)pg_dir >> 12);
    asm volatile(
        "csrw satp, %0\n"
        "sfence.vma zero, zero\n"
        : : "r"(satp) : "memory"
    );
}

void drop_identity_map(void) {
    pg_dir[0] = 0; // Covers 0x0 ~ 0x3FFFFFFF (Board RAM, UART, PLIC, CLINT)
    pg_dir[1] = 0; // Covers 0x40000000 ~ 0x7FFFFFFF
    pg_dir[2] = 0; // Covers 0x80000000 ~ 0xBFFFFFFF (QEMU RAM)
    pg_dir[3] = 0; // Covers 0xC0000000 ~ 0xFFFFFFFF (Board PLIC)
    asm volatile("sfence.vma zero, zero\n" : : : "memory");

    //  // 故意存取無映射的實體位址
    // uart_puts("[MMU Test] Trying to read from raw physical address 0x80200000 directly...\n");
    // volatile unsigned int *raw_phys_ptr = (volatile unsigned int *)0x80200000UL;
    // unsigned int val = *raw_phys_ptr; // 這行會讀取實體位址
    
    // uart_puts("[MMU Test] Value read: "); // 這行將永遠不會被執行到
    // uart_hex(val);
    // uart_puts("\n");
}
