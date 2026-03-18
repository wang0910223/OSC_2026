#include "../include/uart.h"
#include "../include/utils.h"
#include "../include/sbi.h"
#include "../include/dtb.h"
#include "../include/cpio.h"
#define BOOT_MAGIC 0x544F4F42UL

#ifdef QEMU
#define KERNEL_LOAD_ADDR 0x82000000UL
#else
#define KERNEL_LOAD_ADDR 0x20000000UL
#endif // QEMU


typedef enum {
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

SPECIAL_CHAR parse(char c){
    if(c > 127 || c < 0) return UNKNOWN;
    if(c == DELETE || c == BACK_SPACE) return DELETE;
    if(c == CARRIAGE_RETURN || c == LINE_FEED) return LINE_FEED;

    return REGULAR_INPUT;
}
void command_help(){
    uart_puts("help  - show all commands.\n");
    uart_puts("hello - print Hello World!\n");
    uart_puts("info  - print system info.\n");
    uart_puts("ls    - list files in initramfs.\n");
    uart_puts("cat   - display file content (usage: cat <filename>).\n");
}
void command_hello(){
    uart_puts("Hello World!\n");
}
void command_info(){
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

static void print_hex_ulong(unsigned long x)
{
    char buf[2 * sizeof(unsigned long)];
    int i;

    for (i = (int)(sizeof(unsigned long) * 2) - 1; i >= 0; --i) {
        unsigned long nibble = x & 0xFUL;
        if (nibble < 10UL) {
            buf[i] = (char)('0' + nibble);
        } else {
            buf[i] = (char)('a' + (nibble - 10UL));
        }
        x >>= 4;
    }

    for (i = 0; i < (int)(sizeof(unsigned long) * 2); ++i) {
        uart_putc((unsigned char)buf[i]);
    }
}

static void print_dec_ulong(unsigned long x)
{
    char buf[32];
    int i = 0;

    if (x == 0) {
        uart_putc('0');
        return;
    }

    while (x > 0 && i < (int)sizeof(buf)) {
        buf[i++] = (char)('0' + (x % 10));
        x /= 10;
    }

    while (i > 0) {
        uart_putc((unsigned char)buf[--i]);
    }
}

void command_load(){
    unsigned int magic;
    unsigned int size;
    volatile unsigned char *dst;
    unsigned int i;

    uart_puts("Waiting for kernel over UART...\n");

    /* Read 8-byte header: magic (LE) + size (LE) */
    magic = (unsigned int)uart_getc()
            | ((unsigned int)uart_getc() << 8)
            | ((unsigned int)uart_getc() << 16)
            | ((unsigned int)uart_getc() << 24);
    size = (unsigned int)uart_getc()
           | ((unsigned int)uart_getc() << 8)
           | ((unsigned int)uart_getc() << 16)
           | ((unsigned int)uart_getc() << 24);

    if (magic != BOOT_MAGIC) {
        uart_puts("Invalid header (bad magic).\n");
        return;
    }

    dst = (volatile unsigned char *)KERNEL_LOAD_ADDR;
    for (i = 0; i < size; ++i)
        dst[i] = uart_getc_raw();

    uart_puts("Loaded ");
    print_dec_ulong((unsigned long)size);
    uart_puts(" bytes, jumping to ");
    uart_hex((unsigned long)dst);
    uart_puts("...\n");

    /* On real hardware, the stores above may still be in D-cache.
     * fence   : wait for all outstanding stores to complete (data ordering)
     * fence.i : synchronize I-cache with D-cache so the CPU fetches the
     *           newly written kernel instructions, not stale cache lines.
     * QEMU has no real cache, so this is a no-op there but necessary on board. */
    // __asm__ volatile ("fence\n\tfence.i" ::: "memory");

    /* Jump to loaded kernel; do not return. */
    // ((void (*)())dst)();
    extern int boot_hart_id;
    extern char *dtb_addr;
    ((void (*)(int, void *))dst)(boot_hart_id, dtb_addr);


}
void command_unknown(){
    uart_puts("Unknown command: ");
    uart_puts(buffer);
    uart_puts("\nUse help to get commands.\n");    
}
void command_ls(void) {
    if (!CPIO_DEFAULT_ADDR) {
        uart_puts("Error: initrd not loaded.\n");
        return;
    }
    cpio_ls(CPIO_DEFAULT_ADDR);
}
void command_cat(void) {
    /* Find the filename after "cat " */
    const char *p = buffer;
    while (*p && *p != ' ') p++;  /* skip "cat" */
    if (*p == ' ') p++;           /* skip the space */
    if (*p == '\0') {
        uart_puts("Usage: cat <filename>\n");
        return;
    }
    if (!CPIO_DEFAULT_ADDR) {
        uart_puts("Error: initrd not loaded.\n");
        return;
    }
    cpio_cat(CPIO_DEFAULT_ADDR, p);
}
void cmp_command(){
    if(!strcmp(buffer, "help")) command_help();
    else if(!strcmp(buffer, "hello")) command_hello();
    else if(!strcmp(buffer, "info")) command_info();
    else if(!strcmp(buffer, "load")) command_load();
    else if(!strcmp(buffer, "ls")) command_ls();
    else if(buffer[0]=='c' && buffer[1]=='a' && buffer[2]=='t' && buffer[3]==' ') command_cat();
    else command_unknown();
}


void put_char(SPECIAL_CHAR s, char c){
    switch(s){
        case DELETE:
            if(buf_len > 0) buf_len--;
            uart_puts("\b \b");
            break;

        case LINE_FEED:
            uart_putc('\n');

            if(buf_len == BUFFER_SIZE)
                uart_puts("The command being entered is too long to process.\n");
            else{
                buffer[buf_len] = '\0';
                cmp_command();
            }
            
            buf_len = 0;
            memset(buffer, 0, BUFFER_SIZE);
            uart_puts("opi-rv2> ");
            break;
            
        case REGULAR_INPUT:
            if(buf_len < BUFFER_SIZE) 
                buffer[buf_len++] = c;
            uart_putc(c);
            break;

        default:
            break;
    }
    return;
}

void shell(){
    
    char c;
    SPECIAL_CHAR s;
    uart_puts("opi-rv2> ");

    // for continue receive new char
    while(1){
        c = uart_getc();
        s = parse(c);
        put_char(s, c);
    }

}