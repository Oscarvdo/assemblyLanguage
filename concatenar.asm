section .bss
    nombre resb 50              ; Reserva 50 bytes para el nombre
    apellido resb 50            ; Reserva 50 bytes para el apellido
    nombre_completo resb 101    ; Reserva 101 bytes para el nombre completo

section .data
    prompt_nombre db "Ingrese su nombre: ", 0
    prompt_apellido db "Ingrese su apellido: ", 0
    mensaje_completo db "Nombre completo: ", 0

section .text
    global _start

_start:
    ; Mostrar prompt para el nombre
    mov rax, 1          ; syscall: write
    mov rdi, 1          ; file descriptor: stdout
    mov rsi, prompt_nombre
    mov rdx, 20         ; longitud del prompt
    syscall

    ; Leer el nombre desde stdin
    mov rax, 0          ; syscall: read
    mov rdi, 0          ; file descriptor: stdin
    mov rsi, nombre
    mov rdx, 50         ; máximo 50 bytes
    syscall

    ; Eliminar el salto de línea
    mov rdi, nombre
    call remove_newline

    ; Mostrar prompt para el apellido
    mov rax, 1          ; syscall: write
    mov rdi, 1          ; file descriptor: stdout
    mov rsi, prompt_apellido
    mov rdx, 22         ; longitud del prompt
    syscall

    ; Leer el apellido desde stdin
    mov rax, 0          ; syscall: read
    mov rdi, 0          ; file descriptor: stdin
    mov rsi, apellido
    mov rdx, 50         ; máximo 50 bytes
    syscall

    ; Eliminar el salto de línea
    mov rdi, apellido
    call remove_newline

    ; Copiar nombre a nombre_completo
    mov rsi, nombre
    mov rdi, nombre_completo
    call copy_string

    ; Añadir un espacio
    mov al, ' '
    stosb

    ; Copiar apellido a nombre_completo
    mov rsi, apellido
    call copy_string

    ; Mostrar mensaje "Nombre completo: "
    mov rax, 1          ; syscall: write
    mov rdi, 1          ; file descriptor: stdout
    mov rsi, mensaje_completo
    mov rdx, 17         ; longitud del mensaje
    syscall

    ; Mostrar nombre_completo
    mov rax, 1          ; syscall: write
    mov rdi, 1          ; file descriptor: stdout
    mov rsi, nombre_completo
    mov rdx, 101        ; longitud máxima del nombre completo
    syscall

    ; Salir del programa
    mov eax, 60         ; syscall: exit
    xor edi, edi        ; status: 0
    syscall

remove_newline:
    ; Elimina el salto de línea al final de una cadena
    mov rcx, rdi
    .find_newline:
        cmp byte [rcx], 0x0A
        je .replace_newline
        inc rcx
        jmp .find_newline
    .replace_newline:
        mov byte [rcx], 0
        ret

copy_string:
    ; Copiar cadena de RSI a RDI
    .copy_loop:
        lodsb
        stosb
        test al, al
        jnz .copy_loop
    ret
