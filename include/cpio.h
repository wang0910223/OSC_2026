#ifndef CPIO_H
#define CPIO_H

typedef unsigned int uint32_t;
typedef unsigned long long uint64_t;
typedef unsigned long uintptr_t;

/*
 * New ASCII Format cpio header (always exactly 110 bytes).
 * All numeric fields are ASCII hex strings (no null terminator).
 * Ref: https://man.freebsd.org/cgi/man.cgi?query=cpio&sektion=5
 */
struct cpio_newc_header {
    char c_magic[6];       /* "070701" */
    char c_ino[8];
    char c_mode[8];
    char c_uid[8];
    char c_gid[8];
    char c_nlink[8];
    char c_mtime[8];
    char c_filesize[8];
    char c_devmajor[8];
    char c_devminor[8];
    char c_rdevmajor[8];
    char c_rdevminor[8];
    char c_namesize[8];
    char c_check[8];
};

void cpio_ls(void *cpio_addr);
void cpio_cat(void *cpio_addr, const char *filename);

#endif /* CPIO_H */
