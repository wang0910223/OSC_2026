SECTIONS
{
    . = 0x80200000;
    _code_start = .;

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

    _code_end = .;
}

_code_size = _code_end - _code_start;