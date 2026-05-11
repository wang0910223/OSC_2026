#ifndef _VM_H_
#define _VM_H_

#define PAGE_OFFSET 0xffffffc000000000UL
#define PAGE_SIZE   (1UL << 12)
#define HPAGE_SIZE  (1UL << 21) // 2MB PMD page size
#define PFN_DOWN(x) ((x) >> 12)

/* Page protection bits */
#define PAGE_PRESENT  (1UL << 0)
#define PAGE_READ     (1UL << 1)
#define PAGE_WRITE    (1UL << 2)
#define PAGE_EXEC     (1UL << 3)
#define PAGE_USER     (1UL << 4)
#define PAGE_GLOBAL   (1UL << 5)
#define PAGE_ACCESSED (1UL << 6)
#define PAGE_DIRTY    (1UL << 7)

#define PAGE_KERNEL                                                    \
    (PAGE_PRESENT | PAGE_READ | PAGE_WRITE | PAGE_EXEC | PAGE_GLOBAL | \
     PAGE_ACCESSED | PAGE_DIRTY)

#define PAGE_BASE      (PAGE_DIRTY | PAGE_ACCESSED | PAGE_USER | PAGE_PRESENT)
#define PAGE_RX        (PAGE_BASE | PAGE_READ | PAGE_EXEC)
#define PAGE_RW        (PAGE_BASE | PAGE_READ | PAGE_WRITE)

#define SATP_MODE_SV39 (8UL << 60)

#define __va(pa) ((void *)((unsigned long)(pa) + PAGE_OFFSET))
#define __pa(va) ((unsigned long)(va) - PAGE_OFFSET)

extern unsigned long pg_dir[512];

void setup_vm(void);
void drop_identity_map(void);
void map_pages_4k(unsigned long *pgd, unsigned long va, unsigned long size, unsigned long pa, unsigned long prot);
void map_pages_2m(unsigned long *pgd, unsigned long va, unsigned long size, unsigned long pa, unsigned long prot);

void *alloc_page(void);
void pagewalk(unsigned long *pgd, unsigned long va, unsigned long pa, unsigned long prot);
void map_pages(unsigned long *pgd, unsigned long va, unsigned long size, unsigned long pa, unsigned long prot);
void free_user_space(unsigned long *pgd);
void unmap_page(unsigned long *pgd, unsigned long va);

#endif
