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

/** ----------------------------------------------------------------------
 * @brief cpio_find() – Locate a file inside an SVR4 newc cpio archive.
 *
 * Walks the archive until TRAILER!!! is reached, comparing each entry
 * name with @target. On match, returns the payload pointer and size via
 * the out-parameters; on failure, leaves them untouched.
 * @param archive Base of the cpio blob (as passed by the bootloader).
 * @param target  NUL-terminated filename to look up.
 * @param data    Out: pointer to the file payload inside the archive.
 * @param size    Out: payload size in bytes.
 * @return 0 on success, -1 if not found or archive is invalid.
 * -------------------------------------------------------------------- */
int cpio_find(const void *archive, const char *target,
              const void **data, unsigned long *size);

              
#endif /* CPIO_H */
