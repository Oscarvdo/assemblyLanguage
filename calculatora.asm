section .bss
    result resb 10       ; Store the result as a string
    num1 resq 1          ; Store the first number as a 64-bit integer
    num2 resq 1          ; Store the second number as a 64-bit integer

section .text
global _start

_start:
    ; Read the first number from standard input
    mov rdi, num1
    call read_integer

    ; Read the operator (+, -, *, /)
    mov rsi, result
    call read_operator

    ; Read the second number from standard input
    mov rdi, num2
    call read_integer

    ; Perform the operation and store the result in RAX
    mov rax, [num1]
    mov rcx, [num2]
    mov rsi, result
    call perform_operation

    ; Print the result to standard output
    mov rdi, result
    call print_string

    ; Exit
    call exit_program

; Function to read an integer from standard input
read_integer:
    mov rax, 0                  ; syscall number for sys_read
    mov rdi, 0                  ; file descriptor for standard input (stdin)
    mov rdx, 10                 ; maximum input length
    syscall
    xor rax, rax                ; clear RAX
    mov rcx, 10                 ; initialize counter for converting to decimal
.loop:
    mov r8b, byte [rsi + rax]  ; load the next character
    cmp r8b, 10                 ; check if it's a newline (end of input)
    je .found_newline
    sub r8b, '0'                ; convert character to digit
    imul qword [rdi], r8       ; multiply the current number by 10
    add qword [rdi], r8        ; add the digit to the current number
    inc rax                     ; move to the next character
    cmp rax, rdx                ; check if we've read enough characters
    jl .loop                    ; continue reading if we haven't reached the limit
.found_newline:
    ret

; Function to read an operator (+, -, *, /)
read_operator:
    mov rax, 0                  ; syscall number for sys_read
    mov rdi, 0                  ; file descriptor for standard input (stdin)
    mov rdx, 2                  ; maximum input length (1 character + newline)
    syscall
    ret

; Function to perform the operation
perform_operation:
    mov r9, rdi                 ; r9 = address of the result string
    mov rax, [rsi]              ; rax = first number
    mov r8, [rsi + 1]           ; r8 = operator
    mov rcx, [rsi + 2]          ; rcx = second number

    cmp byte [r8], '+'          ; check the operator
    je .addition
    cmp byte [r8], '-'          ; check the operator
    je .subtraction
    cmp byte [r8], '*'          ; check the operator
    je .multiplication
    cmp byte [r8], '/'          ; check the operator
    je .division
    ; If the operator is not valid, exit with an error
    call exit_with_error

.addition:
    add rax, rcx                ; addition
    jmp .save_result

.subtraction:
    sub rax, rcx                ; subtraction
    jmp .save_result

.multiplication:
    imul rax, rcx               ; multiplication
    jmp .save_result

.division:
    xor rdx, rdx                ; clear rdx for division
    idiv rcx                     ; division
    jmp .save_result

.save_result:
    mov rsi, r9                  ; rsi = address of the result string
    mov rdi, rax                ; rdi = result
    call convert_to_string     ; convert the result to a string
    ret

; Function to print a string
print_string:
    mov rax, 0x1                ; syscall number for sys_write
    mov rsi, rdi                ; rsi = address of the string
    mov rdx, 10                 ; length of the string
    add rdx, rdi                ; adjust length to include the null terminator
    sub rdx, rsi                ; calculate the length of the string
    syscall
    ret

; Function to convert a number to a string
convert_to_string:
    mov rax, rdi                ; rax = number to convert
    mov rsi, r9                  ; rsi = address of the result string
    mov rcx, 10                 ; divisor (base 10)
    add rsi, 10                 ; move rsi to the end of the string
    mov byte [rsi], 0          ; set the null terminator at the end of the string

.reverse_loop:
    dec rsi                     ; move backward in the string
    xor rdx, rdx                ; clear rdx for division
    div rcx                     ; divide rax by 10, result in rax, remainder in rdx
    add dl, '0'                 ; convert the digit to a character
    mov [rsi], dl               ; store the character in the string

    test rax, rax              ; check if rax is 0 (end of conversion)
    jnz .reverse_loop           ; if not, continue the conversion
    ret

; Function to exit the program
exit_program:
    mov rax, 60                 ; syscall number for sys_exit
    xor rdi, rdi                ; exit code 0
    syscall

; Function to exit with an error code
exit_with_error:
    mov rax, 60                 ; syscall number for sys_exit
    mov rdi, 1                  ; exit code 1 (error)
    syscall
