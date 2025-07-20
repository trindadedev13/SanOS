NASM = nasm
QEMU = qemu-system-i386

BOOT_SRC = src/boot/boot.asm
KERNEL_SRC = src/kernel/kernel.asm

BOOT_BIN = build/boot.bin
KERNEL_BIN = build/kernel.bin
IMG = build/SanOS.img

.PHONY: all run clean

all: setup clean $(IMG)

setup:
	mkdir -p build

$(BOOT_BIN): $(BOOT_SRC)
	$(NASM) -f bin $< -o $@

$(KERNEL_BIN): $(KERNEL_SRC)
	$(NASM) -f bin $< -o $@

$(IMG): $(BOOT_BIN) $(KERNEL_BIN)
	dd if=/dev/zero of=$(IMG) bs=512 count=2880
	mkfs.fat -F 12 -n "SanOS" $(IMG)
	dd if=$(BOOT_BIN) of=$(IMG) conv=notrunc
	mcopy -i $(IMG) $(KERNEL_BIN) "::kernel.bin"

run: $(IMG)
	$(QEMU) -m 2048 -smp 4 -drive format=raw,file=$(IMG)

clean:
	rm -f build/*.bin build/*.img