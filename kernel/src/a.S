.section ".text.boot"
.global _start
_start:
    /* Save hart_id (a0) and dtb_ptr (a1) to s0 and s1 */
    /* setup_vm is a C function and might clobber caller-saved registers */
    mv s0, a0
    mv s1, a1

    /* Load early stack pointer (PA) */
    la sp, __stack_top

    /* Clear BSS using PA */
    la t0, __bss_start
    la t1, __bss_end
_clear_bss:
    bge t0, t1, _bss_done
    sd zero, 0(t0)
    addi t0, t0, 8
    j _clear_bss
_bss_done:

    /* Call setup_vm to enable MMU */
    call setup_vm

    /* Calculate the high VA of label 1 */
    la a2, 1f
    li t0, 0xffffffc000000000
    add a2, a2, t0
    
    /* Jump to high VA */
    jr a2

.align 2
1:
    /* Now in the higher half */
    /* Reload sp with the high VA */
    la sp, __stack_top

    /* Restore hart_id and dtb_ptr */
    mv a0, s0
    mv a1, s1

    /* Jump to main */
    tail main