# Lab 5
## Basic Exercise 1
### thread.c
實做 thread 概念，並且使用 scheduler 進行 Round-Robin 排程
- `test_threads()`
    ``` c
    void test_threads() {
        uart_puts("Testing threads...\n");
        struct task_struct *idle_thread = thread_create(idle);
        asm volatile("mv tp, %0" : : "r"(idle_thread));
        
        for (int i = 0; i < 3; i++) {
            thread_create(foo);
        }
        idle();
    }
    ```
    - `thread_create(idle)`
        - 建立第一個thread (idle thread)，必須把它的位址塞進 `tp`，後續的 `get_current()` 以及 `switch_to()` 才能抓到正確的指標，不會引發 Error
        - `mv tp, %0`
            - 把 idle thread 的位址塞進 `tp` register，也算是宣告現在正在跑的就是 idle thread
            - 在執行這行程式碼之前，CPU 雖然正在跑 kernel，但對於排程器來說，它不屬於任何一個 Thread，這行程式碼賦予它一個 thread 的身份
    - idle thread
        - 會不斷跑 `kill_zombies()` 以及 `schedule()` 這兩個 function，也就是負責排程和 release 已經跑完的 thread 的空間

- `get_current()`   
    ``` c
    struct task_struct* get_current() {
        register struct task_struct* current asm("tp");
        return current;
    }
    ```
    - RISC-V 架構中，`tp` (Thread Pointer) register 通常用來儲存正在執行的 `task_struct` 記憶體位址，只要讀取 `tp` 就能知道現在是誰在執行。
    - 宣告 current 這個變數，並讓它永遠對應到 CPU 的 tp register。
- `schedule()`
    - 實作 Round-Robin 排程，找出下一個非 zombie 的 thread 並 switch to the nexrt thread
    - `enqueue()` 有將這個 `run_queue` 實作成為一個 circular linked list 的結構，初始時便將 `task->next` 指向自己，且 queue 中永遠有 idle thread ，所以這個 queue 不會是空的。
- `thread_exit()`
    ``` c
    void thread_exit() {
        struct task_struct* current = get_current();
        current->state = THREAD_ZOMBIE;
        schedule();
        while (1);  // Just in case accidentally return
    }
    ```
    - 標記當前 thread 為 zombie 並呼叫 `schedule()`
    - 執行 thread_exit 時，thread 仍然使用自己的 Stack，如果它把自己釋放了，下一秒 CPU 取出指令或存取區域變數時，就會 error，所以這邊只讓 thread 把自己的狀態改成 zombie 並呼叫 scheduler，後續 idle thread 會負責 call `kill_zombies()` 來釋放 thread 的記憶體空間
- `kill_zombies()`
    - 釋放 zombie thread 的記憶體空間
- `switch_to()`
    - 實做 context switch 的概念，會將 current thread 的 callee-saved register 都存到 current thread 的 task_struct 裡面，並把 next thread 的 callee-saved register 都從 next thread 的 task_struct 裡面 load 出來
    - 這邊 caller-saved register 會由 C-compiler 自動存入，不需手動存入。再回到這個 thread 時也會自動 load 回 register 內

目前系統是 Cooperative 的，也就是說 thread 必須主動寫出 `schedule()` (類似 `yield()` 的概念)才能交出控制權
而且目前的 thread 都是 kernel thread，產生的 thread 並沒有進行 user-mode switch

