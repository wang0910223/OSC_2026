RISCV_GNU ?= riscv64-unknown-elf
CC = $(RISCV_GNU)-gcc
LD = $(RISCV_GNU)-ld
OBJCOPY = $(RISCV_GNU)-objcopy
CFLAGS = -mcmodel=medany -ffreestanding -nostdlib -g -Wall -I include -march=rv64gc_zifencei -mabi=lp64d
QEMU ?= qemu-system-riscv64
TARGET = kernel

PLATFORM ?= QEMU
LDSCRIPT ?= linker_qemu.ld
ifeq ($(PLATFORM), QEMU)
	LDSCRIPT = linker_qemu.ld
    CFLAGS += -DQEMU
else
	LDSCRIPT = linker_board.ld
    CFLAGS += -DBOARD
endif

DEBUG ?= 0
ifeq ($(DEBUG), 1)
    CFLAGS += -DDEBUG
endif

build: clean
	$(MAKE) initramfs.cpio
	$(CC) $(CFLAGS) -c src/*.S src/*.c
	$(LD) -T $(LDSCRIPT) -o $(TARGET).elf *.o
	$(OBJCOPY) -O binary $(TARGET).elf $(TARGET).bin
	mkimage -f kernel.its kernel.fit

run: build $(TARGET).bin
	$(QEMU) -M virt -m 8G -kernel $(TARGET).bin -initrd initramfs.cpio -display none -serial stdio

clean:
	rm -f $(TARGET).bin $(TARGET).elf *.o kernel *.fit
	rm -rf rootfs initramfs.cpio

rootfs/hello.txt:
	mkdir -p rootfs
	echo "Hello world from initramfs!" > rootfs/hello.txt

# Stage the pre-built user program into rootfs/ so it ends up inside
# the initramfs cpio archive. prog.bin is committed in the kernel/ tree.
rootfs/prog.bin: prog.bin
	mkdir -p rootfs
	cp prog.bin rootfs/prog.bin

rootfs/osctest.bin: osctest.bin
	mkdir -p rootfs
	cp osctest.bin rootfs/osctest.bin

initramfs.cpio: rootfs/hello.txt rootfs/prog.bin rootfs/osctest.bin
	cd rootfs && find . | cpio -o -H newc > ../initramfs.cpio


