section .text
    global _start

; Constants
TASK_STACK_SIZE equ 1024  ; Size of each task stack

; Function prototypes
extern scheduler_init
extern scheduler_start
extern scheduler_stop
extern task_create
extern task_yield
extern task_sleep
extern communication_init
extern communication_send
extern communication_receive

section .data

section .bss
    task1_stack resb TASK_STACK_SIZE
    task2_stack resb TASK_STACK_SIZE

section .text
_start:
    ; Initialize the RTOS components
    call rtos_init

    ; Start the scheduler
    call scheduler_start

    ; Create tasks
    call create_tasks

    ; Main program logic goes here

    ; Stop the scheduler (optional)
    call scheduler_stop

    ; Exit program
    mov eax, 1       ; syscall number for exit
    xor ebx, ebx     ; exit code 0
    int 0x80         ; invoke syscall

rtos_init:
    ; Initialize the scheduler
    call scheduler_init

    ; Initialize communication module
    call communication_init

    ret

create_tasks:
    ; Create Task 1
    mov dword [esp], task1_entry   ; Task entry point
    mov dword [esp + 4], task1_stack + TASK_STACK_SIZE  ; Stack pointer
    call task_create

    ; Create Task 2
    mov dword [esp], task2_entry   ; Task entry point
    mov dword [esp + 4], task2_stack + TASK_STACK_SIZE  ; Stack pointer
    call task_create

    ret

task1_entry:
    ; Task 1 main function
    ; Example: Send a message via communication module
    mov esi, message_string
    call communication_send

task2_entry:
    ; Task 2 main function
    ; Example: Receive a message via communication module
    call communication_receive

message_string db "Hello, RTOS!", 0

