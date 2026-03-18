#ifndef UART_H
#define UART_H

void uart_init(void *dtb_addr);
void uart_set_base(unsigned long base);
char uart_getc_raw();

void uart_putc(unsigned int c);
char uart_getc();
void uart_puts(char *s);
void uart_hex(unsigned long h);

#endif
