#ifndef DTH_H
#define DTH_H

typedef unsigned int uint32_t;
typedef unsigned long long uint64_t;
typedef unsigned long uintptr_t;

typedef void (*dtb_callback)(uint32_t token_type, const char* name, 
                             const void* value);

extern void *cpio_addr;

void dtb_traverse(dtb_callback callback);
void dtb_initramfs_callback(uint32_t token_type, const char* name, 
                            const void* value);

void dtb_set_addr(void *addr);
uintptr_t dtb_get_reg(const char *path);
const void *dtb_getprop(const char *node_path, const char *prop_name,
                       int *lenp);
void dtb_load_initrd_addr(void);

#endif