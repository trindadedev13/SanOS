NASM = nasm
QEMU = qemu-system-i386

BOOT_SRC = src/boot.asm
IMG = build/sanOS.img

.PHONY: all run clean

all: setup $(IMG)

setup:
	mkdir -p build

$(IMG): $(BOOT_SRC)
	$(NASM) $< -o $@

run: $(IMG)
	@echo "Running with QEMU..."
	$(QEMU) -drive format=raw,file=$(IMG) || (echo "Failed to run QEMU" && false)

clean:
	rm -f $(IMG)

.PHONY: all run clean $(IMG)