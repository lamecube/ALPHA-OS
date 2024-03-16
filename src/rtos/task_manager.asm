section .text
    global task_create
    global task_yield
    global rtos_init

; Constants
MAX_TASKS       equ 10    ; Maximum number of tasks
TASK_STACK_SIZE equ 1024  ; Size of each task stack

; Task Control Block (TCB) structure
struc tcb_struct
    .task_entry     resd 1      ; Task entry point
    .stack_pointer  resd 1      ; Task stack pointer
endstruc

; Data section
section .data
    task_table  times MAX_TASKS db 0    ; Task table to store TCBs
    current_task dd 0                    ; Pointer to the currently running task

; Function to initialize the RTOS
rtos_init:
    ; Initialize task table
    xor eax, eax
    mov ecx, MAX_TASKS
    mov edi, task_table
    rep stosd

    ; Set current task to null
    mov dword [current_task], 0

    ret

; Function to create a new task
task_create:
    ; Find a free slot in the task table
    mov eax, 0
find_free_slot:
    mov ebx, [task_table + eax * 8]
    test ebx, ebx
    jz found_free_slot
    inc eax
    cmp eax, MAX_TASKS
    jl find_free_slot
    jmp task_create_failed

found_free_slot:
    ; Allocate stack memory for the new task
    push TASK_STACK_SIZE
    call allocate_stack
    add esp, 4

    ; Initialize the task control block (TCB)
    mov [task_table + eax * 8], esp
    mov [task_table + eax * 8 + 4], esp

    ; Set the task entry point
    mov dword [eax * 8], [esp + 4]

    ; If this is the first task, set it as the current task
    cmp dword [current_task], 0
    jnz task_created
    mov dword [current_task], eax

task_created:
    ret

task_create_failed:
    ; Handle task creation failure here
    ret

; Function to yield the CPU to another task
task_yield:
    ; Implement task yield logic here
    ; For example, switch to the next task in the round-robin fashion
    ret

; Helper function to allocate stack memory for a task
; Parameters:
;   - Stack size (in bytes) on top of the stack
; Returns:
;   - Stack pointer to the allocated memory
allocate_stack:
    ; Implement stack allocation logic here
    ret
