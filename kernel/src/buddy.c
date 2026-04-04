#include "buddy.h"
#include "list.h"
#include "uart.h"
#include "utils.h"
#include "types.h"
#include "dtb.h"

/* ===== Frame Array ======================================================
 *
 *   frame_array[i] >= 0           : head of a free block of order val
 *   frame_array[i] == FRAME_FREE_PART (-1) : free, part of a larger block
 *   frame_array[i] == ALLOC_TAG(idx, order): allocated
 *
 * For free block heads we embed a struct list_head at the start of the
 * page's memory (the page is unused, so this is safe).
 * ==================================================================== */

/* bit 30 set to 1 signifies an allocated frame tag */
#define ALLOC_TAG(idx, order) ((int)((1 << 30) | ((idx) << 8) | (order)))
#define GET_ALLOC_ORDER(val) ((val) & 0xFF)
#define GET_ALLOC_IDX(val) (((val) >> 8) & 0x3FFFFF)

uintptr_t buddy_base_addr = 0;
uintptr_t buddy_end_addr = 0;
unsigned long buddy_total_pages = 0;
int *frame_array = NULL;

extern char _start[];
extern char _end[];

typedef struct {
    uint64_t start;
    uint64_t end;
} mem_region_t;

#define MAX_RESERVED_REGIONS 32
static mem_region_t reserved_regions[MAX_RESERVED_REGIONS];
static int num_reserved = 0;

void memory_reserve(uint64_t start, uint64_t size) {
    if (num_reserved < MAX_RESERVED_REGIONS) {
        reserved_regions[num_reserved].start = start;
        reserved_regions[num_reserved].end = start + size;
        uart_puts("[Reserve] Reserved address [");
        uart_hex(start);
        uart_puts(", ");
        uart_hex(start + size);
        uart_puts("]\n");
        num_reserved++;
    }
}

static void *startup_alloc(unsigned long size) {
    unsigned long pages_needed = (size + PAGE_SIZE - 1) / PAGE_SIZE;
    unsigned long idx = 0;
    while (idx + pages_needed <= buddy_total_pages) {
        int ok = 1;
        uint64_t start_addr = buddy_base_addr + idx * PAGE_SIZE;
        uint64_t end_addr = start_addr + pages_needed * PAGE_SIZE;

        for (int i = 0; i < num_reserved; i++) {
            if (!(end_addr <= reserved_regions[i].start || start_addr >= reserved_regions[i].end)) {
                ok = 0;
                unsigned long clash_end_idx = (reserved_regions[i].end - buddy_base_addr + PAGE_SIZE - 1) / PAGE_SIZE;
                if (clash_end_idx > idx)
                    idx = clash_end_idx;
                else
                    idx++;
                break;
            }
        }
        if (ok) {
            memory_reserve(start_addr, pages_needed * PAGE_SIZE);
            return (void *)start_addr;
        }
    }
    return NULL;
}

/* One free-list head per order (0 .. MAX_ORDER). */
static struct list_head free_list[MAX_ORDER + 1];

/* ---- Helpers ----------------------------------------------------------- */

/** Convert a frame index to the physical address it represents. */
static inline uintptr_t idx_to_addr(unsigned long idx)
{
    return buddy_base_addr + idx * PAGE_SIZE;
}

/** Convert a physical address back to a frame index. */
static inline unsigned long addr_to_idx(uintptr_t addr)
{
    return (addr - buddy_base_addr) / PAGE_SIZE;
}

/**
 * Get the list_head pointer that lives at the start of a free page.
 * Only valid when the page is free and is a block head.
 */
static inline struct list_head *frame_list_head(unsigned long idx)
{
    return (struct list_head *)idx_to_addr(idx);
}

/** Recover the frame index from a list_head that lives in a free page. */
static inline unsigned long list_head_to_idx(struct list_head *lh)
{
    return addr_to_idx((uintptr_t)lh);
}

/**
 * Return the smallest order whose block size >= @pages.
 * block size at order k = 2^k pages.
 */
static int pages_to_order(unsigned long pages)
{
    int order = 0;
    unsigned long block = 1;
    while (block < pages)
    {
        block <<= 1;
        order++;
    }
    return order;
}

/* ---- Logging helpers --------------------------------------------------- */

static void log_add(unsigned long idx, int order)
{
    unsigned long count = 1UL << order;
    uart_puts("[+] Add page ");
    uart_dec(idx);
    uart_puts(" to order ");
    uart_dec((unsigned long)order);
    uart_puts(". Range: [");
    uart_dec(idx);
    uart_puts(", ");
    uart_dec(idx + count - 1);
    uart_puts("]\n");
}

static void log_remove(unsigned long idx, int order)
{
    unsigned long count = 1UL << order;
    uart_puts("[-] Remove page ");
    uart_dec(idx);
    uart_puts(" from order ");
    uart_dec((unsigned long)order);
    uart_puts(". Range: [");
    uart_dec(idx);
    uart_puts(", ");
    uart_dec(idx + count - 1);
    uart_puts("]\n");
}

static void log_buddy_found(unsigned long buddy_idx, unsigned long page_idx,
                            int order)
{
    uart_puts("[*] Buddy found! buddy idx: ");
    uart_dec(buddy_idx);
    uart_puts(" for page ");
    uart_dec(page_idx);
    uart_puts(" with order ");
    uart_dec((unsigned long)order);
    uart_puts("\n");
}

static void log_alloc(uintptr_t addr, int order, unsigned long page_idx)
{
    uart_puts("[Page] Allocate ");
    uart_hex(addr);
    uart_puts(" at order ");
    uart_dec((unsigned long)order);
    uart_puts(", page ");
    uart_dec(page_idx);
    uart_puts("\n");
}

static void log_free(uintptr_t addr, int order, unsigned long page_idx)
{
    uart_puts("[Page] Free ");
    uart_hex(addr);
    uart_puts(" and add back to order ");
    uart_dec((unsigned long)order);
    uart_puts(", page ");
    uart_dec(page_idx);
    uart_puts("\n");
}

/* ---- Internal: add / remove block from free list ----------------------- */

/** Put free block starting at @idx of given @order onto its free list. */
static void block_push(unsigned long idx, int order)
{
    frame_array[idx] = order;
    /* Mark remaining pages in this block as FRAME_FREE_PART */
    unsigned long count = 1UL << order;
    for (unsigned long i = 1; i < count; i++)
        frame_array[idx + i] = FRAME_FREE_PART;

    // utilize the space on idx page to store the list_head
    struct list_head *node = frame_list_head(idx); // return the  idx page's address
    INIT_LIST_HEAD(node);
    list_add(node, &free_list[order]);

    log_add(idx, order);
}

/** Remove free block starting at @idx from its free list. */
static void block_pop(unsigned long idx, int order)
{
    struct list_head *node = frame_list_head(idx);
    list_del(node);

    log_remove(idx, order);
}

/* ===== Public API ======================================================= */

void buddy_init(void)
{
    uintptr_t dtb_mem_start;
    uint64_t dtb_mem_size = 0;
    dtb_get_memory_region(&dtb_mem_start, &dtb_mem_size);
    if (dtb_mem_size == 0) {
        /* Fallback for QEMU virt if devicetree fails */
        uart_puts("Fallback for QEMU virt if devicetree fails\n");
        dtb_mem_start = 0x80000000;
        dtb_mem_size  = 0x10000000; /* 256MB */
    }
    uart_puts("dtb_mem_start=");
    uart_hex(dtb_mem_start);
    uart_puts("\ndtb_mem_size=");
    uart_hex(dtb_mem_size);
    uart_puts("\n");

    buddy_base_addr = dtb_mem_start;
    buddy_end_addr = dtb_mem_start + dtb_mem_size;
    buddy_total_pages = dtb_mem_size / PAGE_SIZE;

    /* Reserve kernel regions explicitly */
    memory_reserve((uintptr_t)_start, (uintptr_t)_end - (uintptr_t)_start);
    
    if (dtb_addr)
        memory_reserve((uintptr_t)dtb_addr, dtb_get_totalsize());

    if (cpio_addr) {
        /* Estimate initramfs size as a generic chunk / bounding box or maybe hardcoded to 20MB for safety if we don't parse length */
        /* Currently we only get start address from dtb_load_initrd_addr. Let's reserve 16MB just in case,
           or if the user provided it in device tree, we parse it properly. */
        memory_reserve((uintptr_t)cpio_addr, 0x1000000); // 16MB reserve
    }

    dtb_find_and_reserve_memory();

    /* Allocate frame_array itself via bump pointer (Advanced Exercise 3) */
    frame_array = (int *)startup_alloc(buddy_total_pages * sizeof(int));
    if (!frame_array) {
        uart_puts("Failed to allocate frame_array!\n");
        return;
    }

    /* Initialise all free list heads. */
    for (int i = 0; i <= MAX_ORDER; i++)
        INIT_LIST_HEAD(&free_list[i]);

    /* All frames start as FRAME_FREE_PART */
    for (unsigned long i = 0; i < buddy_total_pages; i++)
        frame_array[i] = FRAME_FREE_PART;

    /* Flag reserved regions in frame_array */
    for (int i = 0; i < num_reserved; i++) {
        unsigned long start_idx = (reserved_regions[i].start > buddy_base_addr) ? (reserved_regions[i].start - buddy_base_addr) / PAGE_SIZE : 0;
        unsigned long end_idx = (reserved_regions[i].end > buddy_base_addr) ? (reserved_regions[i].end - buddy_base_addr + PAGE_SIZE -1) / PAGE_SIZE : 0;
        if (start_idx < buddy_total_pages) {
            for (unsigned long j = start_idx; j < end_idx && j < buddy_total_pages; j++) {
                frame_array[j] = ALLOC_TAG(j, 0); // Marking it as effectively allocated
            }
        }
    }

    /*
     * Build the initial free blocks.
     * Walk through the range and create the largest possible aligned blocks.
     */
    unsigned long idx = 0;
    while (idx < buddy_total_pages)
    {
        if (frame_array[idx] != FRAME_FREE_PART) {
            idx++;
            continue;
        }

        /* Find the largest order that:
         *   1) is aligned  (idx % (1 << order) == 0)
         *   2) fits        (idx + (1 << order) <= buddy_total_pages)
         *   3) <= MAX_ORDER
         */
        int order = MAX_ORDER;
        while (order > 0)
        {
            unsigned long block_pages = 1UL << order;
            // check alignment  &&  check boundary
            if ((idx & (block_pages - 1)) == 0 && idx + block_pages <= buddy_total_pages) {
                int all_free = 1;
                for (unsigned long j = 0; j < block_pages; j++) {
                    if (frame_array[idx + j] != FRAME_FREE_PART) {
                        all_free = 0;
                        break;
                    }
                }
                if (all_free)
                    break;
            }
            order--;
        }
        block_push(idx, order);
        idx += (1UL << order);
    }

    uart_puts("[Buddy] Initialized: ");
    uart_dec(buddy_total_pages);
    uart_puts(" pages (");
    uart_dec(buddy_total_pages * PAGE_SIZE / 1024 / 1024);
    uart_puts(" MiB) managed\n");
}

void *buddy_alloc(unsigned long size)
{
    if (size == 0)
        return NULL;

    /* Determine how many pages we need. */
    unsigned long pages_needed = (size + PAGE_SIZE - 1) / PAGE_SIZE;
    int target_order = pages_to_order(pages_needed);

    if (target_order > MAX_ORDER)
        return NULL; /* too large */

    /* Search upward for a free block. */
    int current_order = target_order;
    while (current_order <= MAX_ORDER && list_empty(&free_list[current_order]))
        current_order++;

    if (current_order > MAX_ORDER)
        return NULL; /* out of memory */

    /* Take the first block from that list. */
    struct list_head *chosen = free_list[current_order].next;
    unsigned long idx = list_head_to_idx(chosen);
    block_pop(idx, current_order);

    /* Split: release the upper half repeatedly until we reach target_order. */
    while (current_order > target_order)
    {
        current_order--;
        unsigned long buddy_idx = idx + (1UL << current_order);
        block_push(buddy_idx, current_order);
    }

    /* Mark all pages of the allocated block. */
    unsigned long alloc_pages = 1UL << target_order;
    for (unsigned long i = 0; i < alloc_pages; i++)
        frame_array[idx + i] = ALLOC_TAG(idx, target_order);

    uintptr_t addr = idx_to_addr(idx);
    log_alloc(addr, target_order, idx);

    return (void *)addr;
}

void buddy_free(void *ptr)
{
    if (!ptr)
        return;

    uintptr_t addr = (uintptr_t)ptr;
    if (addr < buddy_base_addr || addr >= buddy_end_addr)
        return;

    unsigned long idx = addr_to_idx(addr);

    /* Extract the order of the originally allocated block from the tag */
    int order = GET_ALLOC_ORDER(frame_array[idx]);

    /* Mark pages as free. */
    for (unsigned long j = 0; j < (1UL << order); j++)
        frame_array[idx + j] = FRAME_FREE_PART;

    /* Coalesce with buddy iteratively. */
    unsigned long cur_idx = idx;
    int cur_order = order;

    while (cur_order < MAX_ORDER)
    {
        unsigned long buddy_idx = cur_idx ^ (1UL << cur_order);

        /* Buddy must be within range. */
        if (buddy_idx >= buddy_total_pages)
            break;

        /* Buddy must be a free block head of the same order. */
        if (frame_array[buddy_idx] != cur_order)
            break;

        log_buddy_found(buddy_idx, cur_idx, cur_order);

        /* Remove buddy from its free list. */
        block_pop(buddy_idx, cur_order);

        /* Merge: the merged block starts at the lower index. */
        if (buddy_idx < cur_idx)
            cur_idx = buddy_idx;

        cur_order++;
    }

    /* Place the (possibly merged) block on the appropriate free list. */
    block_push(cur_idx, cur_order);

    log_free(addr, cur_order, cur_idx);
}
