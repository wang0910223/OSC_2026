#include "../include/uart.h"
#include "../include/shell.h"

void main(){

    // uart_init();
    uart_puts("\nKernel Starting...\n");

    shell();


    // while(1){
    //     uart_putc(uart_getc());
    // }
    return;
}