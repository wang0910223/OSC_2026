#ifndef UART_H
#define UART_H

void uart_putc(unsigned int c);
char uart_getc();
// void uart_init();
void uart_puts(char *s);
void uart_hex(unsigned long h);

#endif
