#include "../include/uart.h"
#include "../include/utils.h"
#include "../include/sbi.h"

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
void command_unknown(){
    uart_puts("Unknown command: ");
    uart_puts(buffer);
    uart_puts("\nUse help to get commands.\n");    
}
void cmp_command(){
    if(!strcmp(buffer, "help")) command_help();
    else if(!strcmp(buffer, "hello")) command_hello();
    else if(!strcmp(buffer, "info")) command_info();
    
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