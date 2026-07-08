; get keyboard input
; AH = scan code of pressed key, AL = ASCII character of pressed key
get_char:
    mov ah, 0x00
    int 0x16

    ret

read_line:
.wait_key:
    call get_char
    push ax
    
    call put_char

    pop ax
    cmp al, 0x0D
    je .exit

    jmp .wait_key
.exit:
    ret