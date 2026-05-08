# Lab 5
## Basic Exercise 1 (after basic 3)
開機進入 `main()` 後會 call `thread_create()` 幫 idle thread 建立一個 task_structure 並將這個 structure 的 address 塞入 `tp`
- 也就是把現在這個 thread 直接變成 idle thread 的意思。

接下來在 `main()` 中還會建立一個 kernel shell thread，也就是把原本的 kernel shell 也包成一個 thread。

然後當前這個 thread 就會開始跑 `idle()` function, 正式開始執行 idle thread 的工作。

idle thread 的用意＆功能
- 一個永遠處於可執行狀態的 thread 。當系統中沒有其他可執行的 thread時，scheduler 就會挑選它，以保證 CPU 永遠會執行下一條指令
- 必須把它的 task_structure 塞進 `tp`，後續的 `get_current()` 以及 `switch_to()` 才能抓到正確的指標，不會引發 Error
- 不斷跑 `kill_zombies()` 以及 `schedule()` 這兩個 function，也就是負責排程和 release 已經跑完的 thread 的空間




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
    - 這邊 caller-saved register 會由 C-compiler 在 function call 前自動插入一段除存的 code 存入，不需手動存入。再回到這個 thread 時也會自動 load 回 register 內

目前系統是 Cooperative 的，也就是說 thread 必須主動寫出 `schedule()` (類似 `yield()` 的概念)才能交出控制權
而且目前的 thread 都是 kernel thread，產生的 thread 並沒有進行 user-mode switch


## Basic Exercise 2 
實做 user process 和提供 system call 供 user program 使用。

### user process Implementation
![image](https://hackmd.io/_uploads/HybiZSGA-g.png)
在 kernel shell 執行 `exec` 後會 call `run_user_program()` 這個 function。

`run_user_program()` 會 call `user_program_execute()` ，這邊就完成了建立 user thread 和將此 thread 加入 `run_queue` 的動作了，待 scheduler 選到這個 thread 後就會開始執行。

此時 kernel shell 這個 thread 會呼叫 `do_waitpid()` 等到 user thread 結束才會回來執行 kernel shell。
#### `call user_program_execute()` 任務如下：
- Parse `dtb` to find the binary file to be execute
- Allocate memory for the file (binary file size + user stack size) and copy the file content to its memory space
- Call `thread_create()` to create thread for this user program 
    - 會將 `user_program_start()` 這個 functino 當參數傳入 `thread_create()` ，
    - 而 `user_program_start()` 會 call `enter_user_mode()` 並傳入 user program address 跟 user stack address

#### `thread_create()` 任務如下：
``` c
struct task_struct* thread_create(void (*threadfn)()) {
    struct task_struct* task = kmalloc(sizeof(struct task_struct));
    task->pid = nr_threads++;
    task->ppid = 0;
    task->state = THREAD_RUNNING;
    task->stack = (unsigned long)kmalloc(STACK_SIZE);
    task->thread.ra = (unsigned long)threadfn;
    task->thread.sp = task->stack + STACK_SIZE;
    enqueue(&run_queue, task);
    return task;
}
```
- Allocate a `task_struct` for the thread and fill the information into the struct
    -  `task->stack` : user thread's kernel stack (each user thread has their own kernel stack)
    -  `task->thread.ra`: In `switch_to()` function, after context switch, the PC will point to the address `task->thread.ra` point to
        -  **Here, we set it to `user_program_start()` function**, this funtion will call `enter_user_mode()` to switch to user mode and `sret` to the start address of the user program .
    -  `task->thread.sp`: point to the user thread's kernel stack (i.e., `task->stack`)
-  `enqueue()`: Add this thread to the `run_queue`, waiting for being scheduled.

### system call Implementation
user program 呼叫 system call 的流程：
1. 將參數填入指定 registers (`a0`, `a1`, ...)
2. 將 system call number 填入 `a7` 
3. call `ecall`  

呼叫 `ecall` 後會 trap 進入 `stvec` 裡面存的位置，也就是 `trap_entry()` ，後會 call 到 `trap_handler()` 。
`trap_handler()`判斷是 system call 後會 call `syscall_handler()`。
`syscall_handler()` 便會根據 `a7` register 裡面的值判斷要呼叫哪一個 system call function。

**Important !!**
由於執行 `ecall` 的瞬間 CPU 會自動完成以下動作：
1. U-mode 切換到 S-mode
2. 關閉中斷：自動把 sstatus.SIE 設為 0
3. 把當前 PC 存進 sepc 暫存器；把中斷原因存進 scause 暫存器。
4. 把 PC 指到 `stvec`

所以進入 `syscall_handler()` 時是收不到中斷的，所以為了 enable Kernel Preemption 我們會在進入 `syscall_handler()` 時打開中斷。
``` c
void syscall_handler(struct trap_frame *tf) {
    asm volatile("csrs sstatus, 2");   // enable interrupt!!
    long syscall_num = tf->a7;
    long ret = -1;

    switch (syscall_num) {
            ...
```


#### 0: long getpid()
Return the current process’s pid.
``` c
case SYS_getpid:
    ret = get_current()->pid;
    break;
```
`get_current()` 會回傳 current thread 的 `task_struct`

#### 1: long uart_read(char *buf, long count)
Read count bytes into buf. Return the number of bytes read.
``` c
case SYS_uart_read: {
    char *buf = (char *)tf->a0;
    long count = tf->a1;
    long bytes_read = 0;
    
    for (long i = 0; i < count; i++) {
        char c = uart_getc();
        buf[i] = c;
        bytes_read++;
    }
    ret = bytes_read;
    break;
}
```

#### 2: long uart_write(const char *buf, long count)
Write count bytes from buf. Return the number of bytes written.
``` c
case SYS_uart_write: {
    const char *buf = (const char *)tf->a0;
    long count = tf->a1;
    long bytes_written = 0;
    
    for (long i = 0; i < count; i++) {
        uart_putc(buf[i]);
        bytes_written++;
    }
    ret = bytes_written;
    break;
}
```


#### 3: int exec(const char *path)
Load and execute the program specified by path. Return 0 on success, -1 on failure.
`exec()` 是把現在的thread 直接改成跑新的 program，不會建立一個新的 thread，而是直接**取代**。
``` c
case SYS_exec: {
    const char *path = (const char *)tf->a0;
    ret = do_exec(path);
    break;
}   ...

int do_exec(const char *path) {
    struct task_struct *curr = get_current();
    
    // cpio parsing 
        ...
    if (cpio_find(initrd, path, &src, &src_size) != 0) return -1;
    
    // Allocate new user space (no MMU, just kmalloc)
    unsigned long total = src_size + 16 * 1024; // 16 KiB user stack
    void *buf = kmalloc(total);
    if (!buf) return -1;
    
    byte_copy(buf, src, src_size);
    
    // Free old user space if it exists
    if (curr->user_stack_base) {
        kfree((void *)curr->user_stack_base);
    }
    // Update new user space info
    curr->user_stack_base = (unsigned long)buf;
    curr->user_stack_size = total;
    
    
    // Update trap frame
    uintptr_t entry = (uintptr_t)buf;
    uintptr_t user_sp = ((uintptr_t)buf + total) & ~0xfUL;
    curr->tf->sepc = entry;
    curr->tf->sp = user_sp;
    
    return 0;
}
```
- `do_exec()`
    1. 先 parsing cpio 找出要執行的 binary
    2. Allocate 新的 user space (src + user stack)，並進行 copy
    3. 把這個 thread 原本持有的 user space free 掉
        - `user_stack_base` 跟 `user_stack_size` 其實是整個 user space 的起始 address 跟 size (命名不當 等等改) 
    5. **把 trap frame 中的 `sepc` 和 `sp` 改成新 program 的 entry 和 stack**
        - return 回 `trap_entry()` 後裡面的 code 會將 trap_frame 中的sepc load 回 sepc register，後面執行 sret 回 U-mode 後就會自動到新 program entry 開始執行
    6. return 回 `trap_entry()` 繼續執行下半部



#### 4: long fork()
Duplicate the current process. Return the child’s pid to the parent, and 0 to the child.


``` c
case SYS_fork:
    ret = do_fork(tf);
    break;
//--------------------------

long do_fork(struct trap_frame *tf) {
    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

    struct task_struct *parent = get_current();
    struct task_struct *child = thread_create(0); // 0 because we will overwrite context
    
    // Copy user space to child
    if (parent->user_stack_base) {
        child->user_stack_base = (unsigned long)kmalloc(parent->user_stack_size);
        child->user_stack_size = parent->user_stack_size;
        byte_copy((void *)child->user_stack_base, (void *)parent->user_stack_base, parent->user_stack_size);
    }

    // record parent pid
    child->ppid = parent->pid;
    
    // Copy the trap frame to the child's kernel stack
    struct trap_frame *child_tf = (struct trap_frame *)(child->stack + STACK_SIZE - sizeof(struct trap_frame));
    byte_copy(child_tf, tf, sizeof(struct trap_frame));
    child->tf = child_tf;
    
    // Child's fork() return value is 0
    child_tf->a0 = 0;

    // store new `tp` into trap frame
    child_tf->tp = (unsigned long)child;
    
    // Adjust child's user stack pointer: same offset within child's allocation
    if (parent->user_space_base) {
        
        /* run on parent's memory */
        // unsigned long sp_offset = child_tf->sp - parent->user_space_base;
        // child_tf->sp = child->user_space_base + sp_offset;
        
        /* run on child's memory */
        unsigned long offset = child->user_space_base - parent->user_space_base;
        child_tf->sp += offset;
        child_tf->sepc += offset;
        child_tf->s0 += offset; 
        child_tf->gp += offset; 
        child_tf->ra += offset;
    }
    
    // Set child's kernel thread context:
    // When scheduler picks the child, switch_to returns into _ret_from_fork,
    // which restores the trap frame and srets back to U-mode.
    extern void _ret_from_fork();
    child->thread.ra = (unsigned long)_ret_from_fork;
    child->thread.sp = (unsigned long)child_tf;

    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
    
    return child->pid;
}
```


- `do_fork()`
    1. 首先進入 critical section
    2. call `thread_create()` 幫 child 建立一個 new thread
    3. copy parent 的 user space (src + user stack) 給 child
    4. 更新 child 的 `task_struct` 的 `ppid` 為 parent 的 `pid`
    5.  在 child 的 kernel stack 上 配置一塊空間放 child trap frame 並將 parent trap frame copy 過去
    6.  在 child trap frame 上設定 child 的 fork return value 回 0
    7.  將 child's `task_struct` addresss 存到 trap frame 中的 `tp`
    8.  算出 child 的 `sp` offset 並存回 trap frame
    9.  **這邊少更新 sepc !!!**
    10. 更新 `switch_to()` 會用到的 `ra` 跟 `task_struct` 中的 `sp`



#### 5: long waitpid(long pid)
Wait for the process identified by pid to finish. Return the pid of the finished process.

``` c

long do_waitpid(long pid) {
    while (1) {
        int found = 0;
        struct task_struct *curr = run_queue;
        struct task_struct* par = get_current();

        unsigned long saved_sstatus;
        asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

        if (curr) {
            do {
                if (curr->pid == pid) {
                    found = 1;
                    if (curr->state == THREAD_ZOMBIE) {
                        dequeue(&run_queue, curr);
                        if (curr->user_stack_base) {
                            kfree((void *)curr->user_stack_base);
                        }
                        kfree((void *)curr->stack);
                        kfree(curr);
                        
                        asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
                        return pid;
                    }
                    break;
                }
                curr = curr->next;
            } while (curr != run_queue);
        }

        asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));

        // child process not found
        if (!found) return -1; 
        
        // Found the child process but not zombie, schedule other process
        schedule();
    }
}

```

使用 while loop 重複 traverse `run_queue` 的流程，traverse `run_queue` 則是在內層的 do-while loop 執行。如果發現正在**等待的 pid 變成 zombie 的話才會完成 pid thread 的 kill zombie 流程並從這個 function return**。
若有找到正在等待的 pid 且還在 running state 的話就會 break 出 do-while loop 並 call `schedule()` 讓出 CPU ，下次 schedule 回來就會進入下一輪的 while loop 繼續等待。

**為何要 critical section?**
若不用 critical section 保護 traverse flow 可能 traverse 到一半突然就讀到已經被其他 thread free 掉的空間



#### 6: void exit(int status)
Terminate the current process. The status can be used to indicate the exit reason, but it is not required in this lab.
``` c
case SYS_exit: {
    thread_exit(); // Doesn't return
    break;
}

void thread_exit() {
    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

    struct task_struct* current = get_current();
    current->state = THREAD_ZOMBIE;

    // Reparenting：把所有以此 thread 為 parent 的 thread 的 ppid 都改成 0
    if (run_queue) {
        struct task_struct *curr = run_queue;
        do {
            if (curr->ppid == current->pid) {
                curr->ppid = 0; // turn this thread into orphan thread and handover to idle thread
            }
            curr = curr->next;
        } while (curr != run_queue);
    }

    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));
    schedule();
    while (1);  // Just in case accidentally return
}
```
把自己改成 zombie 後，將以自己為 parent 的 child threads 的 `ppid` 改成 0 ，也就是 orphan thread 的意思。這些 orphan thread 的 memory reclamation 會由 idle thread 處理。  

最後會 call `schdule()` 讓出 CPU ，因為不能讓這個 function 繼續執行 return 就結束在這裡，也因為 state 已經改成 zombie ，所以不會再被 schedule 到，只會等待 idle thread 回收。
最後的 `while (1);` 只是 in case 意外的 return 或被 schedule，所以讓它停在這裡，也方便 debug。

#### 7: int stop(long pid)
Terminate the process identified by pid. Return 0 on success, -1 on failure.

``` c
int do_stop(long pid) {
    if (!run_queue) return -1;
    
    struct task_struct *curr = run_queue;
    do {
        if (curr->pid == pid) {
            curr->state = THREAD_ZOMBIE;
            return 0;
        }
        curr = curr->next;
    } while (curr != run_queue);
    
    return -1;
}
```
Traverse the `run_queue` to find the `pid` thread, and change its state to zombie. 


## Basic Exercise 3
實做 **1/32 second 的 timer interrupt**，以讓所有 thread 可以在一定時間內爭取到 CPU 使用權，並使用播放影片的方式來確認影片跟 user shell 是否可以同時執行，可以的話也就代表 1/32 sec 的 context switch 機制有正確實做。
影片的播放需要實做額外**兩個 syscall `display(...)` and `usleep(usec)`**。

### 1/32 timer interrupt implementation

- `add_timer_ticks(preempt_callback, NULL, SYS_CLOCK_FREQ / 32);`
    - 跟上個 lab 的 `add_timer` 邏輯一模一樣，只是時間單位變成 usec 



- `preempt_callback()`
    ``` c
    static void preempt_callback(void *arg) {
        // Re-register for the next 1/32 second
        add_timer_ticks(preempt_callback, NULL, SYS_CLOCK_FREQ / 32);
        // Give up CPU
        schedule();
    }
    ```
    每次執行到 callback 後就會 set 下一個 timer，並且呼叫 `schedule()` 執行 context switch。
    
### syscall Implementation

#### 8: void display(unsigned int *bmp_image, unsigned int width, unsigned int height)
Display the video.
``` c
case SYS_display: {
    unsigned int *bmp_image = (unsigned int *)tf->a0;
    unsigned int width = (unsigned int)tf->a1;
    unsigned int height = (unsigned int)tf->a2;
    video_bmp_display(bmp_image, width, height);  // provided by TA
    ret = 0;
    break;
}
```

#### 9: int usleep(unsigned int usec)
Sleep for a specified number of microseconds. Return 0 on success, -1 on failure.
``` c
static void wakeup_callback(void *arg) {
    struct task_struct *task = (struct task_struct *)arg;
    
    if (task->state == THREAD_SLEEPING) {
        task->state = THREAD_RUNNING;
    }
}

int do_usleep(unsigned int usec) {
    struct task_struct *curr = get_current();
    curr->state = THREAD_SLEEPING;
    
    // Calculate ticks. freq is ticks per second.
    // ticks = usec * freq / 1000000
    unsigned long ticks = ((unsigned long)usec * get_timer_freq()) / 1000000;
    if (ticks == 0) ticks = 1; // Sleep at least one tick if usec is very small
    
    add_timer_ticks(wakeup_callback, curr, ticks);
    schedule();
    return 0;
}
```
把自己的 state 改成 sleeping，並加一個 timer， timer 的 callback 會把 state 改回 running。
**改回 running 前要先確認是否是 sleeping state!!!**
以播放影片的 thread 來說，如果 它呼叫 sleep 後馬上被 stop (也就是被改成 zombie，甚至空間可能被 free 掉了) 後來 timer 跳起來後 zombie 又被改回 running，這是不正確的結果


## Advance Exercise 1
實做 POSIX Signal 機制，讓 User Process 能夠註冊並執行自定義的 Signal Handler，並且在執行完畢後安全地回到原本被中斷的地方
分成以下幾個部份實做：
### 擴充 `task_struct` 
增加記錄 Signal 相關狀態的欄位：
- `pending_signals`: 待處理的 Signal 記錄，用 bitmask 記錄哪些 Signal 發生了
- `signal_handlers[SIGNAL_MAX]`: 記錄每個 Signal 對應的 handler（如果是 NULL 代表使用預設行為）。
- `struct trap_frame signal_saved_tf`: 備份用的 Trap Frame，當 Process 被打斷去執行 Signal Handler 時，原本的暫存器狀態必須被備份起來
- `signal_stack`: 記錄為了執行 Handler 而額外分配的 User Stack 位址，以便事後 kfree。
- `is_handling_signal`: 標記該 Process 是否正在執行 Signal Handler（不用處理 Nested Signal，所以只用一個 Flag 來防止重複進入）
- 

### trap.c signal handler 的觸發點
lab spec mentioned *"The kernel checks for pending signals before returning a process to user mode. If a signal is pending, the kernel redirects execution to the appropriate handler."* 所以需要在 thread 進入 kernel mode 然後準備回到 user mode 前，call `signal_check()` 檢查該 thread 是否有 pending signal，如果有就執行 signal handler
#### signal_check()
``` c
void signal_check(struct trap_frame *tf) {
    // Only act when returning to U-mode (SPP == 0)
    if (tf->sstatus & (1UL << 8)) return;

    struct task_struct *curr = get_current();
    if (!curr->pending_signals) return;
    if (curr->is_handling_signal) return;

    // Find the lowest-numbered pending signal
    int sig = -1;
    for (int i = 0; i < SIGNAL_MAX; i++) {
        if (curr->pending_signals & (1u << i)) {
            sig = i;
            break;
        }
    }
    if (sig < 0) return;

    void (*handler)() = curr->signal_handlers[sig];
    if (!handler) {
        // No registered handler: clear bit and terminate
        curr->pending_signals &= ~(1u << sig);
        curr->state = THREAD_ZOMBIE;
        curr->ppid = 0;
        return;
    }

    // Deep-copy the current trap frame so we can restore it in sigreturn
    byte_copy(&curr->signal_saved_tf, tf, sizeof(struct trap_frame));

    // Allocate a fresh stack for the handler
    curr->signal_stack = kmalloc(STACK_SIZE);
    curr->is_handling_signal = 1;
    curr->pending_signals &= ~(1u << sig);

    /*
     * Inject the sigreturn trampoline at the bottom of the signal stack:
     *   li   a7, 11          # SYS_sigreturn = 11  -> encoding: 0x00B00893
     *   ecall                #                     -> encoding: 0x00000073
     *
     * Place it at stack_base so the user-mode handler returns to it via ra.
     */
    unsigned int *trampoline = (unsigned int *)curr->signal_stack;
    trampoline[0] = 0x00B00893u; /* li a7, 11  */
    trampoline[1] = 0x00000073u; /* ecall      */
    unsigned long trampoline_addr = (unsigned long)trampoline;

    // New user stack top: top of signal stack, 16-byte aligned
    unsigned long new_sp = ((unsigned long)curr->signal_stack + STACK_SIZE) & ~0xfUL;

    // Redirect trap frame to the handler
    tf->sepc = (unsigned long)handler;
    tf->sp   = new_sp;
    tf->s0   = new_sp;   // frame pointer = sp for a fresh frame
    tf->ra   = trampoline_addr;
    tf->a0   = (unsigned long)sig;
}
```
1. 首先檢查 `sstatus` 的 `spp` 來判斷是否為 user mode（0）
2. 檢查當前 thread 是否有 pending signal 和 是否正在處理 signal
3. 從 `pending_signals` 中找出是否有對應的 bit 被 set，並找出對應的 handler
    - 如果沒有設定 handler，就直接將 thread 變成 zombie 並 clear signal bit，然後 return 
4. deep copy 當前 trap frame 到 `signal_saved_tf`
5. Allocate new signal stack, set `is_handling_signal` and clear signal bit in `pending_signals`
6. 設置 signal stack 中的 trampoline（li a7, 11; ecall）
    - 因為 U-mode 不該執行 Kernel (S-mode) 記憶體裡的程式碼，就算沒有 MMU，RISC-V 的硬體機制（或是編譯時的 Section 屬性）通常也會阻擋 U-mode 去 Fetch S-mode 的 Instruction，這會直接觸發 Instruction Access Fault。
    - 所以直接將這個 trampoline 放在 User signal stack
7. 設置新的 trap frame：
    - `tf->sepc = (unsigned long)handler;`
        - trap 結束回到 U-mode 後會直接跳到 handler function
    - `tf->sp = new_sp;`
    - `tf->s0 = new_sp;`
    - `tf->ra = trampoline_addr;`
        - **把 `ra` 設為剛剛 trampoline address，這是為了讓 Handler 執行完後，會跳到 trampoline 並呼叫 `sigreturn()` syscall**
    - `tf->a0 = (unsigned long)sig;`
        - 傳 `sig` number 給 handle


### syscal Implementation
#### 10: long signal(int signum, void (*handler)())
Register a user-space handler for the given signal. The handler must run in U-mode. The return value is the previous handler for the signal, you can ignore it in this lab.
``` c
void do_signal(int sig, void (*handler)()) {
    if (sig < 0 || sig >= SIGNAL_MAX) return;
    struct task_struct *curr = get_current();
    curr->signal_handlers[sig] = handler;
}
```

#### 11: void sigreturn()
Restore the original user context after a signal handler returns. This syscall is called automatically via a trampoline set by the kernel. The kernel also recycles the signal stack upon completion.
``` c
void do_sigreturn(struct trap_frame *tf) {
    struct task_struct *curr = get_current();

    uart_puts("[sigreturn] signal handler finished, pid: ");
    uart_dec(curr->pid);
    uart_puts("\n");

    // Restore original user context (deep copy back into the live trap frame)
    byte_copy(tf, &curr->signal_saved_tf, sizeof(struct trap_frame));

    // Free the temporary signal stack
    if (curr->signal_stack) {
        kfree(curr->signal_stack);
        curr->signal_stack = 0;
    }

    curr->is_handling_signal = 0;
    // tf is now pointing at the restored context; trap_handler returns normally
    // and sret will resume the original user execution.
}
```

#### 12: int kill(int pid, int signum)
Send a signal to the process identified by pid. If the process has a registered handler for the signal, the handler is executed. Otherwise, the process is terminated by default. Return 0 on success, -1 on failure.


``` c
int do_kill(int pid, int sig) {
    if (sig < 0 || sig >= SIGNAL_MAX) return -1;
    if (!run_queue) return -1;

    struct task_struct *curr = run_queue;
    do {
        if (curr->pid == pid) {
            if (curr->signal_handlers[sig]) {
                // Registered handler: set the pending bit
                curr->pending_signals |= (1u << sig);
            } else {
                // Default action: terminate the process
                curr->state = THREAD_ZOMBIE;
                curr->ppid = 0; // orphan -> idle will reap
            }
            return 0;
        }
        curr = curr->next;
    } while (curr != run_queue);

    return -1; // pid not found
}
```

---
需要處理 user shell 2 stop user shell 1 的情況嗎？