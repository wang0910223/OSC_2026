#include "buddy.h"
#include "cpio.h"
#include "dtb.h"
#include "kmalloc.h"
#include "sbi.h"
#include "task.h"
#include "timer.h"
#include "trap.h"
#include "types.h"
#include "uart.h"
#include "utils.h"
#include "thread.h"

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
static void run_user_program(const char *name);

#define USER_STACK_SIZE (16 * 1024) /* 16 KiB user stack for prog.bin */

SPECIAL_CHAR parse(char c) {
	if (c > 127 || c < 0)
		return UNKNOWN;
	if (c == DELETE || c == BACK_SPACE)
		return DELETE;
	if (c == CARRIAGE_RETURN || c == LINE_FEED)
		return LINE_FEED;

	return REGULAR_INPUT;
}
void command_help() {
  uart_puts("help  - show all commands.\n");
  uart_puts("hello - print Hello World!\n");
  uart_puts("info  - print system info.\n");
  uart_puts("ls    - list files in initramfs.\n");
  uart_puts("cat   - display file content (usage: cat <filename>).\n");
  uart_puts("test  - run memory allocator test.\n");
  uart_puts("exec  - load a user program from initrd and run it in U-mode.\n");
  uart_puts("setTimeout - <sec> <msg> schedule a delayed message.\n");
  uart_puts("testTask - test task prioritization and preemption.\n");
  uart_puts("testThread - test thread creation and context switch.\n");
}
void command_hello() { uart_puts("Hello World!\n"); }
void command_info() {
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

void command_load() {
  unsigned int magic;
  unsigned int size;
  volatile unsigned char *dst;
  unsigned int i;

  uart_puts("Waiting for kernel over UART...\n");

  /* Read 8-byte header: magic (LE) + size (LE) */
  magic = (unsigned int)uart_getc() | ((unsigned int)uart_getc() << 8) |
          ((unsigned int)uart_getc() << 16) | ((unsigned int)uart_getc() << 24);
  size = (unsigned int)uart_getc() | ((unsigned int)uart_getc() << 8) |
         ((unsigned int)uart_getc() << 16) | ((unsigned int)uart_getc() << 24);

  if (magic != BOOT_MAGIC) {
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
void command_unknown() {
  uart_puts("Unknown command: ");
  uart_puts(buffer);
  uart_puts("\nUse help to get commands.\n");
}
void command_ls(void) {
  if (!cpio_addr) {
    uart_puts("Error: initrd not loaded.\n");
    return;
  }
  cpio_ls(cpio_addr);
}
void command_cat(void) {
  /* Find the filename after "cat " */
  const char *p = buffer;
  while (*p && *p != ' ')
    p++;            /* skip "cat" */
  if (*p == '\0') { /* command only "cat", without filename*/
    uart_puts("Usage: cat <filename>\n");
    return;
  }

  if (*p == ' ')
    p++;            /* skip the space */
  if (*p == '\0') { /* command only "cat ", without filename*/
    uart_puts("Usage: cat <filename>\n");
    return;
  }
  if (!cpio_addr) {
    uart_puts("Error: initrd not loaded.\n");
    return;
  }
  cpio_cat(cpio_addr, p);
}

void command_exec(void) {
  /* Find the filename after "cat " */
  const char *p = buffer;
  while (*p && *p != ' ')
    p++;            /* skip "cat" */
  if (*p == '\0') { /* command only "cat", without filename*/
    uart_puts("Usage: exec <filename>\n");
    return;
  }

  if (*p == ' ')
    p++;            /* skip the space */
  if (*p == '\0') { /* command only "cat ", without filename*/
    uart_puts("Usage: exec <filename>\n");
    return;
  }
  run_user_program(p);
}

static void command_test(void) {
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
  for (int i = 0; i < 100; i++) {
    kmem_ptr[i] = (char *)kmalloc(128);
  }
  for (int i = 0; i < 100; i++) {
    kfree(kmem_ptr[i]);
  }

  /* Test exceeding the maximum size */
  char *kmem_ptr7 = (char *)kmalloc(buddy_total_pages * PAGE_SIZE + 1);
  if (kmem_ptr7 == NULL) {
    uart_puts("Allocation failed as expected for size > MAX_ALLOC_SIZE\n");
  } else {
    uart_puts("Unexpected allocation success for size > MAX_ALLOC_SIZE\n");
    kfree(kmem_ptr7);
  }

  uart_puts("=== Memory allocation test done ===\n");
}

/** ----------------------------------------------------------------------
 * @brief byte_copy() – Tiny byte-wise memcpy used to load user programs.
 *
 * The kernel does not link against libc, so a minimal copy helper lives
 * here to stage prog.bin from the cpio archive into a kmalloc()'d buffer.
 * @param dst Destination buffer (must be writable).
 * @param src Source bytes (may overlap forbidden).
 * @param n   Number of bytes to copy.
 * -------------------------------------------------------------------- */
static void byte_copy(void *dst, const void *src, unsigned long n) {
  unsigned char *d = (unsigned char *)dst;
  const unsigned char *s = (const unsigned char *)src;
  while (n--) {
    *d++ = *s++;
  }
}

/** ----------------------------------------------------------------------
 * @brief run_user_program() – Load a file from initrd and drop into U-mode.
 *
 * Looks up @name inside the cpio archive, copies it into a fresh kmalloc
 * region sized for both the code and a 16 KiB user stack, then calls
 * enter_user_mode() which does not return. The shell regains control only
 * through a trap (printed by trap_handler) followed by sret back to the
 * program.
 * @param name Filename inside the initial ramdisk (e.g. "prog.bin").
 * -------------------------------------------------------------------- */
static void run_user_program(const char *name) {
  // parsing dtb to get initrd address
  const void *initrd =
      (const void *)dtb_getprop("/chosen", "linux,initrd-start", NULL);
  if (!initrd) {
    uart_puts("exec: initrd not found\n");
    return;
  }

  const void *src = NULL;
  unsigned long src_size = 0;

  // parsing cpio to find the file
  if (cpio_find(initrd, name, &src, &src_size) != 0) {
    uart_puts("exec: ");
    uart_puts((char *)name);
    uart_puts(": not found\n");
    return;
  }

  // allocate memory for user program
  unsigned long total = src_size + USER_STACK_SIZE;
  void *buf = kmalloc(total);
  if (!buf) {
    uart_puts("exec: out of memory\n");
    return;
  }
  byte_copy(buf, src, src_size);

  uintptr_t entry = (uintptr_t)buf;
  uintptr_t user_sp = ((uintptr_t)buf + total) & ~0xfUL;

  uart_puts("[exec] entry=");
  uart_hex(entry);
  uart_puts(" sp=");
  uart_hex(user_sp);
  uart_puts(" size=");
  uart_dec(src_size);
  uart_puts("\n");

  trap_set_user_base(entry);
  enter_user_mode(entry, user_sp);
}

struct timeout_arg {
  int duration_sec;
  unsigned long exec_time;
  char msg[128]; // max buffer limit of shell
};

static void timeout_cb(void *arg) {
  struct timeout_arg *targ = (struct timeout_arg *)arg;
  unsigned long current_time = get_cycles() / get_timer_freq();

  uart_puts("\n[setTimeout] ");
  uart_puts(targ->msg);
  uart_puts("\n - Set at: ");
  uart_dec(targ->exec_time);
  uart_puts("s\n - Now: ");
  uart_dec(current_time);
  uart_puts("s\n - Expected delay: ");
  uart_dec(targ->duration_sec);
  uart_puts("s\n");

  kfree(targ);
}

void command_setTimeout(void) {
  const char *p = buffer;
  while (*p && *p != ' ')
    p++;
  if (*p == '\0') {
    uart_puts("Usage: setTimeout <seconds> <message>\n");
    return;
  }
  p++; // skip space
  while (*p == ' ')
    p++;

  int sec = 0;
  if (!(*p >= '0' && *p <= '9')) {
    uart_puts("Usage: setTimeout <seconds> <message>\n");
    return;
  }
  while (*p >= '0' && *p <= '9') {
    sec = sec * 10 + (*p - '0');
    p++;
  }

  if (*p != ' ') {
    uart_puts("Usage: setTimeout <seconds> <message>\n");
    return;
  }
  while (*p == ' ')
    p++; // skip space

  if (*p == '\0') {
    uart_puts("Usage: setTimeout <seconds> <message>\n");
    return;
  }

  struct timeout_arg *arg =
      (struct timeout_arg *)kmalloc(sizeof(struct timeout_arg));
  if (!arg) {
    uart_puts("kmalloc failed for setTimeout\n");
    return;
  }

  arg->duration_sec = sec;
  arg->exec_time = get_cycles() / get_timer_freq();

  int i = 0;
  while (*p && i < 127) {
    arg->msg[i++] = *p++;
  }
  arg->msg[i] = '\0';

  add_timer(timeout_cb, arg, sec);
}

static void test_task_cb(void *arg) {
  uart_puts("[Task] Executing Priority ");
  uart_puts((char *)arg);
  uart_puts("\n");
}

void command_testTask(void) {
  uart_puts("Queueing priority tasks (1, 5, 3)...\n");
  add_task(test_task_cb, "1", 1);
  add_task(test_task_cb, "5", 5);
  add_task(test_task_cb, "3", 3);

  /* They will be executed in priority order: 5 -> 3 -> 1 */
  uart_puts("Tasks queued! Running them now:\n");
  run_tasks();
}

static void high_prio_task_cb(void *arg) {
    uart_puts("\n[10] start\n");
}

static void timer_trigger_cb(void *arg) {
    uart_puts("\n--- [10] insert  ---\n");
    add_task(high_prio_task_cb, NULL, 10);
}
static void delay_sec(int sec) {
    unsigned long target = get_cycles() + sec * get_timer_freq();
    while (get_cycles() < target) {
    }
}
static void low_prio_task_cb(void *arg) {
    uart_puts("\n[low] start\n");
    
    add_timer(timer_trigger_cb, NULL, 2);

    delay_sec(4);

    uart_puts("\n[low] end\n");
}
void command_testNest(void) {
	uart_puts("=== Nested interrupt test start ===\n");

	// 先把低優先權任務丟進去
	add_task(low_prio_task_cb, NULL, 1);

	// 開始執行 Bottom Half
	run_tasks();

	uart_puts("\n=== Nested interrupt test end ===\n");
}

void cmp_command() {
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
  else if (buffer[0] == 'c' && buffer[1] == 'a' && buffer[2] == 't' &&
           (buffer[3] == ' ' || buffer[3] == '\0'))
    command_cat();
  else if (buffer[0] == 'e' && buffer[1] == 'x' && buffer[2] == 'e' &&
           buffer[3] == 'c' && (buffer[4] == ' ' || buffer[4] == '\0'))
    command_exec();
  else if (buffer[0] == 's' && buffer[1] == 'e' && buffer[2] == 't' &&
           buffer[3] == 'T' && buffer[4] == 'i' && buffer[5] == 'm' &&
           buffer[6] == 'e' && buffer[7] == 'o' && buffer[8] == 'u' &&
           buffer[9] == 't' && (buffer[10] == ' ' || buffer[10] == '\0'))
    command_setTimeout();
  else if (!strcmp(buffer, "testTask"))
    command_testTask();
  else if (!strcmp(buffer, "testNest"))
    command_testNest();
  else if (!strcmp(buffer, "testThread"))
    test_threads();
  else
    command_unknown();
}

void put_char(SPECIAL_CHAR s, char c) {
  switch (s) {
  case DELETE:
    if (buf_len > 0)
      buf_len--;
    uart_puts("\b \b");
    break;

  case LINE_FEED:
    uart_putc('\n');

    if (buf_len == BUFFER_SIZE)
      uart_puts("The command being entered is too long to process.\n");
    else {
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

void shell() {

  char c;
  SPECIAL_CHAR s;
  uart_puts("opi-rv2> ");

  // for continue receive new char
  while (1) {
    c = uart_getc();
    s = parse(c);
    put_char(s, c);
  }
}