#ifndef DTH_H
#define DTH_H

typedef unsigned int uint32_t;
typedef unsigned long long uint64_t;
typedef unsigned long uintptr_t;

extern char *dtb_addr;
extern void *cpio_addr;

void dtb_initramfs_callback(uint32_t token_type, const char* name, 
                            const void* value);

void dtb_set_addr(void *addr);
uintptr_t dtb_get_reg(const char *path);
const void *dtb_getprop(const char *node_path, const char *prop_name,
                       int *lenp);
void dtb_load_initrd_addr(void);
uint64_t dtb_get_totalsize(void);
void dtb_get_memory_region(uintptr_t *start, uint64_t *size);
void dtb_find_and_reserve_memory(void);

#endif