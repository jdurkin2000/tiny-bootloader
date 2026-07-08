all: boot.bin

boot.bin: boot/boot.asm \
          kernel/screen.asm \
          kernel/keyboard.asm
	nasm -f bin boot/boot.asm -o boot.bin

.PHONY: clean
clean:
	rm -f boot.bin