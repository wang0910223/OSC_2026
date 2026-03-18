RISCV_GNU ?= riscv64-unknown-elf
CC = $(RISCV_GNU)-gcc
LD = $(RISCV_GNU)-ld
OBJCOPY = $(RISCV_GNU)-objcopy
CFLAGS = -mcmodel=medany -ffreestanding -nostdlib -g -Wall
QEMU ?= qemu-system-riscv64
TARGET = kernel

PLATFORM ?= QEMU
LDSCRIPT ?= linker_qemu.ld
ifeq ($(PLATFORM), QEMU)
	LDSCRIPT = linker_qemu.ld
    CFLAGS += -DQEMU
else
	LDSCRIPT = linker_qemu.ld
    CFLAGS += -DBOARD
endif

build: clean
	$(CC) $(CFLAGS) -c src/*.S src/*.c
	$(LD) -T $(LDSCRIPT) -o $(TARGET).elf *.o
	$(OBJCOPY) -O binary $(TARGET).elf $(TARGET)
	mkimage -f kernel.its kernel.fit

run: build $(TARGET)
	$(QEMU) -M virt -m 8G -kernel $(TARGET) -display none -serial stdio

clean:
	rm -f $(TARGET) $(TARGET).elf *.o *.bin kernel *.fit
