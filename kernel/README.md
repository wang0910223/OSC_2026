### sstatus 暫存器是做什麼的？
sstatus 的全名是 Supervisor Status Register。你可以把它想像成是 CPU 在 S-mode（特權模式）下的**「狀態控制面板」**。

它裡面記錄了 CPU 現在的特權等級、中斷是開還是關，以及發生中斷「前」的歷史紀錄。  
當系統發生 Trap（中斷或例外）時，硬體會自動把當下的狀態備份到 sstatus 裡面的某些 bit；而當我們處理完中斷要「返回」時，硬體又會去讀取這些 bit 來恢復狀態。

- 為什麼要改第 8 個 Bit (SPP)？它原本是多少？
它的全名：SPP (Supervisor Previous Privilege)，意思是「之前的特權等級」。

    - 當 SPP = 0 時，代表之前是 U-mode (User)。

    - 當 SPP = 1 時，代表之前是 S-mode (Supervisor)。

會在哪裡用到？
當你執行 sret (Supervisor Return) 指令時，CPU 必須決定「我現在要返回哪一個模式？」。CPU 怎麼知道呢？它就是去讀取 sstatus 的 SPP bit。如果讀到 0 就切換成 U-mode，讀到 1 就繼續留在 S-mode。

我們把它修改成 0 就是為了 sret 回 U-mode



3. 為什麼要改第 5 個 Bit (SPIE)？它原本是多少？
它的全名：SPIE (Supervisor Previous Interrupt Enable)，意思是「之前的中斷開啟狀態」。

當 SPIE = 0 時，代表之前中斷是關閉的。

當 SPIE = 1 時，代表之前中斷是開啟的。

會在哪裡用到？
sstatus 裡面還有另一個掌管「現在」中斷總開關的 bit，叫做 SIE (Supervisor Interrupt Enable, 第 1 個 bit)。
當你執行 sret 返回時，硬體會做一個自動覆蓋的動作：SIE = SPIE（把「之前」的狀態覆蓋給「現在」的狀態）。

它原本是多少？為什麼要改？
在執行 enter_user_mode 之前，你可能正在 Kernel 裡面做一些初始化，為了安全，那時候的總中斷很可能是關閉的（或者狀態未知），所以 SPIE 原本可能是 0。
如果我們不把它強制設為 1 (csrs sstatus, t0)，當 sret 執行時，它會把 0 複製給 SIE。結果就是：你的使用者程式雖然成功在 U-mode 跑起來了，但它的中斷總開關是關閉的！ 這樣一來，你的 Core Timer 響了 CPU 聽不到，鍵盤輸入了 CPU 也收不到，系統就跟死機沒兩樣。


## trap_entry.S
`.align n` 的意思是接下來的程式碼在記憶體中的位址對齊到 $2^n$ Bytes  
`.align 2` 代表對齊到 $2^2 =$ 4 Bytes  
因為指令至少對齊 4 bytes，也就是最後兩個 bit 一定是 0 ，所以 `stvec` 這個暫存器前 30 (or 62) 個 bits 用來表示 vector 的 address `BASE` ，最後兩個 bits 用來表示模式：  
1. `00`: direct mode，所有的 Exception 和 Interrupt，無論原因為何，CPU 都會把 PC 直接指向 BASE 的位址。在進入 trap_entry 後，由軟體去讀取 scause 暫存器，用程式邏輯來判斷到底是誰觸發了 Trap
2. `01`: vectored mode，Exception 一樣會跳到 BASE；但 Interrupt 發生時，硬體會自動幫你計算位址，跳轉到 BASE + (4 * cause) 的地方。也就是硬體幫你做好分支了，你可以為每一個中斷寫一個獨立的進入點。
也就是說 `stvec` 在找 vector address 時是不會看最後兩個 bits 的 (會直接塡零)，所以我們程式碼如果沒有對齊 4 bytes 讓最後兩個 bits 是 0 的話， CPU 進入 trap 時就會找錯位置


---
# Basic 2 

## timer.c
``` c
void core_timer_enable(void) {
    // 1. Set the STIE bit in the sie register to enable timer interrupts.
    asm volatile("csrs sie, %0" ::"r"(SIE_STIE));

    // Start the periodic boot time timer using software timer multiplexer
    add_timer(boot_time_cb, NULL, 2);
}
```
- `sie` register 是 CPU 在 S-mode 管理中斷來源的獨立開關
    - SIE_STIE (Supervisor Timer Interrupt Enable) 就是專屬於 timer 的中斷開關（通常是第 5 個 bit）。
- `csrs` (CSR Set) 指令的作用是「把指定的 bit 設為 1，其他 bit 保持原本的狀態」

實際意義：你透過這行指令告訴硬體：「從現在起允許 Core Timer 的中斷訊號送進 CPU。」

``` c
void add_timer(timer_callback_t callback, void *arg, int sec) {
    ...

	/* Critical section start */
	unsigned long saved_sstatus;
	asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));
	...

	/* Critical section end */
	// 把中斷開關恢復成剛才備份的狀態
	asm volatile("csrs sstatus, %0" ::"r"(saved_sstatus & 2));
}
```
- Critical section start
    - `csrrci`: Control and Status Register Read and Clear Immediate（讀取並立即清除 CSR）。
        - 這是一個 Atomic Operation，也就是讀取和清除會在同一個瞬間完成。
    - `sstatus`: 目標暫存器（Supervisor 狀態暫存器）
    - `2`: 2 換算成二進位是 0010，也就是第一個 bit (從 0 開始算)
        - 在 RISC-V 規格中，sstatus[1] 就是 SIE (Supervisor Interrupt Enable，中斷總開關)
    - `"=r"`: Output Operand

    這行指令的意思是：把 sstatus 的舊值讀出來存入`saved_sstatus`，然後立刻把 SIE bit 設為 0（關閉全域中斷）。
- Critical section end
    - `csrs`: Control and Status Register Set  (傳進來的 bit 是 1，就把 CSR 裡面的對應 bit 設為 1；如果是 0，就不做任何事)
    - `"r"(saved_sstatus & 2)`: 輸入運算元。它拿出了剛剛備份的變數並 & 2 ，也就是只取出原始的 `SIE bit` 的狀態並 set 回 `sstatus`   
    
    這行指令的意思是：如果剛才備份的 SIE 狀態是開的，就把中斷重新打開；如果剛才本來就是關的，就繼續保持關閉。

- 為何不直接用 `asm volatile("csrs sstatus, 2")` 開啟 SIE
    - 如果是在 trap_handler 裡面呼叫了 add_timer()，全域中斷卻被 add_timer() 意外打開，此時如果有其他硬體訊號進來，Kernel Stack 會被瘋狂嵌套打斷，暫存器狀態會徹底大亂。所以應該根據原始狀態來還原，而非直接打開中斷


``` c
void add_timer(timer_callback_t callback, void *arg, int sec) {
    ...
	if (!timer_head || new_event->expire_cycles < timer_head->expire_cycles) {
		...
		sbi_set_timer(timer_head->expire_cycles);  
	} 
	...
}

static void boot_time_cb(void *arg) {
    ...
    add_timer(boot_time_cb, NULL, 2);
}

void core_timer_handler(void) {
  /* Process all expired timers */
  while (timer_head && timer_head->expire_cycles <= get_cycles()) {
    ...

    if (event->callback) {
      event->callback(event->arg);
    }
    ...
  }

  /* Reprogram the next timer interrupt if there's any pending event */
  if (timer_head) 
    sbi_set_timer(timer_head->expire_cycles);
  ...
}
```
- add_timer 中的 `sbi_set_timer()`  
    - 負責「插隊 / 提前喚醒」
- core_timer_handler 中的 `sbi_set_timer()`
    - 負責「交接棒 / 設定下一班」
- 兩個 function 都 call `sbi_set_timer()`，會重複嗎？
    - 有可能會 (特別是兩秒一次這個情境)！但不需要修  
        sbi_set_timer 的底層操作，只是把一個 64-bit 的數字寫入 CPU 的暫存器裡。這是一個極度快速的操作   
        把同一個數字（2秒後）連續寫進去兩次，硬體的結果是一模一樣的，完全不會影響正確性。  
        如果你為了省下這一次寫入暫存器的動作，而試圖在 add_timer 和 core_timer_handler 之間傳遞各種全域變數或 Flag 來判斷「剛剛有沒有設定過」，那會讓程式碼變得極度複雜，而且在多核心（Multi-core）環境下還會引發可怕的 Race Condition（競爭危害）。

## plic.c
``` c
void plic_init(void)
{
    int ctx = get_current_s_context();

    // 單純幫 UART 設定 priority
    plic_write32(PLIC_PRIORITY(UART0_IRQ), 1);

    // 讓 current context 可以收到 UART interrupt
    unsigned long enable_reg = PLIC_ENABLE(ctx) + (UART0_IRQ / 32) * 4;
    uint32_t enable_bits = plic_read32(enable_reg);
    enable_bits |= (1 << (UART0_IRQ % 32));
    plic_write32(enable_reg, enable_bits);

    // 讓 current context 可以收到 priotiry 大於 0 的所有 interrupt
    plic_write32(PLIC_THRESHOLD(ctx), 0);
}
```
- `enable_reg = PLIC_ENABLE(ctx) + (UART0_IRQ / 32) * 4;`）    
    - PLIC_ENABLE(ctx) 
        - `#define PLIC_ENABLE(ctx) (PLIC_BASE + 0x2000 + (ctx) * 0x80)`
        - `0x2000` 是 PLIC 開始存放 enable 開關的 offest  (根據 RISC-V PLIC spec)
        - `(ctx) * 0x80`
            - `ctx` 是 current context
            - `0x80` 是每個 context enable 開關大小，128 bytes 剛好是 1024 個 bit，RISC-V 的 PLIC 規格最多支援 1024 個硬體中斷（IRQ 0 ~ 1023）
    - `(UART0_IRQ / 32)`
        - PLIC 的 enable 暫存器是 32 個 IRQ 為一組，每組 4 bytes
        - `(UART0_IRQ / 32)` 決定了要操作哪一個 4-byte 的暫存器
    - `* 4`
        - 每個 enable 暫存器是 4 bytes
- `enable_bits |= (1 << (UART0_IRQ % 32));`
    - `(UART0_IRQ % 32)` 決定了要操作哪一個 bit

``` c
#define PLIC_THRESHOLD(ctx)  (PLIC_BASE + 0x200000 + (ctx) * 0x1000)
#define PLIC_CLAIM(ctx)      (PLIC_BASE + 0x200004 + (ctx) * 0x1000)
```
- `PLIC_BASE + 0x200000` PLIC 的記憶體地圖中，前 2MB 是用來放所有中斷的優先權 (Priority) 和開關 (Enable) 的
- `(ctx) * 0x1000` 換算成十進位是 4KB。為每一個 Context 都劃分了整整 4KB 的空間 (a page size)

- `PLIC_THRESHOLD(ctx)` threshold 暫存器位在該 Context 專屬 4KB 空間的正起點 (Offset 0x00)
    - 用來設定這顆 CPU 的接收底線，如果寫入 3，那麼 PLIC 就會幫把優先權小於或等於 3 的中斷全部擋下來，只有優先權 4 以上的緊急中斷才能打斷這顆 CPU。
- `PLIC_CLAIM(ctx)` 在 threshold 暫存器隔壁，所以 offset 多加 4
    - 特殊的雙向 (讀/寫行為不同)暫存器，完美對應了中斷處理的「一借一還」協議：
    - 當你讀取它 (Read = Claim 領取)
        - 當 CPU 被外部中斷打斷，跳進 Trap Handler 時，CPU 其實不知道是誰按了門鈴
        - 這時 CPU 去「讀取」這個位址，PLIC 就會回傳目前優先權最高且正在等待處理的 IRQ 號碼
        - 讀取的這個瞬間，PLIC 會自動在內部把這個 IRQ 號碼標記為 `Claimed`，暫停發送該中斷的新訊號
    - 當你寫入它 (Write = Complete 結案)
        - 當你的驅動程式（例如 UART Handler）把收到的字元處理完畢後，你必須把剛剛拿到的 IRQ 號碼「寫回」這個一模一樣的位址。
        - 這個動作告訴 PLIC：「10 號案件我處理完了！」
        - PLIC 收到結案通知後，就會解除該中斷的鎖定。如果該硬體還有後續的訊號，PLIC 就可以再次去敲 CPU 的門了。

## uart.c
``` c
void uart_intr_enable(void) {
    /* Enable RX Interrupt (Bit 0). We leave TX interrupt (Bit 1) disabled
     * until we actually have data to send. */
    async_tx_enabled = 1;
    *UART_IER |= (1 << 0);
    *UART_MCR |= (1 << 3);
}
```
- `UART_IER`: UART 晶片內部專門管中斷的控制面板 (Interrupt Enable Register)
    - 第 0 個 bit 叫做 ERBFI (Enable Received Data Available Interrupt)
    - 功能：只要在鍵盤上敲了一個字元，並且這個字元已經抵達的 UART RX Buffer 就立刻產生一個內部中斷
- 為何沒開 TX interrupt?
    - TX 中斷邏輯是：「只要我的 TX biffer 是空的，我就發出中斷跟你要資料」，如果現在沒有字串要印，卻把 TX 中斷打開，UART 就會發中斷。
    - 所以標準做法是：只有當你真的有字串要送時，才短暫打開 TX 中斷；送完最後一個字元，就立刻把它關掉。
- `UART_MCR`: Modem Control Register
    - Bit 3 叫做 `OUT2`，`OUT2` 是一道物理閘門。即使在上一步打開了 `IER`，UART 晶片確實會在內部產生中斷訊號，但是！ 如果 OUT2 是關閉的（0），這個中斷訊號會被鎖在 UART 晶片內部，根本傳不出去

## main.c
``` c
asm volatile("csrs sie, %0" :: "r"(SIE_SEIE));   
asm volatile("csrs sstatus, %0" :: "r"(SSTATUS_SIE));   
```
- `SIE_SEIE`: 第九個 bit，代表打開 PLIC 的外部中斷
- `sstatus`: 這是管理 CPU 在 S-mode 下整體運作狀態的核心暫存器
    - `SSTATUS_SIE` (Supervisor Interrupt Enable)：第 1 個 bit。它是整個系統的中斷總開關
        - 在執行這行之前，就算打開了 Timer、打開了 External，所有訊號依然都會被擋在門外。執行這行指令的瞬間，總電源正式接通，CPU 瞬間「活」了過來，開始會被各種中斷打斷！
- 為何要分 `sie` `sstatus` 兩個開關？
    - 為了 Critical Section 的效能與安全
    - 當需要短暫且緊急地不被打擾時，你只需要關掉總開關 (sstatus.SIE = 0)。此時，你的 sie 暫存器（局部開關）裡面的設定（Timer 是開的、External 是開的）全部都會被完好地保留著！等你修改完指標，再次把總開關打開 (sstatus.SIE = 1)，CPU 就會立刻恢復剛才的狀態，繼續接收 Timer 和 External 中斷。


## task.c
``` c
void run_tasks(void)
{
    while (1) {
        /* Safely check the task list */
        unsigned long saved_sstatus;
        asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

        // 判斷是否要插隊的邏輯
        // 如果一個新的 task 插進來並且呼叫 run_task，執行到這行時會檢查這個新的 task 跟剛剛跑到一半的 task (current_priority) 誰的 priority高
        // 如果新的 priority 小就會進入這個 if conditionl，恢覆中斷狀態 (結束 critical section)並且 break 出去回到原本在跑的地方
        // 還有如果現在 task queue是空的也會走這邊的邏輯，恢復狀態並 break
        if (!task_head || task_head->priority <= current_priority) {
            /* No more tasks, or tasks are of lower/equal priority 
               than the one we are already handling. Wait for it. */
            asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
            break;
        }

        // 取出 task 並且更新 current_priority
        struct task *curr = task_head;
        task_head = task_head->next;
        int prev_priority = current_priority;
        current_priority = curr->priority;



        /* Enable global interrupts to allow nested interrupts and higher-priority preemption */
        // 在執行任務前，主動把全域中斷打開。允許 task 執行中仍可以收到新的中斷
        asm volatile("csrs sstatus, 2");

        if (curr->callback) {
            curr->callback(curr->arg);
        }

        /* Disable global interrupts to wrap up */
        // 任務執行完畢了。我們要準備收拾善後（修改變數），所以再次暴力關閉全域中斷，確保收拾過程不被打擾
        asm volatile("csrc sstatus, 2");

        current_priority = prev_priority;
        kfree(curr);

        /* Restore original interrupt state for the while loop evaluation */
        asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
    }
}

```




### Q&A
- About **context**
一個 Context 代表一個可以獨立接收中斷的實體目標
Context 數量 = CPU 核心數 (Harts) × 該核心支援的特權模式 (Modes)
    - OS 如何知道有幾個 context
        - 查手冊，Hardcoded
        - 解析 Device Tree 找 `interrupts-extended` 屬性
            - interrupts-extended = <0x10 0x0b 0x10 0x09 0x11 0x0b 0x11 0x09 0x12 0x0b 0x12 ...
            - 第一組 <0x10 0x0b>：Hart 0, M-mode (0x0b 代表 11，RISC-V 規定 11 是 M-mode External Interrupt) $\rightarrow$ Context 0
            - 第二組 <0x10 0x09>：Hart 0, S-mode (0x09 代表 9，RISC-V 規定 9 是 S-mode External Interrupt) $\rightarrow$ Context 1
            - 第三組 <0x11 0x0b>：Hart 1, M-mode $\rightarrow$ Context 2