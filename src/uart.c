#ifdef QEMU
    #define UART_BASE 0x10000000UL
    #define UART_RBR  (unsigned char*)(UART_BASE + 0x0)
    #define UART_THR  (unsigned char*)(UART_BASE + 0x0)
    #define UART_LSR  (unsigned char*)(UART_BASE + 0x5)
    #define LSR_DR    (1 << 0)
    #define LSR_TDRQ  (1 << 5)

    #define UART_IER    ((volatile unsigned char*)(UART_BASE + 0x01)) // Interrupt Enable (QEMU 是 +1)
    #define UART_FCR    ((volatile unsigned char*)(UART_BASE + 0x02)) // FIFO Control (QEMU 是 +2)
    #define UART_LCR    ((volatile unsigned char*)(UART_BASE + 0x03)) // Line Control (QEMU 是 +3)

#else
    #define UART_BASE  0xD4017000UL
    #define UART_THR    ((volatile unsigned int*)(UART_BASE + 0x00)) // Transmit Holding 
    #define UART_RBR    ((volatile unsigned int*)(UART_BASE + 0x00)) // Receiver Buffer  
    #define UART_LSR    ((volatile unsigned int*)(UART_BASE + 0x14)) // Line Status Register

    #define UART_IER    ((volatile unsigned int*)(UART_BASE + 0x04)) // Interrupt Enable
    #define UART_FCR    ((volatile unsigned int*)(UART_BASE + 0x08)) // FIFO Control
    #define UART_LCR    ((volatile unsigned int*)(UART_BASE + 0x0C))

    /* LSR bits */
    #define LSR_DR      (1 << 0)  // Data Ready (有資料可讀取)
    #define LSR_TDRQ    (1 << 5)  // Transmit Holding Register Empty (發送區已空)
#endif

/**
 * Diaplay a character
 */
void uart_putc(unsigned int c) {
    if(c == '\n')
        uart_putc('\r');
    // Wait until there's no data in the transmit buffer
    while ((*UART_LSR & LSR_TDRQ) == 0);

    

    *UART_THR = c;
}

/**
 * Receive a character from host
 */
char uart_getc() {
    // Wait until there's data in the receive buffer
    while ((*UART_LSR & LSR_DR) == 0);

    // get data from reciever buffer register
    char c = (char)*UART_RBR;

    // To ensure output sequence can display normaly, we replace '\r' with '\n'
    return c == '\r' ? '\n' : c;
}

/**
 * Display a string
 */
void uart_puts(char *s) {
    while (*s) {
        uart_putc((unsigned int)*s++);
    }
}

void uart_hex(unsigned long h) {
    uart_puts("0x");
    unsigned long n;
    for (int c = 60; c >= 0; c -= 4) {
        n = (h >> c) & 0xf;
        n += n > 9 ? 0x57 : '0';
        uart_putc(n);
    }
}