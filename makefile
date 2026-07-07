all: boot.bin

boot.bin: boot/boot.asm
	nasm -f bin boot/boot.asm -o boot.bin

.PHONY: clean
clean:
	rm -f boot.bin