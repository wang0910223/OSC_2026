#ifdef QEMU
    #define UART_BASE_DEFAULT 0x10000000UL
#else
    #define UART_BASE_DEFAULT 0xD4017000UL
#endif

static volatile unsigned long g_uart_base = 0;

void uart_set_base(unsigned long base)
{
    if (base)
        g_uart_base = base;
}

#define UART_BASE g_uart_base



#ifdef QEMU
    #define UART_RBR  (unsigned char*)(UART_BASE + 0x0)
    #define UART_THR  (unsigned char*)(UART_BASE + 0x0)
    #define UART_LSR  (unsigned char*)(UART_BASE + 0x5)
    #define LSR_DR    (1 << 0)
    #define LSR_TDRQ  (1 << 5)

    #define UART_IER    ((volatile unsigned char*)(UART_BASE + 0x01)) // Interrupt Enable (QEMU 是 +1)
    #define UART_FCR    ((volatile unsigned char*)(UART_BASE + 0x02)) // FIFO Control (QEMU 是 +2)
    #define UART_LCR    ((volatile unsigned char*)(UART_BASE + 0x03)) // Line Control (QEMU 是 +3)
    #define UART_MCR    ((volatile unsigned char*)(UART_BASE + 0x04))

#else
    #define UART_THR    ((volatile unsigned int*)(UART_BASE + 0x00)) // Transmit Holding 
    #define UART_RBR    ((volatile unsigned int*)(UART_BASE + 0x00)) // Receiver Buffer  
    #define UART_LSR    ((volatile unsigned int*)(UART_BASE + 0x14)) // Line Status Register

    #define UART_IER  ((volatile unsigned int*)(UART_BASE + 0x04)) 
    #define UART_FCR  ((volatile unsigned int*)(UART_BASE + 0x08)) 
    #define UART_LCR  ((volatile unsigned int*)(UART_BASE + 0x0C))
    #define UART_MCR  ((volatile unsigned int*)(UART_BASE + 0x10))

    #define LSR_DR    (1 << 0)
    #define LSR_TDRQ  (1 << 5)
#endif



/* ----------------------------------------------------------------------- */
/* Async UART ring buffers and interrupts                                  */
/* ----------------------------------------------------------------------- */
#define UART_RX_BUF_SIZE 256
static char rx_buf[UART_RX_BUF_SIZE];
static volatile int rx_head = 0, rx_tail = 0;

#define UART_TX_BUF_SIZE 256
static char tx_buf[UART_TX_BUF_SIZE];
static volatile int tx_head = 0, tx_tail = 0;

static volatile int async_tx_enabled = 0;

void uart_intr_enable(void) {
    /* Enable RX Interrupt (Bit 0). We leave TX interrupt (Bit 1) disabled
     * until we actually have data to send. */
    async_tx_enabled = 1;
    *UART_IER |= (1 << 0);
    *UART_MCR |= (1 << 3);
}

void uart_interrupt_handler(void) {
    /* 1. Check RX: if Data is Ready */
    if (*UART_LSR & LSR_DR) {
        char c = (char)*UART_RBR;
        int next_head = (rx_head + 1) % UART_RX_BUF_SIZE;
        if (next_head != rx_tail) { /* Drop byte if buffer full */
            rx_buf[rx_head] = c;
            rx_head = next_head;
        }
    }

    /* 2. Check TX: if Transmit Holding Register is Empty (ready for next byte) */
    if (*UART_LSR & LSR_TDRQ) {
        if (tx_head != tx_tail) {
            /* We have data, send it! */
            *UART_THR = tx_buf[tx_tail];
            tx_tail = (tx_tail + 1) % UART_TX_BUF_SIZE;
        } else {
            /* Buffer is empty, so disable TX interrupts!
             * Otherwise we will infinitely trap. */
            *UART_IER &= ~(1 << 1);
        }
    }
}

/**
 * Send character into TX Ring Buffer and trigger TX Interrupts
 * Falls back to synchronous polling before uart_intr_enable() is called.
 */
void uart_putc(unsigned int c) {
    if (c == '\n') uart_putc('\r');

    /* Before async is ready: use safe polling mode */
    if (!async_tx_enabled) {
        while ((*UART_LSR & LSR_TDRQ) == 0);
        *UART_THR = c;
        return;
    }
    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

    int next_head = (tx_head + 1) % UART_TX_BUF_SIZE;
    while (next_head == tx_tail) {
        /* Buffer is full: wait. Re-enable interrupts while waiting so TX ISR can execute */
        asm volatile("csrs sstatus, 2");
        asm volatile("wfi");
        asm volatile("csrc sstatus, 2");
    }

    tx_buf[tx_head] = c;
    tx_head = next_head;

    /* Turn on TX interrupt (Bit 1) because we now have data to send */
    *UART_IER |= (1 << 1);

    /* Exit Critical Section */
    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
}

/**
 * Receive character from RX Ring Buffer
 */
char uart_getc_raw(void) {
    char c;
    /* Wait until buffer has data */
    while (rx_head == rx_tail) {
        asm volatile("wfi");
    }

    /* Enter Critical Section */
    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

    c = rx_buf[rx_tail];
    rx_tail = (rx_tail + 1) % UART_RX_BUF_SIZE;

    /* Exit Critical Section */
    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
    
    return c;
}

char uart_getc(void) {
    char c = uart_getc_raw();
    return c == '\r' ? '\n' : c;
}

/**
 * Display a string
 */
void uart_puts(char *s) {
    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));
    
    while (*s) {
        uart_putc((unsigned int)*s++);
    }
    
    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
}

void uart_hex(unsigned long h) {
    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

    uart_puts("0x");
    unsigned long n;
    for (int c = 60; c >= 0; c -= 4) {
        n = (h >> c) & 0xf;
        n += n > 9 ? 0x57 : '0';
        uart_putc(n);
    }

    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
}

void uart_dec(unsigned long x) {
    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

    char buf[32];
    int i = 0;

    if (x == 0) {
        uart_putc('0');
        goto done;
    }

    while (x > 0 && i < (int)sizeof(buf)) {
        buf[i++] = (char)('0' + (x % 10));
        x /= 10;
    }

    while (i > 0) {
        uart_putc((unsigned char)buf[--i]);
    }

done:
    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
}