/*
 * trap_entry.S – S-mode trap vector and U-mode entry helper.
 *
 * The trap vector uses the sscratch CSR to distinguish the two trap
 * sources during Basic Ex1:
 *   - sscratch != 0 : trap was taken from U-mode; sscratch holds the
 *                     kernel sp that enter_user_mode() stashed. Swap
 *                     it with the current (user) sp to run on the
 *                     kernel stack.
 *   - sscratch == 0 : trap was taken while the kernel was already
 *                     running. Ex1 does not expect this path; the
 *                     fallback halts the kernel.
 */

#include "trap.h"

.section .text.trap, "ax"

.globl trap_entry
.align 2                            /* stvec direct mode: 4-byte aligned */
trap_entry:
    /* Swap sp with sscratch so sp points at the kernel stack. */
    /* 把 sp 換成存在 sscratch 中的 kernel stack */
    csrrw sp, sscratch, sp
    beqz  sp, .Lfrom_kernel   /* 如果 sscratch 裡面是 0 代表 nested trap，跳到對應處理 label */

.Lsave_context:
    /* Reserve a trap_frame on the kernel stack and save GPRs. */
    addi  sp, sp, -TF_SIZE    /* 在 Stack 往下開一個 256 bytes 的空間，存所有暫存器的值 */

    sd    x1,  TF_RA(sp)      /* store 所有 trap 發生當下的暫存器值到 kernel stack 上保存 */
    sd    x3,  TF_GP(sp)
    sd    x4,  TF_TP(sp)
    sd    x5,  TF_T0(sp)
    sd    x6,  TF_T1(sp)
    sd    x7,  TF_T2(sp)
    sd    x8,  TF_S0(sp)
    sd    x9,  TF_S1(sp)
    sd    x10, TF_A0(sp)
    sd    x11, TF_A1(sp)
    sd    x12, TF_A2(sp)
    sd    x13, TF_A3(sp)
    sd    x14, TF_A4(sp)
    sd    x15, TF_A5(sp)
    sd    x16, TF_A6(sp)
    sd    x17, TF_A7(sp)
    sd    x18, TF_S2(sp)
    sd    x19, TF_S3(sp)
    sd    x20, TF_S4(sp)
    sd    x21, TF_S5(sp)
    sd    x22, TF_S6(sp)
    sd    x23, TF_S7(sp)
    sd    x24, TF_S8(sp)
    sd    x25, TF_S9(sp)
    sd    x26, TF_S10(sp)
    sd    x27, TF_S11(sp)
    sd    x28, TF_T3(sp)
    sd    x29, TF_T4(sp)
    sd    x30, TF_T5(sp)
    sd    x31, TF_T6(sp)

    /* sscratch currently holds the user sp captured at entry. */
    csrr  t0, sscratch    # 把剛剛存在 sscratch 裡的 sp 讀出來
    sd    t0, TF_SP(sp)   # 把 sp push 進 trap frame

    /* Mark "currently in kernel" for any nested trap check later. */
    csrw  sscratch, zero  

    /* Save the four supervisor CSRs that describe the trap. */
    csrr  t0, sepc
    csrr  t1, sstatus
    csrr  t2, scause
    csrr  t3, stval
    sd    t0, TF_SEPC(sp)
    sd    t1, TF_SSTATUS(sp)
    sd    t2, TF_SCAUSE(sp)
    sd    t3, TF_STVAL(sp)

    /* Dispatch to C. */
    mv    a0, sp
    call  trap_handler
.globl _ret_from_fork
_ret_from_fork:
    /* Restore sepc / sstatus (scause / stval are read-only on return). */
    ld    t0, TF_SEPC(sp)
    ld    t1, TF_SSTATUS(sp)
    csrw  sepc, t0
    csrw  sstatus, t1

    /* Restore general-purpose registers (x2/sp handled specially). */
    ld    x1,  TF_RA(sp)
    ld    x3,  TF_GP(sp)
    ld    x4,  TF_TP(sp)
    ld    x5,  TF_T0(sp)
    ld    x6,  TF_T1(sp)
    ld    x7,  TF_T2(sp)
    ld    x8,  TF_S0(sp)
    ld    x9,  TF_S1(sp)
    ld    x10, TF_A0(sp)
    ld    x11, TF_A1(sp)
    ld    x12, TF_A2(sp)
    ld    x13, TF_A3(sp)
    ld    x14, TF_A4(sp)
    ld    x15, TF_A5(sp)
    ld    x16, TF_A6(sp)
    ld    x17, TF_A7(sp)
    ld    x18, TF_S2(sp)
    ld    x19, TF_S3(sp)
    ld    x20, TF_S4(sp)
    ld    x21, TF_S5(sp)
    ld    x22, TF_S6(sp)
    ld    x23, TF_S7(sp)
    ld    x24, TF_S8(sp)
    ld    x25, TF_S9(sp)
    ld    x26, TF_S10(sp)
    ld    x27, TF_S11(sp)
    ld    x28, TF_T3(sp)
    ld    x29, TF_T4(sp)
    ld    x30, TF_T5(sp)
    ld    x31, TF_T6(sp)

    /* Load saved sp into t0 before freeing the frame, 
       then check SPP in sstatus to decide sscratch value. */
    ld    t0, TF_SP(sp)     # load trap 前的 sp 進 t0 
    ld    t1, TF_SSTATUS(sp)
    addi  sp, sp, TF_SIZE   # 釋放 Trap Frame 空間


    /* 檢查 SPP (sstatus 的第 8 個 bit) */
    li    t2, (1 << 8)
    and   t2, t1, t2
    bnez  t2, .Lret_to_s    # 如果 SPP 是 1 (不為 0)，代表要返回 S-mode

    /* CPU 準備執行 sret 回去，所以需要決定 sscratch 該設定成什麼 
     * 若 SPP = 1  -> Smode  (sscratch 設為 0)
     * 若 SPP = 0  -> Smode  (sscratch 設為 kernel stack)
     */
.Lret_to_u:
    csrw  sscratch, sp
    j     .Lfinish_ret

.Lret_to_s:
    csrw  sscratch, zero

.Lfinish_ret:
    mv    sp, t0   # 把 trap 前的 sp 存回 sp，sret 回去
    sret

.Lfrom_kernel:
    /*
     * Trap occurred while the kernel was already running.
     * Restore sp, keep a copy in sscratch temporarily so .Lsave_context
     * can pick it up correctly.
     */
    csrrw sp, sscratch, sp   /* 再交換一次 sp, sscratch，讓 sp 指向 kernel stack */
    csrw  sscratch, sp       /* 把 kernel sp 也存到 sscratch，下次 trap 回來時 sscratch 裡面就會是正確的位置 */
    j     .Lsave_context     /* 回到一般的 save context flow */


/* ------------------------------------------------------------------ */
/* enter_user_mode(entry = a0, user_sp = a1)                          */
/* ------------------------------------------------------------------ */
.globl enter_user_mode
.align 2
enter_user_mode:
    /* Remember the current kernel sp for the eventual U→S trap. */
    /* 當前 Kernel sp 備份到 sscratch 這個 S-mode 專用的暫存器裡 當 user mode 發生中斷進入 s mode 時可以將 sp 換回來*/
    csrw  sscratch, sp

    /* Program the return PC. spec (Supervisor Exception Program Counter) */
    /* 執行返回指令時，會執行 spec 中的位置 */
    csrw  sepc, a0

    /* Clear SPP bit (sstatus[8]) so sret returns to U-mode. */
    /* sstatus 暫存器裡的第 8 個 bit 是 SPP (Supervisor Previous Privilege) */
    /* csrc 會把這個 bit 清 0。代表前一個狀態是處於 U-mode (0)，稍後的返回指令就會把權限降級成 U-mode */
    li    t0, (1 << 8)
    csrc  sstatus, t0


    /* Set SPIE bit (sstatus[5]) so SIE becomes 1 after sret. */
    /* sstatus 暫存器裡的第 5 個 bit 是 SPIE (Supervisor Interrupt Enable) */
    /* csrs 會把這個 bit 設為 1。代表進入 U-mode後允許中斷 */
    li    t0, (1 << 5)
    csrs  sstatus, t0

    /* Switch to the user stack and clear argument registers to avoid
     * leaking kernel state into U-mode. */
    mv    sp, a1
    li    a0, 0
    li    a1, 0
    li    a2, 0
    li    a3, 0
    li    a4, 0
    li    a5, 0
    li    a6, 0
    li    a7, 0
    li    t0, 0
    li    t1, 0
    li    t2, 0
    li    t3, 0
    li    t4, 0
    li    t5, 0
    li    t6, 0

    /* sret 會做三件事：
     * 讀取 sstatus 的 SPP，發現是 0，於是把當前 CPU 權限拔除降為 U-mode。
     * 把 sstatus 的 SPIE 複製給 SIE，開啟中斷。
     * 讀取 sepc 的位址，把 PC 指向那裡，開始執行user program */
    sret
