; RP2040 initialization code

section .text
    global _start

_start:
    ; Your initialization code for RP2040 goes here
    ; For testing purposes, let's print a message to the console
    mov     eax, 4          ; sys_write system call
    mov     ebx, 1          ; file descriptor 1 (stdout)
    mov     ecx, message    ; pointer to the message
    mov     edx, message_len  ; message length
    int     0x80            ; make kernel call

    ; Exit
    mov     eax, 1          ; sys_exit system call
    xor     ebx, ebx        ; exit code 0
    int     0x80            ; make kernel call

section .data
    message db 'Hello, RP2040!', 0x0A  ; Message to print
    message_len equ $ - message        ; Length of the message

