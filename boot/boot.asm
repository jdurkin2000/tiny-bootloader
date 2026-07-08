; boot.asm - 16-bit boot sector

BITS 16
ORG 0x7C00

jmp start

%include "kernel/screen.asm"
%include "kernel/keyboard.asm"

start:
    ; Setup stack
    cli
    mov ax, 0x9000 
    mov ss, ax
    mov ax, 0x0000
    mov sp, ax
    sti

    ; Set data segment to bootloader area
    xor ax, ax
    mov ds, ax

    call clear_screen
    call read_line
    mov si, hello
    call put_str
hang:
    cli
    hlt
    jmp hang


hello db "Hello from brain hurt!", 0


; padding + boot signature
times 510-($-$$) db 0
dw 0xAA55
