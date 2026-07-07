; boot.asm - 16-bit boot sector

ASCII_NUL equ 0x00
ASCII_BS  equ 0x08
ASCII_TAB equ 0x09
ASCII_LF  equ 0x0A
ASCII_CR  equ 0x0D
ASCII_SPACE equ 0x20

BITS 16
ORG 0x7C00

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

    mov si, hello
    call put_str

hang:
    cli
    hlt
    jmp hang

put_char:
    mov ah, 0x07

    call put_char_with_attr

    ret 

; Takes ax value and prints it to screen
; input = ah: attribute, al: char
put_char_with_attr:
    push bx
    push es
    push di

    ; Setup VGA memory addr
    mov bx, 0xB800
    mov es, bx
    mov di, [cursor_pos]

    cmp al, ASCII_LF
    jz .new_line

    cmp al, ASCII_CR
    jz .carriage_return

    cmp al, ASCII_BS
    jz .backspace

    cmp al, ASCII_TAB
    jz .tab

    mov [es:di], ax ; put char in vga buffer
    add word [cursor_pos], 2 ; increment cursor pop

.exit:
    pop di
    pop es
    pop bx
    ret

.tab:
    add word [cursor_pos], 6

    jmp .exit

.new_line:
    ; move cursor to next line
    push ax
    push cx
    push dx

    mov ax, [cursor_pos]
    xor dx, dx          ; clear dx — dividend is dx:ax, must zero high half
    mov cx, 160          ; 80 columns * 2 bytes per cell
    div cx               ; ax = current row, dx = byte offset within current row
    sub cx, dx            ; cx = bytes remaining to reach start of next row
    add word [cursor_pos], cx

    pop dx
    pop cx
    pop ax
    jmp .exit
.carriage_return:
    ; move cursor to beginning of row
    push ax
    push cx
    push dx

    mov ax, [cursor_pos]
    xor dx, dx          ; clear dx — dividend is dx:ax, must zero high half
    mov cx, 160          ; 80 columns * 2 bytes per cell
    div cx               ; ax = current row, dx = byte offset within current row
    sub word [cursor_pos], dx

    pop dx
    pop cx
    pop ax
    jmp .exit
.backspace:
    sub word [cursor_pos], 2
    mov di, [cursor_pos]

    mov al, ASCII_SPACE
    mov[es:di], ax

    jmp .exit

; Prints string onto screen
; input: DS:SI -> null-terminated string
; preserves si
put_str:
    push si

.loop:
    lodsb            ; load byte from [SI] into AL, increment SI
    test al, al        ; check if AL == 0
    jz .exit

    call put_char

    jmp .loop

.exit:
    pop si
    ret


; clears entire screen
clear_screen:
    push ax
    push bx
    push cx
    push es
    push di

    cld

    ; Setup VGA memory addr
    mov bx, 0xB800
    mov es, bx
    mov di, 0

    mov ax, 0x0720
    mov cx, 2000
    rep stosw

    mov word [cursor_pos], 0

    pop di
    pop es
    pop cx
    pop bx
    pop ax

    ret

; CRTC register 0x0E = Cursor Location High
; CRTC register 0x0F = Cursor Location Low
set_cursor_pos:
    ; assume bx = desired cursor position (row*80 + col)
    push ax
    push dx

    mov dx, 0x3D4
    mov al, 0x0E          ; select "cursor location high" register
    out dx, al
    mov dx, 0x3D5
    mov al, bh            ; high byte of position
    out dx, al

    mov dx, 0x3D4
    mov al, 0x0F          ; select "cursor location low" register
    out dx, al
    mov dx, 0x3D5
    mov al, bl            ; low byte of position
    out dx, al

    pop dx
    pop ax

    ret

hello db "Hello from", ASCII_TAB ,"brain hurt!", 0
cursor_pos dw 0

; padding + boot signature
times 510-($-$$) db 0
dw 0xAA55
