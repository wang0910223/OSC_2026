SECTIONS
{
    . = 0x00200000;
    _start = .;
    .text : { *(.text.boot) *(.text) }
    .rodata : { *(.rodata) }
    .data : { *(.data) }

    . = ALIGN(8);
    __bss_start = .;
    .bss : { *(.sbss) *(.bss) }
    __bss_end = .; 

    . = ALIGN(16);
    . += 0x4000;     /* reserve 16 KB for stack */
    __stack_top = .;
    _end = .;
}