#include "uart.h"
#include "utils.h"
#include "sbi.h"
#include "dtb.h"
#include "cpio.h"
#include "buddy.h"
#include "types.h"
#define BOOT_MAGIC 0x544F4F42UL

#ifdef QEMU
#define KERNEL_LOAD_ADDR 0x82000000UL
#else
#define KERNEL_LOAD_ADDR 0x20000000UL
#endif // QEMU

typedef enum
{
    BACK_SPACE = 8,
    LINE_FEED = 10,
    CARRIAGE_RETURN = 13,
    DELETE = 127,
    UNKNOWN = 512,
    REGULAR_INPUT = 513,
} SPECIAL_CHAR;

#define BUFFER_SIZE 128
static char buffer[BUFFER_SIZE];
static int buf_len = 0;

SPECIAL_CHAR parse(char c)
{
    if (c > 127 || c < 0)
        return UNKNOWN;
    if (c == DELETE || c == BACK_SPACE)
        return DELETE;
    if (c == CARRIAGE_RETURN || c == LINE_FEED)
        return LINE_FEED;

    return REGULAR_INPUT;
}
void command_help()
{
    uart_puts("help  - show all commands.\n");
    uart_puts("hello - print Hello World!\n");
    uart_puts("info  - print system info.\n");
    uart_puts("ls    - list files in initramfs.\n");
    uart_puts("cat   - display file content (usage: cat <filename>).\n");
    uart_puts("test  - run memory allocator test.\n");
}
void command_hello()
{
    uart_puts("Hello World!\n");
}
void command_info()
{
    struct sbires res;

    res = sbi_ecall(0x10, 0x0, 0, 0, 0, 0, 0, 0);
    uart_puts("OpenSBI specification version: ");
    uart_hex(res.value);

    res = sbi_ecall(0x10, 0x1, 0, 0, 0, 0, 0, 0);
    uart_puts("\nImplementation ID: ");
    uart_hex(res.value);

    res = sbi_ecall(0x10, 0x2, 0, 0, 0, 0, 0, 0);
    uart_puts("\nImplementation version: ");
    uart_hex(res.value);
    uart_putc('\n');
}

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
    // print_dec_ulong((unsigned long)size);
    uart_dec((unsigned long)size);
    uart_puts(" bytes, jumping to ");
    uart_hex((unsigned long)dst);
    uart_puts("...\n");

    /* Jump to loaded kernel; do not return. */
    extern int boot_hart_id;
    extern char *dtb_addr;
    ((void (*)(int, void *))dst)(boot_hart_id, dtb_addr);
}
void command_unknown()
{
    uart_puts("Unknown command: ");
    uart_puts(buffer);
    uart_puts("\nUse help to get commands.\n");
}
void command_ls(void)
{
    if (!cpio_addr)
    {
        uart_puts("Error: initrd not loaded.\n");
        return;
    }
    cpio_ls(cpio_addr);
}
void command_cat(void)
{
    /* Find the filename after "cat " */
    const char *p = buffer;
    while (*p && *p != ' ')
        p++; /* skip "cat" */
    if (*p == '\0')
    { /* command only "cat", without filename*/
        uart_puts("Usage: cat <filename>\n");
        return;
    }

    if (*p == ' ')
        p++; /* skip the space */
    if (*p == '\0')
    { /* command only "cat ", without filename*/
        uart_puts("Usage: cat <filename>\n");
        return;
    }
    if (!cpio_addr)
    {
        uart_puts("Error: initrd not loaded.\n");
        return;
    }
    cpio_cat(cpio_addr, p);
}

static void command_test(void)
{
    uart_puts("Testing memory allocation...\n");

    /* Page-level allocations (> MAX_CHUNK_SIZE → buddy) */
    char *ptr1 = (char *)kmalloc(4000);
    char *ptr2 = (char *)kmalloc(8000);
    char *ptr3 = (char *)kmalloc(4000);
    char *ptr4 = (char *)kmalloc(4000);

    kfree(ptr1);
    kfree(ptr2);
    kfree(ptr3);
    kfree(ptr4);

    /* Chunk-level allocations */
    uart_puts("Testing dynamic allocator...\n");
    char *kmem_ptr1 = (char *)kmalloc(16);
    char *kmem_ptr2 = (char *)kmalloc(32);
    char *kmem_ptr3 = (char *)kmalloc(64);
    char *kmem_ptr4 = (char *)kmalloc(128);
    char *kmem_ptr5 = (char *)kmalloc(16);
    char *kmem_ptr6 = (char *)kmalloc(32);

    kfree(kmem_ptr1);
    kfree(kmem_ptr2);
    kfree(kmem_ptr3);
    kfree(kmem_ptr4);
    kfree(kmem_ptr5);
    kfree(kmem_ptr6);

    /* Test allocate new page if the cache is not enough */
    void *kmem_ptr[102];
    for (int i = 0; i < 100; i++)
    {
        kmem_ptr[i] = (char *)kmalloc(128);
    }
    for (int i = 0; i < 100; i++)
    {
        kfree(kmem_ptr[i]);
    }

    /* Test exceeding the maximum size */
    char *kmem_ptr7 = (char *)kmalloc(TOTAL_PAGES * PAGE_SIZE + 1);
    if (kmem_ptr7 == NULL)
    {
        uart_puts("Allocation failed as expected for size > MAX_ALLOC_SIZE\n");
    }
    else
    {
        uart_puts("Unexpected allocation success for size > MAX_ALLOC_SIZE\n");
        kfree(kmem_ptr7);
    }

    uart_puts("=== Memory allocation test done ===\n");
}

void cmp_command()
{
    if (!strcmp(buffer, "help"))
        command_help();
    else if (!strcmp(buffer, "hello"))
        command_hello();
    else if (!strcmp(buffer, "info"))
        command_info();
    else if (!strcmp(buffer, "load"))
        command_load();
    else if (!strcmp(buffer, "ls"))
        command_ls();
    else if (!strcmp(buffer, "test"))
        command_test();
    else if (buffer[0] == 'c' && buffer[1] == 'a' && buffer[2] == 't' && (buffer[3] == ' ' || buffer[3] == '\0'))
        command_cat();
    else
        command_unknown();
}

void put_char(SPECIAL_CHAR s, char c)
{
    switch (s)
    {
    case DELETE:
        if (buf_len > 0)
            buf_len--;
        uart_puts("\b \b");
        break;

    case LINE_FEED:
        uart_putc('\n');

        if (buf_len == BUFFER_SIZE)
            uart_puts("The command being entered is too long to process.\n");
        else
        {
            buffer[buf_len] = '\0';
            cmp_command();
        }

        buf_len = 0;
        memset(buffer, 0, BUFFER_SIZE);
        uart_puts("opi-rv2> ");
        break;

    case REGULAR_INPUT:
        if (buf_len < BUFFER_SIZE)
            buffer[buf_len++] = c;
        uart_putc(c);
        break;

    default:
        break;
    }
    return;
}

void shell()
{

    char c;
    SPECIAL_CHAR s;
    uart_puts("opi-rv2> ");

    // for continue receive new char
    while (1)
    {
        c = uart_getc();
        s = parse(c);
        put_char(s, c);
    }
}