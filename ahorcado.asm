section .data
    word db "HELLO", 0     ; Palabra a adivinar (cambia esto)
    max_attempts equ 6     ; Número máximo de intentos

section .bss
    guessed_word resb 32   ; Almacenar las letras adivinadas
    attempts resb 1        ; Contador de intentos
    word_length resb 1     ; Longitud de la palabra

section .text
global _start

_start:
    ; Inicializar el juego
    call init_game

game_loop:
    ; Dibujar la palabra oculta y las letras adivinadas
    call draw_game

    ; Leer la letra adivinada del usuario
    call read_guess

    ; Verificar si la letra está en la palabra
    call check_guess

    ; Verificar si el juego ha terminado
    call check_game_over

    ; Volver al bucle principal del juego
    jmp game_loop

; Función para inicializar el juego
init_game:
    ; Inicializar variables globales
    mov rsi, word
    call strlen
    mov [word_length], al
    mov byte [attempts], 0
    mov byte [guessed_word], 0
    ret

; Función para dibujar la palabra oculta y las letras adivinadas
; Función para dibujar la palabra oculta y las letras adivinadas
draw_game:
    ; Borra la pantalla o la consola (dependiendo de tu plataforma)
    ; Puedes usar interrupciones de sistema para borrar la pantalla
    ; Dibuja la palabra oculta con letras adivinadas y muestra el número de intentos restantes

    ; Muestra la palabra oculta con letras adivinadas
    mov rsi, guessed_word  ; Dirección de la cadena de letras adivinadas
    mov rdi, guessed_word_length  ; Longitud de la cadena de letras adivinadas
    call print_string  ; Llama a una función para imprimir la cadena

    ; Dibuja las letras no adivinadas como "_"
    mov rsi, word
    mov rdi, guessed_word
    call draw_hidden_letters

    ; Muestra el número de intentos restantes
    mov rax, 1  ; syscall number for sys_write
    mov rdi, 1  ; File descriptor 1 (stdout)
    lea rsi, [attempts_remaining_msg]
    mov rdx, attempts_remaining_msg_length
    syscall

    ret

; Función para dibujar letras no adivinadas como "_"
draw_hidden_letters:
    xor rcx, rcx  ; Inicializa el contador a cero
    mov al, [rsi + rcx]  ; Lee la primera letra de la palabra oculta
    .draw_loop:
        cmp al, 0  ; Comprueba si hemos llegado al final de la palabra
        je .done
        mov byte [rdi + rcx], '_'  ; Reemplaza la letra no adivinada por "_"
        inc rcx  ; Incrementa el contador
        mov al, [rsi + rcx]  ; Lee la siguiente letra de la palabra
        jmp .draw_loop
    .done:
    ret

; Función para imprimir una cadena en la consola
print_string:
    ; Esta función recibe la dirección de la cadena en rsi
    ; y la longitud de la cadena en rdi
    ; Utiliza la interrupción de sistema adecuada para imprimir la cadena en la consola
    ret

; Otras declaraciones de datos y funciones auxiliares según sea necesario
...


; Función para leer la letra adivinada del usuario
; Función para leer la letra adivinada del usuario
read_guess:
    ; Reserva espacio para almacenar la letra adivinada
    mov rsi, guessed_word  ; Dirección de guessed_word
    mov rdx, 1            ; Leer un solo carácter
    mov rax, 0            ; syscall number for sys_read
    mov rdi, 0            ; File descriptor 0 (stdin)
    syscall

    ; Verifica si se ha leído un carácter válido
    cmp rax, 1            ; Comprueba si se leyó un carácter
    jne .invalid_input    ; Salta si no se leyó un carácter válido

    ; Verifica si la letra es una letra minúscula y la convierte a mayúscula si es necesario
    mov al, [guessed_word] ; Carga la letra adivinada
    cmp al, 'a'            ; Comprueba si es una letra minúscula
    jl .store_guess        ; Salta si no es una letra minúscula
    cmp al, 'z'            ; Comprueba si es una letra minúscula
    jg .store_guess        ; Salta si no es una letra minúscula
    sub al, 32             ; Convierte a mayúscula
    mov [guessed_word], al ; Almacena la letra adivinada en mayúscula

.store_guess:
    ; Incrementa el puntero en guessed_word para la próxima letra
    inc rsi
    ret

.invalid_input:
    ; Maneja el caso de entrada no válida (puedes mostrar un mensaje de error)
    ret


; Función para verificar si la letra está en la palabra
check_guess:
    ; Implementa la lógica para verificar si la letra adivinada está en la palabra
    ; Actualiza [guessed_word] y [attempts] según corresponda
    ret

; Función para verificar si el juego ha terminado
check_game_over:
    ; Implementa la lógica para verificar si el juego ha terminado (ganado o perdido)
    ; Puedes utilizar [attempts] y [guessed_word] para determinar el estado del juego
    ret

; Otras funciones auxiliares según sea necesario
...
; Función para dibujar la palabra oculta y las letras adivinadas
draw_game:
    ; Borra la pantalla o la consola (dependiendo de tu plataforma)
    ; y dibuja la palabra oculta con letras adivinadas
    ; Usa caracteres "_" para letras no adivinadas
    ; y muestra el número de intentos restantes
    ; Puedes usar las interrupciones de sistema adecuadas para borrar y mostrar texto en la pantalla
    ret

; Función para leer la letra adivinada del usuario
read_guess:
    ; Lee una letra del usuario desde la entrada estándar (teclado)
    ; y almacena la letra adivinada en [guessed_word]
    ; Puedes usar interrupciones de sistema para leer caracteres desde la entrada estándar
    ; y almacenarlos en [guessed_word]
    ret

; Función para verificar si la letra está en la palabra
check_guess:
    ; Verifica si la letra adivinada está en la palabra oculta ([word])
    ; Si la letra está en la palabra, actualiza [guessed_word]
    ; Si no está en la palabra, incrementa [attempts]
    ; También verifica si el juego ha sido ganado o perdido
    ; y actualiza el estado del juego en consecuencia
    ret

; Función para verificar si el juego ha terminado
check_game_over:
    ; Verifica si el juego ha terminado (ganado o perdido)
    ; Puedes usar [attempts] y [guessed_word] para determinar el estado del juego
    ; y compararlos con la palabra oculta ([word])
    ; Actualiza el estado del juego y muestra un mensaje de victoria o derrota si es necesario
    ret

