# Lab 6

## Basic Exercise 1 
``` c
void setup_vm(void) {
#ifdef QEMU
    ...
    
    map_pages_2m(pg_dir, 0x00000000, 0x80000000, 0x00000000, PAGE_READ | PAGE_WRITE | PAGE_EXEC | PAGE_GLOBAL);
    map_pages_2m(pg_dir, PAGE_OFFSET + 0x00000000, 0x80000000, 0x00000000, PAGE_READ | PAGE_WRITE | PAGE_EXEC | PAGE_GLOBAL);
    
    
    unsigned long mmio_prot = PAGE_READ | PAGE_WRITE | PAGE_GLOBAL;
    // Board UART 
    map_pages_4k(pg_dir, 0xD4017000, 0x1000, 0xD4017000, mmio_prot);
    map_pages_4k(pg_dir, PAGE_OFFSET + 0xD4017000, 0x1000, 0xD4017000, mmio_prot);

    // Board PLIC
    map_pages_4k(pg_dir, 0xe0000000, 0x400000, 0xe0000000, mmio_prot);
    map_pages_4k(pg_dir, PAGE_OFFSET + 0xe0000000, 0x400000, 0xe0000000, mmio_prot);
#endif

    // Write satp and flush TLB
    unsigned long satp = SATP_MODE_SV39 | ((unsigned long)pg_dir >> 12);
    asm volatile(
        "csrw satp, %0\n"
        "sfence.vma zero, zero\n"
        : : "r"(satp) : "memory"
    );
}
```
每一個硬體都做了兩次 mapping，一次是 VA = PA ，另一次是  higher half VA = PA ，
- VA = PA (Identity Mapping)  
    - 當函數最後一行執行 `csrw satp` 開啟 MMU 的瞬間，**PC 還停留在低位址** 。如果不做 Identity Mapping，開啟 MMU 的下一秒，CPU 就會用 PA 當成 VA 拿去查 page table，但 page table 中對應 PA 的 entry 還是空的，就會造成 page fault。
    - 等到 **CPU 執行了 Jump 指令，正式把 PC 暫存器改寫成 0xffffffc0... 這樣的高位址**後，我們就可以呼叫 drop_identity_map() 把這個階段性任務的保護網拆掉了。

對於範圍大的 RAM 使用 2MB huge page mapping，MMIO 則使用 4KB
- RAM 被賦予了 PAGE_EXEC 權限，因為 Kernel 程式碼放在裡面。
- MMIO 的權限變數 mmio_prot 刻意去掉了 PAGE_EXEC，只保留 R | W



``` c
void drop_identity_map(void) {
    pg_dir[0] = 0; // Covers 0x0 ~ 0x3FFFFFFF (Board RAM, UART, PLIC, CLINT)
    pg_dir[1] = 0; // Covers 0x40000000 ~ 0x7FFFFFFF
    pg_dir[2] = 0; // Covers 0x80000000 ~ 0xBFFFFFFF (QEMU RAM)
    pg_dir[3] = 0; // Covers 0xC0000000 ~ 0xFFFFFFFF (Board PLIC)
    asm volatile("sfence.vma zero, zero\n" : : : "memory");
}
```
- `pg_dir[i] = 0`
    - 一個 `pgd` entry 對應到 1GB，所以這四條指令清除了 low half 前 4 GB 的 mapping relationship
- `asm volatile("sfence.vma zero, zero\n" : : : "memory");`
    - `sfence.vma` : flush TLB 的指令
    - 後面接的兩個參數是 virtual address 和 asid
        - virtual address: 可以指定只刷新特定 VA
            - 0 代表刷新所有位置
        - asid: 可以指定只刷新特定 process TLB cache
            - 0 代表刷新所有 process
    - 兩個參數都放零的意思是清空所有 entry
    - `"memory"`: 代表這行指令可能會影響記憶體狀態，所以執行前需要把所有在暫存氣上的內容都寫回 RAM ，執行後所有變數會重新從 RAM 裡面 load

## Basic Exercise 2
在 user thread 中實做 VA，主要的實做修改是將先直接使用 `kmalloc()` 分配給 thread 的空間，現在需要改用 page table的方式來配置並更新 page table 上對應的 entry。

### thread.c
``` c
struct task_struct* thread_create(void (*threadfn)()) {
    ...
    task->pgd = (unsigned long *)alloc_page();
    for (int i = 256; i < 512; i++) {
        task->pgd[i] = pg_dir[i];
    }
    ...
    task->stack = (unsigned long)kmalloc(STACK_SIZE);  // kernel stack
    ...
}
```
在 `thread_create()` 時，lab 5 的實做會直接為 thread 配置一塊空間存放 src + stack。
lab 6 則改成為配置一個 `pgd` (page global directory) 給 thread，並在初始時將高半部的 entry 複製 kernel 的 pgd，因為高半部是屬於 kernel 使用的空間，所以直接複製 kernel 的 mapping 關係即可。這樣的設計也可以達到所有 user thread 共享 kernel 空間的效果。
而 thread 的 kernel stack 則是直接使用 `kmalloc()` 配置，不用額外設定 page table 是因為 kernel stack 被分配在 high half，而 high half 的 page table entry 已經 copied from kernel 的 `pgd`，所以可以直接使用 `kmalloc()` 配置的位址在 mapping 範圍內。


``` c
int user_program_execute(const char *path) {
    ...
    
    unsigned long code_pages = (src_size + PAGE_SIZE - 1) / PAGE_SIZE;
    const unsigned char *src_ptr = (const unsigned char *)src;
    
    // this critical section is to make sure that we don't switch to another task
    // before we finish setting up the new task's memory and trap frame
    // since after thread_create(), this is a runnable thread and can be scheduled
    unsigned long saved_sstatus;
    asm volatile("csrrci %0, sstatus, 2" : "=r"(saved_sstatus));

    struct task_struct *task = thread_create(user_program_start);
    
    for (unsigned long i = 0; i < code_pages; i++) {
        void *page = alloc_page();
        unsigned long chunk_size = (src_size > PAGE_SIZE) ? PAGE_SIZE : src_size;
        byte_copy(page, src_ptr, chunk_size);
        map_pages(task->pgd, i * PAGE_SIZE, PAGE_SIZE, __pa(page), PAGE_RX);
        src_ptr += chunk_size;
        src_size -= chunk_size;
    }
    
    unsigned long stack_pages = 4;
    for (unsigned long i = 0; i < stack_pages; i++) {
        void *page = alloc_page();
        map_pages(task->pgd, 0x3fffffc000 + i * PAGE_SIZE, PAGE_SIZE, __pa(page), PAGE_RW);
    }
    
    asm volatile("csrs sstatus, %0" :: "r"(saved_sstatus & 2));

    return task->pid;
}
```
在 copy user src 時，會一頁一頁的配置空間並在 page table上紀錄 mapping relationship。
- user src permission: `PAGE_RX` src 只能讀跟執行，不可寫
- user stack permission: `PAGE_RW` stack 可讀可寫
- user stack position: `0x3fffffc000` 到 `0x3fffffc000 + stack_pages * PAGE_SIZE`
    - 將 user stack 配置在 low half 的最頂端並往下長,配置空間為 16KB
    - `0x3fffffc000` 的來源是 low half 共 256 GB（`0x4000000000`），`0x4000000000` - `0x4000` (16KB) = `0x3fffffc000`

### vm.c

`pagewalk()` 把一個 thread 的 VA 對應到的 PA 位置紀錄到 page table 裡面，
``` c
void pagewalk(unsigned long *pgd, unsigned long va, unsigned long pa, unsigned long prot) {
    // `& 0x1ff` for getting the corresponding 9 bits 
    int vpn2 = (va >> 30) & 0x1ff;
    int vpn1 = (va >> 21) & 0x1ff;
    int vpn0 = (va >> 12) & 0x1ff;
    unsigned long *pmd, *pte;

    if (pgd[vpn2] & PAGE_PRESENT) {
        pmd = (unsigned long *)__va((pgd[vpn2] >> 10) << 12);
    } else {
        unsigned long new_page_va = (unsigned long)alloc_page();
        pgd[vpn2] = ((__pa(new_page_va) >> 12) << 10) | PAGE_PRESENT;
        pmd = (unsigned long *)new_page_va;
    } 

    if (pmd[vpn1] & PAGE_PRESENT) {
        pte = (unsigned long *)__va((pmd[vpn1] >> 10) << 12);
    } else {
        unsigned long new_page_va = (unsigned long)alloc_page();
        pmd[vpn1] = ((__pa(new_page_va) >> 12) << 10) | PAGE_PRESENT;
        pte = (unsigned long *)new_page_va;
    }

    // permission after `prot` just in case error 
    // idealy, `prot` shouldn't contain those bits
    pte[vpn0] = ((pa >> 12) << 10) | prot | PAGE_PRESENT | PAGE_ACCESSED | PAGE_DIRTY;
}

void map_pages(unsigned long *pgd, unsigned long va, unsigned long size, unsigned long pa, unsigned long prot) {
    for (unsigned long i = 0; i < size; i += PAGE_SIZE) {
        pagewalk(pgd, va + i, pa + i, prot);
    }
}
```
- `pmd = (unsigned long *)__va((pgd[vpn2] >> 10) << 12);`
    - `(pgd[vpn2] >> 10)`: remove the last 10 bits (permission bits(8) + RSW(2))
    - `<< 12`: align to page size (4KB)
    - `__va()`: convert physical address to virtual address

- page table 的中間層 permission 都只設 `present` bit，硬體看到 R, W, X 都是 0 就知道這只是只向下一層的 page 會繼續往下一層找。

- 如果 R, W, X 任一為 1：硬體就知道「這已經到底了」，會直接把它當成實體記憶體。如果在 PMD 層級設了 RWX，它就變成了 2MB 的 Huge Page


## Advance Exercise 1
### `mmap()` syscall
mmap() is a system call used to create memory regions for a user process. Each region can be mapped to a file or to anonymous pages (i.e., page frames not related to any file) with specific access protections. Users can create heap and memory-mapped regions using this system call.

The kernel can also use it to implement the program loader. Memory regions such as .text and .data can be created by memory-mapped files. Regions like .bss and the user stack can be created by anonymous page mapping.

這裡因為沒有實做檔案系統，所以只做了 anonymous page mapping。

### API Specification
```c
void *mmap(void *addr, unsigned long length, int prot, int flags);
```
- `addr`:
    - If it is NULL, the kernel chooses the starting address.
    - If it is not NULL: If the region overlaps with existing ones or is not page-aligned, treat addr as a hint. Otherwise, use addr as the exact base of the new region.
- `length`: The size of the mapping. It must be page-aligned (the kernel should round it up if it is not).
- `prot`: Specifies the access protection for the region:
    - `PROT_NONE`: 0 (inaccessible)
    - `PROT_READ`: 1 (readable)
    - `PROT_WRITE`: 2 (writable)
    - `PROT_EXEC: 4 (executable)
- `flags`: Memory mapping flags:
    - `MAP_ANONYMOUS`: 0x20, Create anonymous pages (used for stack/heap).
    - `MAP_POPULATE`: 0x8000, Allocate physical pages immediately (optional if you are implementing demand paging).

### Implementation
在 `task_struct` 中加入 `struct vm_area_struct *vma_list;` member 來紀錄 dynamically allocated memory regions for each process.

- struct vm_area_struct
    ``` c
    struct vm_area_struct {
        unsigned long vm_start;         // Start address of the mapped region
        unsigned long vm_end;           // End address (vm_start + length)
        int vm_prot;                    // Protection flags (PROT_READ, PROT_WRITE, etc.)
        int vm_flags;                   // Flags like MAP_ANONYMOUS, MAP_POPULATE
        struct vm_area_struct *vm_next; // Pointer to the next VMA
    };
    ```
`thread.c` 中相關的修改主要有：
-  `thread_create()` 時將 `vma_list` 指標初始化為 0； 
- `kill_zombie()` 中加入了以下程式碼來釋放 mmap 配置的空間
    ``` c
    struct vm_area_struct *vma = zombie_to_free->vma_list;
    while (vma) {
        struct vm_area_struct *next = vma->vm_next;
        kfree(vma);
        vma = next;
    }
    zombie_to_free->vma_list = 0;
    ```

## Advance Exercise 2

### trap.c
加上 page fault handler 的邏輯
``` c
    // Using demand paging to deal with page fault
    if (cause == 12 || cause == 13 || cause == 15) {
        struct task_struct *curr = get_current();
        struct vm_area_struct *vma = curr->vma_list;
        struct vm_area_struct *target_vma = 0;

        // 1. Check if the faulting address belongs to any VMA (regardless of user/kernel mode)
        while (vma) {
            if (tf->stval >= vma->vm_start && tf->stval < vma->vm_end) {
                target_vma = vma;
                break;
            }
            vma = vma->vm_next;
        }
```
- **stval**: 當發生 page fault 時，`stval` 會記錄觸發錯誤的位址
- while loop 中 traverse vma list 以確認這個 address 是否屬於已配置的 vma 範圍，如果都不符合就會直接 以 segmentation fault 處理 (第三個區塊)，並 exit 這個 thread。 若有找到則進入第二個區塊進行 demand paging 的處理。

``` c
        // 2. If matched, dynamically allocate and map it
        if (target_vma) {
            unsigned long fault_page_va = tf->stval & ~(PAGE_SIZE - 1);
            unsigned long *pte_ptr = walk_pte(curr->pgd, fault_page_va);

            // A. Copy-On-Write Check
            if (pte_ptr && (*pte_ptr & PAGE_PRESENT)) {
                if (cause == 15 && (*pte_ptr & PAGE_USER) && !(*pte_ptr & PAGE_WRITE)) {
                    if (target_vma->vm_prot & 2) { // PROT_WRITE allowed
                        // Copy-On-Write event confirmed!
                        uart_puts("[Permission fault]: ");
                        uart_hex(tf->stval);
                        uart_puts("\n");

                        unsigned long old_pa = (*pte_ptr >> 10) << 12;
                        void *old_page_va = (void *)__va(old_pa);

                        if (get_page_ref_count(old_page_va) > 1) {
                            // Shared frame, need reallocation & clone
                            void *new_page = alloc_page();
                            if (!new_page) {
                                uart_puts("COW: Out of memory!\n");
                                thread_exit();
                            }
                            memcpy(new_page, old_page_va, PAGE_SIZE);

                            // Update PTE to point to new page with PAGE_WRITE
                            unsigned long flags = (*pte_ptr & 0x3FF) | PAGE_WRITE;
                            *pte_ptr = ((__pa(new_page) >> 12) << 10) | flags;

                            // Decrement reference count on the original frame
                            buddy_free(old_page_va);
                        } else {
                            // Exclusive owner, simply restore the write flag in-place
                            *pte_ptr |= PAGE_WRITE;
                        }

                        // Invalidate the TLB for the modified address
                        asm volatile("sfence.vma %0, zero" : : "r"(fault_page_va) : "memory");
                        return; // Re-run instruction successfully
                    }
                }
            }

            // B. Standard Demand Paging Check
            int perm_ok = 1;
            if (cause == 15 && !(target_vma->vm_prot & 2)) perm_ok = 0; // PROT_WRITE
            if (cause == 13 && !(target_vma->vm_prot & 1)) perm_ok = 0; // PROT_READ
            if (cause == 12 && !(target_vma->vm_prot & 4)) perm_ok = 0; // PROT_EXEC

            if (perm_ok) {
                void *page = alloc_page();
                if (page) {
                    memset(page, 0, PAGE_SIZE);
                    
                    uart_puts("[Translation fault]: ");
                    uart_hex(tf->stval);
                    uart_puts("\n");

                    // 它負責把 軟體層級（POSIX 標準） 的記憶體權限，翻譯成 硬體層級（RISC-V 分頁表 PTE） 真正看得懂的位元旗標（Flags）。
                    unsigned long page_prot = PAGE_USER;
                    if (target_vma->vm_prot & 1) page_prot |= PAGE_READ;
                    if (target_vma->vm_prot & 2) page_prot |= PAGE_WRITE;
                    if (target_vma->vm_prot & 4) page_prot |= PAGE_EXEC;

                    // 在 RISC-V 的硬體規格書（Privileged Architecture Manual）中，針對 PTE 的 R (Read) 和 W (Write) 權限，有一個強制規定：
                    // 「不允許一個分頁是『可寫』但『不可讀』的。」
                    if (page_prot & PAGE_WRITE) page_prot |= PAGE_READ;

                    // 向下對齊頁面邊界
                    unsigned long fault_page_va = tf->stval & ~(PAGE_SIZE - 1);
                    map_pages(curr->pgd, fault_page_va, PAGE_SIZE, __pa(page), page_prot);
                    asm volatile("sfence.vma zero, zero" : : : "memory");
                    return; // 順利排除分頁錯誤，重試執行
                }
            }
        }
```
#### A. Copy-On-Write Check
User Process 呼叫 fork 時，Parent 和 Child 一開始會共享同一塊實體記憶體，但權限會被強制改為 read-only

觸發條件 (CoW 的判斷條件)
- 分頁存在 (PAGE_PRESENT)
- 寫入錯誤 (cause == 15)。
- PTE 目前被標記為不可寫入 (!PAGE_WRITE)
- 但在 VMA 的邏輯權限中，這塊區域其實是允許寫入的 (target_vma->vm_prot & 2)

處理邏輯
- 檢查 Reference Count：
    - 如果 get_page_ref_count > 1，代表還有其他人 (例如 Parent) 在共享這塊記憶體。
    - 複製 (Clone)： OS 趕緊去要一塊全新的實體分頁 (alloc_page)，並用 memcpy 把舊資料全部拷貝過來。
    - 更新映射： 修改 PTE，讓它指向新的實體分頁，並且把 PAGE_WRITE 權限加回去。
    - 釋放舊引用： 呼叫 buddy_free(old_page_va)，讓舊分頁的計數器減一。
- 如果 Reference Count == 1
    - 代表這個 page 是被獨佔，只需要把 PAGE_WRITE 權限加回 PTE 就好。
- 刷新 TLB： 使用 sfence.vma %0, zero 精準刷新這個位址的 TLB 快取

#### B. Standard Demand Paging Check
如果不是 CoW（例如剛 mmap 完第一次存取，或者陣列存取越界但還在合法 VMA 內）
- `perm_ok`: 檢查 VMA 權限是否允許這次的存取行為 (讀/寫/執行) .
若這次的行為是合法的就會進行以下 demand paging 的處理：
- OS 向 Buddy System 要一塊新的空白分頁，並透過 map_pages 在分頁表裡建立連線。
- 執行 return 結束 Trap Handler。CPU 會退回到剛才引發 Page Fault 的那一條指令再執行一次。這次分頁表已經建好了，程式就能順利跑下去，User 完全感覺不到中斷過。

``` c
        // 3. If no VMA found OR permission check failed:
        int from_user = !(tf->sstatus & (1UL << 8));
        if (from_user) {
            uart_puts("[Segmentation fault]: Kill Process\n");
            thread_exit(); 
        }
    }
```
如果找不到 VMA，或者找到 VMA 但權限不對（例如嘗試寫入 PROT_READ 的唯讀區塊）：
- OS 判斷這是一個非法的存取。
- 檢查來源： 如果是來自 User Mode (from_user)，會印出 Segmentation fault，然後呼叫 `thread_exit()` 把這個 Process terminate
- 如果是 Kernel Mode： 會讓它繼續往下走觸發 Kernel Panic


### syscall.c 
修改 `do_mmap()` 的邏輯，改成 demand paging

- 以前的寫法： 只要呼叫 mmap，OS 就會立刻去向 Buddy System 要實體記憶體
- 現在的寫法： 預設情況下，mmap 只會登記 VMA，等到 User 程式真的去讀寫那塊虛擬位址時，就會觸發Page Fault 到那時才動態分配實體記憶體。
    - `MAP_POPULATE` 例外： 如果 User 在呼叫 mmap 時特別帶了這個 flag，OS 就會「預先」把實體記憶體全部配好並建好分頁表


## Advance Exercise 3 Copy-on-Write
在 `buddy.c` 中新增一個 ref_count array，用來儲存每個 page 的 reference count。
call `buddy_free()` 時會檢查該 page 的 `ref_count` ，若大於 1 就 `ref_count--` 後 return，等於 1 才繼續往下真正釋放。