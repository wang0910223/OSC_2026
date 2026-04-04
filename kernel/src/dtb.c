#include "dtb.h"
#include "uart.h"
#include "utils.h"
#include "buddy.h"

#define FDT_BEGIN_NODE  0x00000001
#define FDT_END_NODE    0x00000002
#define FDT_PROP        0x00000003
#define FDT_NOP         0x00000004
#define FDT_END         0x00000009

#define FDT_HEADER_MAGIC 0xD00DFEED
// https://devicetree-specification.readthedocs.io/en/stable/flattened-format.html  (Section 5.2)

 struct fdt_prop {
    uint32_t len;
    uint32_t nameoff;
};

char *dtb_addr;
void *cpio_addr;


struct fdt_header {
    uint32_t magic;
    uint32_t totalsize;
    uint32_t off_dt_struct;
    uint32_t off_dt_strings;
    uint32_t off_mem_rsvmap;
    uint32_t version;
    uint32_t last_comp_version;
    uint32_t boot_cpuid_phys;
    uint32_t size_dt_strings;
    uint32_t size_dt_struct;
};


static inline uint32_t bswap_32(uint32_t x)
{
    return ((x & 0xFF000000) >> 24) |
           ((x & 0x00FF0000) >> 8) |
           ((x & 0x0000FF00) << 8) |
           ((x & 0x000000FF) << 24);
}

static inline uint64_t bswap_64(uint64_t x)
{
    uint32_t hi = bswap_32((uint32_t)(x >> 32));
    uint32_t lo = bswap_32((uint32_t)(x & 0xFFFFFFFF));
    return ((uint64_t)hi << 32) | lo;
}

static inline uint64_t align_32(uint64_t addr)
{
    return (addr + 3) & ~((uint64_t)3);
}

/*
 * node_name_match - compare a DTB node name against a path segment.
 * DTB node names often include a unit-address: "serial@10000000".
 * This helper treats the part before '@' as the effective name, so
 * node_name_match("serial@10000000", "serial") returns 1 (true).
 */
static int node_name_match(const char *node_name, const char *seg)
{
    while (*seg) {
        if (*node_name == '\0' || *node_name == '@')
            return 0;           /* seg still has chars but name ran out */
        if (*node_name != *seg)
            return 0;
        node_name++;
        seg++;
    }
    /* seg exhausted: node_name must be end-of-string or '@' */
    return (*node_name == '\0' || *node_name == '@');
}

/*
 * path_segment - return pointer to the i-th component of a '/' separated
 * path, and store its length in *len.  Returns NULL when i >= depth.
 * path must start with '/'.  Depth 0 is the root (""), depth 1 is the
 * first real component, etc.
 */
static const char *path_segment(const char *path, int idx, int *seg_len)
{
    if (!path || path[0] != '/')
        return 0;

    const char *p = path + 1;   /* skip leading '/' */
    int i = 0;

    while (1) {
        if (*p == '\0') {
            /* we reached the end without finding idx */
            return 0;
        }
        const char *start = p;
        while (*p && *p != '/')
            p++;
        if (i == idx) {
            *seg_len = (int)(p - start);
            return start;
        }
        i++;
        if (*p == '/')
            p++;
    }
}

/* Count how many '/' separated components a path has (root="/" → 0) */
static int path_depth(const char *path)
{
    if (!path || path[0] != '/')
        return -1;
    if (path[1] == '\0')
        return 0;   /* root */
    int n = 0;
    for (const char *p = path + 1; *p; p++)
        if (*p == '/')
            n++;
    return n + 1;   /* e.g. "/soc/serial" has 2 components */
}

void dtb_set_addr(void *addr)
{
    dtb_addr = (char *)addr;
}

/*
 * dtb_getprop - locate a property inside the DTB.
 *
 * node_path examples: "/", "/soc", "/soc/serial"
 * prop_name examples: "reg", "compatible"
 *
 * Returns a pointer to the raw property data, or NULL on failure.
 * The data is big-endian; callers must byte-swap as needed.
 */
const void *dtb_getprop(const char *node_path, const char *prop_name, int *lenp)
{
    if (!dtb_addr || !node_path || !prop_name)
        return 0;

    /* Step 1: Check the magic number */
    struct fdt_header *header = (struct fdt_header *)dtb_addr;
    if (bswap_32(header->magic) != FDT_HEADER_MAGIC)
        return 0;

    /* Step 2: Calculate the depth of the target node */
    int wanted_depth = path_depth(node_path);

    /* Step 3: Get the size of the device tree structure block and strings block */
    uint32_t struct_size = bswap_32(header->size_dt_struct);
    char *dt_struct = (char *)header + bswap_32(header->off_dt_struct);
    char *dt_strings = (char *)header + bswap_32(header->off_dt_strings);

    char *cur        = dt_struct;
    char *struct_end = dt_struct + struct_size;

    /*
     * current_depth tracks how many levels deep we are in the tree.
     * depth 0 = inside root node.
     * matched_depth is set when we find the target node.
     */
    int current_depth = -1;     /* -1 = not yet inside root */
    int matched_depth = -1;     /* -1 = target not yet found */

    while (cur < struct_end) {
        uint32_t token = bswap_32(*(uint32_t *)cur);
        cur += 4;

        if (token == FDT_BEGIN_NODE) {
            const char *node_name = cur;
            while (*cur)
                cur++;
            cur++;
            cur = (char *)align_32((uint64_t)cur);

            current_depth++;

            /*
             * Check whether this node matches the corresponding segment
             * of the wanted path at this depth.
             * matched_depth < 0 means we haven't found the target node yet
             */
            if (matched_depth < 0) {
                /* Root node doesn't have name, so if wanted_depth is 0, we match it */
                if (current_depth == 0) {
                    if (wanted_depth == 0)
                        matched_depth = 0;
                } 
                /* Parsing and comparing the node name with the path segment */
                else {
                    
                    int seg_len;
                    /* Segment index within path = current_depth - 1 */
                    const char *seg = path_segment(node_path, current_depth - 1, &seg_len);

                    /* If the segment is found, compare it with the node name */
                    if (seg) {
                        /* devide the segment and store it in seg_buf
                         * since a segment in the path may not end with '\0'  (e.g., "soc/ ...")
                         * we need to copy it into a buffer and add '\0' at the end
                         */
                        char seg_buf[64];
                        int copy_len = seg_len < 63 ? seg_len : 63;
                        int i;
                        for (i = 0; i < copy_len; i++)
                            seg_buf[i] = seg[i];
                        seg_buf[i] = '\0';

                        /* Compare the segment with the node name */
                        if (node_name_match(node_name, seg_buf)) {
                            if (current_depth == wanted_depth)
                                matched_depth = current_depth;
                            /* else: continue descending */
                        }
                        /* else: wrong branch — we'll go deeper but won't match */
                    }
                }
            }

        } else if (token == FDT_END_NODE) {
            if (matched_depth == current_depth)
                matched_depth = -1;     /* exited the target node */
            current_depth--;

        } else if (token == FDT_PROP) {
            struct fdt_prop *prop = (struct fdt_prop *)cur;
            /* let cur point to the property data */
            cur += sizeof(struct fdt_prop);

            uint32_t prop_len = bswap_32(prop->len);
            const char *name = dt_strings + bswap_32(prop->nameoff);

            /* atched_depth >= 0 means we are inside the target node, check each property */
            if (matched_depth >= 0) {
                if(strcmp(name, prop_name) == 0){
                    if (lenp) *lenp = (int)prop_len;
                    return cur;
                }
            }

            cur += prop_len;
            cur = (char *)align_32((uint64_t)cur);

        } else if (token == FDT_NOP) {
            continue;

        } else if (token == FDT_END) {
            break;

        } else {
            break;
        }
    }

    if (lenp) *lenp = 0;
    return 0;
}

uintptr_t dtb_get_reg(const char *path)
{
    int len = 0;
    const void *value = dtb_getprop(path, "reg", &len);

    /* In device tree, the basic address unit is 32 bits, 
     * so we need to check if the length is at least 4 bytes */
    if (!value || len < 4)
        return 0;

    const uint32_t *p32 = (const uint32_t *)value;
    if (len >= 8) {
        /* when we are retrieving the property of /soc/serial, the len is 8 
         * which is defined in the device tree as "reg = <address length>;"
         * and the size of address and length are both 8 bytes (2 cells), which is deifne at .dts file line 679
         * p32[0] is the high 32 bits, p32[1] is the low 32 bits
         * for uart p32[0] = 0x0, p32[1] = 0xd4017000
         */
        uint64_t hi = bswap_32(p32[0]);
        uint64_t lo = bswap_32(p32[1]);
        return (uintptr_t)((hi << 32) | lo);
    }

    return (uintptr_t)bswap_32(p32[0]);
}

/*
 * dtb_load_initrd_addr - read linux,initrd-start from /chosen and store in
 * cpio_addr.  Must be called after dtb_set_addr().
 * The property is big-endian and may be 4 bytes (u32) or 8 bytes (u64).
 */
void dtb_load_initrd_addr(void)
{
    int len = 0;
    const void *prop = dtb_getprop("/chosen", "linux,initrd-start", &len);

    if (!prop || len == 0) {
        /* Property not found — leave cpio_addr as NULL */
        return;
    }

    if (len >= 8) {
        /* 64-bit big-endian value */
        const uint32_t *p = (const uint32_t *)prop;
        uint64_t hi = (uint64_t)bswap_32(p[0]);
        uint64_t lo = (uint64_t)bswap_32(p[1]);
        cpio_addr = (void *)(uintptr_t)((hi << 32) | lo);
    } else {
        /* 32-bit big-endian value */
        const uint32_t *p = (const uint32_t *)prop;
        cpio_addr = (void *)(uintptr_t)bswap_32(p[0]);
    }
}







uint64_t dtb_get_totalsize(void)
{
    if (!dtb_addr)
        return 0;
    struct fdt_header *header = (struct fdt_header *)dtb_addr;
    return bswap_32(header->totalsize);
}

void dtb_get_memory_region(uintptr_t *start, uint64_t *size)
{
    int len = 0;
    const void *prop = dtb_getprop("/memory", "reg", &len);
    if (!prop || len < 4) {
        *start = 0;
        *size = 0;
        return;
    }

    const uint32_t *p32 = (const uint32_t *)prop;
    if (len >= 16) {
        /* Usually #address-cells = 2, #size-cells = 2 */
        uint64_t s_hi = bswap_32(p32[0]);
        uint64_t s_lo = bswap_32(p32[1]);
        uint64_t len_hi = bswap_32(p32[2]);
        uint64_t len_lo = bswap_32(p32[3]);
        *start = (uintptr_t)((s_hi << 32) | s_lo);
        *size = (uint64_t)((len_hi << 32) | len_lo);
    } else if (len >= 8) {
        /* Assume #address-cells = 1, #size-cells = 1 for fallback */
        uint64_t s = bswap_32(p32[0]);
        uint64_t l_size = bswap_32(p32[1]);
        *start = (uintptr_t)s;
        *size = (uint64_t)l_size;
    } else {
        *start = 0;
        *size = 0;
    }
}

static int in_reserved_memory_node = 0;

static void reserved_memory_callback(uint32_t token, const char *name, const void *val)
{
    if (token == FDT_BEGIN_NODE) {
        if (node_name_match(name, "reserved-memory")) {
            in_reserved_memory_node = 1;
        }
    } else if (token == FDT_END_NODE) {
        if (in_reserved_memory_node) {
            /* If we just exited a node, we might have exited a subnode or reserved-memory itself.
             * Since FDT traversing goes in order, we can't reliably detect exiting reserved-memory
             * easily without keeping depth track. But we only need 'reg' within reserved-memory children.
             */
        }
    }
}


/* Because depth tracking inside dtb_traverse is a bit complex via callback,
 * let us implement a custom quick scan for /reserved-memory sub-nodes' "reg"
 * directly copying some logic from dtb_getprop.
 */
void dtb_find_and_reserve_memory(void)
{
    if (!dtb_addr)
        return;

    struct fdt_header *header = (struct fdt_header *)dtb_addr;
    if (bswap_32(header->magic) != FDT_HEADER_MAGIC)
        return;

    uint32_t struct_size = bswap_32(header->size_dt_struct);
    char *dt_struct = (char *)header + bswap_32(header->off_dt_struct);
    char *dt_strings = (char *)header + bswap_32(header->off_dt_strings);

    char *cur = dt_struct;
    char *struct_end = dt_struct + struct_size;

    int current_depth = -1;
    int reserved_memory_depth = -1;

    while (cur < struct_end) {
        uint32_t token = bswap_32(*(uint32_t *)cur);
        cur += 4;

        if (token == FDT_BEGIN_NODE) {
            const char *node_name = cur;
            while (*cur)
                cur++;
            cur++;
            cur = (char *)align_32((uint64_t)cur);

            current_depth++;

            if (reserved_memory_depth < 0) {
                if (current_depth == 1 && node_name_match(node_name, "reserved-memory")) {
                    reserved_memory_depth = current_depth;
                }
            }

        } else if (token == FDT_END_NODE) {
            if (reserved_memory_depth == current_depth)
                reserved_memory_depth = -1;
            current_depth--;

        } else if (token == FDT_PROP) {
            struct fdt_prop *prop = (struct fdt_prop *)cur;
            cur += sizeof(struct fdt_prop);

            uint32_t prop_len = bswap_32(prop->len);
            const char *name = dt_strings + bswap_32(prop->nameoff);
            const void *prop_val = cur;

            cur += prop_len;
            cur = (char *)align_32((uint64_t)cur);

            /* If we are inside /reserved-memory and at depth 2 (child of reserved-memory) */
            if (reserved_memory_depth >= 0 && current_depth == reserved_memory_depth + 1) {
                if (strcmp(name, "reg") == 0) {
                    const uint32_t *p32 = (const uint32_t *)prop_val;
                    if (prop_len >= 16) {
                        uint64_t s_hi = bswap_32(p32[0]);
                        uint64_t s_lo = bswap_32(p32[1]);
                        uint64_t len_hi = bswap_32(p32[2]);
                        uint64_t len_lo = bswap_32(p32[3]);
                        uint64_t r_start = (uintptr_t)((s_hi << 32) | s_lo);
                        uint64_t r_size = (uint64_t)((len_hi << 32) | len_lo);
                        memory_reserve(r_start, r_size);
                    } else if (prop_len >= 8) {
                        uint64_t s = bswap_32(p32[0]);
                        uint64_t l_size = bswap_32(p32[1]);
                        memory_reserve((uintptr_t)s, (uint64_t)l_size);
                    }
                }
            }

        } else if (token == FDT_NOP) {
            continue;
        } else if (token == FDT_END) {
            break;
        } else {
            break;
        }
    }
}