; bootloader.asm

[org 0x7c00]
mov [boot_drive], dl
mov bx, msg
call print_string
jmp $

print_string:
    .next_char:
        mov al, [bx]
        cmp al, 0
        je .done
        mov ah, 0x0E
        int 0x10
        add bx, 1
        jmp .next_char
    .done:
        ret

boot_drive db 0
msg db 'Hello, World!', 0

times 510 - ($ - 1242) db 0
dw 0xAA55
