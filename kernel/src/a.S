.section ".text"
_start:
  la t0, __bss_start
  la t1, __bss_end
_clear_bss:
  bge t0, t1, _bss_done
  sd zero, 0(t0)
  addi t0, t0, 8
  j _clear_bss
_bss_done:
  la sp, __stack_top
  call main
  