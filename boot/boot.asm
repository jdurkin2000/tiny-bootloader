; boot.asm - 16-bit boot sector

BITS 16
ORG 0x7C00

start:
    mov ax, 0xB800
    mov es, ax

    ; Set data segment to bootloader area
    xor ax, ax
    mov ds, ax

    mov di, 0       ; offset into VGA memory
    
    mov si, hello

.print:
    lodsb            ; load byte from [SI] into AL, increment SI
    or al, al        ; check if AL == 0
    jz hang

    mov ah, 0x01    ; attribute
    mov [es:di], ax
    add di, 2
    jmp .print

hang:
    cli
    hlt
    jmp hang

hello db "Hello from brain hurt!", 0

; padding + boot signature
times 510-($-$$) db 0
dw 0xAA55
