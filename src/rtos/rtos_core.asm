section .text
    global task_create
    global task_yield
    global task_suspend
    global task_resume
    global task_delete
    global task_sleep
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
    task_table      times MAX_TASKS db 0    ; Task table to store TCBs
    current_task    dd 0                    ; Pointer to the currently running task

; Function to initialize the RTOS
rtos_init:
    ; Initialize task table
    mov ecx, MAX_TASKS
    xor edi, edi
    xor eax, eax
    rep stosd

    ; Set current task to null
    xor dword [current_task], dword [current_task]

    ret

; Function to create a new task
task_create:
    ; Find a free slot in the task table
    xor eax, eax
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
    test dword [current_task], dword [current_task]
    jnz task_created
    mov [current_task], eax

task_created:
    ret

task_create_failed:
    ; Handle task creation failure here
    ret

; Function to yield the CPU to another task
task_yield:
    ; Save the current task context
    ; Implement context switching logic here
    ; Load the next task context
    ret

; Function to suspend a task
task_suspend:
    ; Implement task suspension logic here
    ret

; Function to resume a suspended task
task_resume:
    ; Implement task resumption logic here
    ret

; Function to delete a task
task_delete:
    ; Implement task deletion logic here
    ret

; Function to make the current task sleep for a specified duration
task_sleep:
    ; Implement task sleep logic here
    ret

; Helper function to allocate stack memory for a task
; Parameters:
;   - Stack size (in bytes) on top of the stack
; Returns:
;   - Stack pointer to the allocated memory
allocate_stack:
    ; Stack size is passed on top of the stack
    ; Pop the stack size parameter
    pop ecx

    ; Allocate memory for the stack
    ; Example using Linux syscall (brk/sbrk) for simplicity
    mov eax, 45         ; brk/sbrk syscall number
    mov ebx, 0          ; Request memory increase
    add ebx, ecx        ; Size of memory to allocate (stack size)
    int 0x80            ; Invoke syscall

    ; Check if allocation was successful
    cmp eax, -1         ; Check if syscall returned -1 (error)
    je allocation_failed

    ; If allocation was successful, eax contains the address of the allocated memory
    ; Adjust the stack pointer to point to the top of the allocated memory
    add eax, ecx        ; Move the stack pointer to the top of the allocated memory

    ret

allocation_failed:
    ; Handle allocation failure here
    ; For example, log an error message or take appropriate action
    ; Return with eax set to 0 (indicating failure)
    xor eax, eax       ; Set eax to 0
    ret
