#include "../include/cpio.h"
#include "../include/uart.h"
#include "../include/utils.h"
#include "../include/dtb.h"

#define CPIO_HEADER_SIZE 110  /* Fixed size of newc header */

/*
 * hex_to_ul - convert an ASCII hex string of exactly n chars to unsigned long.
 * Fields in cpio newc header are NOT null-terminated.
 */
static unsigned long hex_to_ul(const char *s, int n)
{
    unsigned long val = 0;
    int i;
    for (i = 0; i < n; i++) {
        char c = s[i];
        unsigned long digit;
        if      (c >= '0' && c <= '9') digit = (unsigned long)(c - '0');
        else if (c >= 'a' && c <= 'f') digit = (unsigned long)(c - 'a' + 10);
        else if (c >= 'A' && c <= 'F') digit = (unsigned long)(c - 'A' + 10);
        else                           digit = 0;
        val = (val << 4) | digit;
    }
    return val;
}

/* Round x up to nearest multiple of 4. */
static unsigned long align4(unsigned long x)
{
    return (x + 3) & ~3UL;
}

/* Simple strcmp for internal use (no libc). */
static int cpio_strcmp(const char *a, const char *b)
{
    while (*a && *b && *a == *b) { a++; b++; }
    return (unsigned char)*a - (unsigned char)*b;
}

/*
 * cpio_ls - iterate through the cpio archive and print every filename
 * with its size.  Stops at the "TRAILER!!!" end marker.
 * Output format:
 *   Total N files.
 *   <size>\t<name>
 */
void cpio_ls(void *cpio_addr)
{
    char *ptr;
    unsigned long count = 0;

    /* --- First pass: count entries (excluding TRAILER!!!) --- */
    ptr = (char *)cpio_addr;
    while (1) {
        struct cpio_newc_header *hdr = (struct cpio_newc_header *)ptr;

        if (hdr->c_magic[0] != '0' ||
            hdr->c_magic[1] != '7' ||
            hdr->c_magic[2] != '0' ||
            hdr->c_magic[3] != '7' ||
            hdr->c_magic[4] != '0') {
            uart_puts("[cpio] bad magic, stopping\n");
            return;
        }

        unsigned long namesize = hex_to_ul(hdr->c_namesize, 8);
        unsigned long filesize = hex_to_ul(hdr->c_filesize, 8);
        char *name = ptr + CPIO_HEADER_SIZE;

        if (cpio_strcmp(name, "TRAILER!!!") == 0)
            break;

        count++;
        ptr += align4(CPIO_HEADER_SIZE + namesize) + align4(filesize);
    }

    /* Print total */
    uart_puts("Total ");
    // print_dec_ulong(count);
    uart_dec((unsigned long)count);
    uart_puts(" files.\n");

    /* --- Second pass: print size + name for every entry --- */
    ptr = (char *)cpio_addr;
    while (1) {
        struct cpio_newc_header *hdr = (struct cpio_newc_header *)ptr;

        if (hdr->c_magic[0] != '0' ||
            hdr->c_magic[1] != '7' ||
            hdr->c_magic[2] != '0' ||
            hdr->c_magic[3] != '7' ||
            hdr->c_magic[4] != '0') {
            break;
        }

        unsigned long namesize = hex_to_ul(hdr->c_namesize, 8);
        unsigned long filesize = hex_to_ul(hdr->c_filesize, 8);
        char *name = ptr + CPIO_HEADER_SIZE;

        if (cpio_strcmp(name, "TRAILER!!!") == 0)
            break;

        // print_dec_ulong(filesize);
        uart_dec((unsigned long)filesize);
        uart_puts("\t");
        uart_puts(name);
        uart_puts("\n");

        ptr += align4(CPIO_HEADER_SIZE + namesize) + align4(filesize);
    }
}

/*
 * cpio_cat - find a file by name in the archive and print its content.
 * Prints an error if the file is not found.
 */
void cpio_cat(void *cpio_addr, const char *filename)
{
    char *ptr = (char *)cpio_addr;

    while (1) {
        struct cpio_newc_header *hdr = (struct cpio_newc_header *)ptr;

        /* Validate magic */
        if (hdr->c_magic[0] != '0' ||
            hdr->c_magic[1] != '7' ||
            hdr->c_magic[2] != '0' ||
            hdr->c_magic[3] != '7' ||
            hdr->c_magic[4] != '0') {
            uart_puts("[cpio] bad magic, stopping\n");
            break;
        }

        unsigned long namesize = hex_to_ul(hdr->c_namesize, 8);
        unsigned long filesize = hex_to_ul(hdr->c_filesize, 8);

        char *name = ptr + CPIO_HEADER_SIZE;

        /* End-of-archive marker */
        if (cpio_strcmp(name, "TRAILER!!!") == 0)
            break;

        unsigned long header_plus_name = align4(CPIO_HEADER_SIZE + namesize);

        if (cpio_strcmp(name, filename) == 0) {
            char *data = ptr + header_plus_name;
            unsigned long i;
            for (i = 0; i < filesize; i++)
                uart_putc((unsigned char)data[i]);
            /* Ensure output ends with newline */
            if (filesize == 0 || data[filesize - 1] != '\n')
                uart_puts("\n");
            return;
        }

        ptr += header_plus_name + align4(filesize);
    }

    uart_puts("cat: file not found: ");
    uart_puts((char *)filename);
    uart_puts("\n");
}
/** ----------------------------------------------------------------------
 * @brief cpio_find() – Locate a file inside an SVR4 newc cpio archive.
 *
 * Mirrors cpio_cat()'s traversal logic but, instead of printing, returns
 * a pointer to the payload and its size via out-parameters. The caller
 * is responsible for copying the bytes out before the archive is freed
 * or overwritten.
 * @param archive Base of the cpio blob.
 * @param target  NUL-terminated filename to look up.
 * @param data    Out: pointer to payload bytes inside the archive.
 * @param size    Out: payload size in bytes.
 * @return 0 on success, -1 otherwise.
 * -------------------------------------------------------------------- */
int cpio_find(const void *archive, const char *target,
              const void **data, unsigned long *size)
{
    if (!archive || !target || !data || !size) {
        return -1;
    }

    const char *ptr = (const char *)cpio_addr;
    while (1) {
        const struct cpio_newc_header *hdr = (const struct cpio_newc_header *)ptr;

        /* Validate magic */
        if (hdr->c_magic[0] != '0' ||
            hdr->c_magic[1] != '7' ||
            hdr->c_magic[2] != '0' ||
            hdr->c_magic[3] != '7') {
            uart_puts("[cpio] bad magic, stopping\n");
            break;
        }

        unsigned long namesize = hex_to_ul(hdr->c_namesize, 8);
        unsigned long filesize = hex_to_ul(hdr->c_filesize, 8);

        const char *filename = ptr + sizeof(struct cpio_newc_header);

        if (!strcmp(filename, "TRAILER!!!")) {
            return -1;
        }

        unsigned long file_data = align4((unsigned long)filename + namesize);

        if (!strcmp(filename, target)) {
            *data = (const void *)file_data;
            *size = filesize;
            return 0;
        }

        unsigned long next_hdr = align4(file_data + filesize);
        ptr = (const char *)next_hdr;
    }
    return -1;
}