SECTIONS
{
    . = 0xffffffc000000000;
    . += 0x80200000;
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