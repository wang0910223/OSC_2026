## Basic Exercise 1 - UART Bootloader - 30%
Implement a load command in the shell to receive the kernel image over UART, allowing the shell to act as a convenient interface for development.

To avoid overwriting itself, the bootloader should load the new kernel into a different memory address like 0x20000000 (or 0x82000000 on QEMU) and jump to it.
- How to make sure it is a safe address to load the new kernel on it?
  - It can be checked on the device tree. We should check the address is for DRAM and not included in the `reserved-memory`

### kernel/src/shell.c
Implement the load command to load the new kernel onto the predefined load address
``` c
#ifdef QEMU
#define KERNEL_LOAD_ADDR 0x80200000UL
#else
#define KERNEL_LOAD_ADDR 0x00200000UL
#endif // QEMU
...

void command_load()
{
    unsigned int magic;
    unsigned int size;
    volatile unsigned char *dst;
    unsigned int i;

    uart_puts("Waiting for kernel over UART...\n");

    /* Read 8-byte header: magic (LE) + size (LE) */
    magic = (unsigned int)uart_getc() | ((unsigned int)uart_getc() << 8) | ((unsigned int)uart_getc() << 16) | ((unsigned int)uart_getc() << 24);
    size = (unsigned int)uart_getc() | ((unsigned int)uart_getc() << 8) | ((unsigned int)uart_getc() << 16) | ((unsigned int)uart_getc() << 24);

    if (magic != BOOT_MAGIC)
    {
        uart_puts("Invalid header (bad magic).\n");
        return;
    }

    dst = (volatile unsigned char *)KERNEL_LOAD_ADDR;
    for (i = 0; i < size; ++i)
        dst[i] = uart_getc_raw();

    uart_puts("Loaded ");
    uart_dec((unsigned long)size);
    uart_puts(" bytes, jumping to ");
    uart_hex((unsigned long)dst);
    uart_puts("...\n");

    /* Flush the data to be written to memory and invalidate instruction cache before jumping to new executable memory */
    __asm__ volatile("fence.i");

    /* Jump to loaded kernel; do not return. */
    extern int boot_hart_id;
    extern char *dtb_addr;
    ((void (*)(int, void *))dst)(boot_hart_id, dtb_addr);
}

```

### kernel/send_kernel.py  (partial)
``` python
    # read kernel image
    with open(path, "rb") as f:     # "path" is the path to the kernel.bin to be transmitted; "rb" means read binary
        kernel_data = f.read()
    size = len(kernel_data)
    header = struct.pack("<II", BOOT_MAGIC, size) # "struct pack" is a module to turn python variables into binary format
                                                  # "<II": "<" stands for little endian, "II" means there are two integers to be packed

    # send kernel image
    with open(dev, "wb", buffering=0) as tty:  # "buffering=0" means bypass system buffer, directly write to the device
        tty.write(header)
        tty.write(kernel_data)
    print(f"Sent {size} bytes (header + kernel) to {dev}")
```

## Basic Exercise 2 - Devicetree - 35%
You should parse the flattened devicetree and provide an interface to query the devicetree for device information. 

### src/dtb.c
```
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
            /* Get the node name, which is a null-terminated string */
            const char *node_name = cur;
            while (*cur)
                cur++;
            cur++;
            cur = (char *)align_32((uint64_t)cur);  // the name is followed by zeroed padding bytes, if necessary for alignment

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
            // FDT_PROP token marks the beginning of the representation of one property in the devicetree.
            // It shall be followed by "fdt_prop" struct to describe the property.
            struct fdt_prop *prop = (struct fdt_prop *)cur;
            /* let cur point to the property data */
            cur += sizeof(struct fdt_prop);

            uint32_t prop_len = bswap_32(prop->len);  // the "len" in fdt_prop gives the length of the property’s value in bytes
            const char *name = dt_strings + bswap_32(prop->nameoff);  // the "nameoff" in fdt_prop gives an offset into the strings block
                                                                      // at which the property’s name is stored as a null-terminated string

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
```


