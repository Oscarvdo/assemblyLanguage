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

    ; Almacena el carácter leído en guessed_word
    mov [guessed_word], al

    ret

; Función para manejar entrada no válida
invalid_input:
    ; Esta función maneja el caso de entrada no válida, puedes personalizarla según tus necesidades
    ; Puedes mostrar un mensaje de error o realizar cualquier otra acción que desees
    ; Luego, vuelve al bucle principal del juego
    ret

; Función para verificar si la letra está en la palabra
check_guess:
    ; Carga la letra adivinada desde guessed_word
    mov al, [guessed_word]

    ; Inicializa el puntero a la palabra
    mov rsi, word

    ; Inicializa el contador a cero
    xor rcx, rcx

    ; Comienza a comparar la letra adivinada con las letras de la palabra
    .compare_loop:
        ; Lee una letra de la palabra
        mov bl, [rsi + rcx]

        ; Comprueba si hemos llegado al final de la palabra
        cmp bl, 0
        je .not_found

        ; Compara la letra adivinada con la letra de la palabra (mayúsculas)
        cmp al, bl
        je .found

        ; Compara la letra adivinada con la letra de la palabra (minúsculas)
        sub bl, 32  ; Convierte a mayúscula
        cmp al, bl
        je .found

        ; Si no se encontró la letra, continúa con la siguiente
        inc rcx
        jmp .compare_loop

    .found:
        ; Actualiza la letra adivinada en guessed_word
        mov [guessed_word], al

    .not_found:
        ret

; Función para verificar si el juego ha terminado
check_game_over:
    ; Compara la palabra adivinada (guessed_word) con la palabra original (word)
    ; Compara también el número de intentos restantes (attempts) con cero
    ; Actualiza el estado del juego y muestra un mensaje de victoria o derrota si es necesario

    ; Compara la palabra adivinada con la palabra original
    mov rsi, guessed_word
    mov rdi, word
    mov rcx, [word_length]
    repe cmpsb

    ; Verifica si las cadenas son iguales
    je .word_found

    ; Si no son iguales, decrementa el número de intentos restantes
    dec byte [attempts]

    ; Verifica si se agotaron los intentos
    cmp byte [attempts], 0
    je .game_over_loss

    ret

.word_found:
    ; Verifica si se ha adivinado la palabra completa
    cmp byte [rsi], 0
    je .game_over_win

    ret

.game_over_loss:
    ; Implementa la lógica para el juego perdido (puedes mostrar un mensaje de derrota)
    ; Actualiza el estado del juego según corresponda
    ; Luego, vuelve al bucle principal del juego
    ret

.game_over_win:
    ; Implementa la lógica para el juego ganado (puedes mostrar un mensaje de victoria)
    ; Actualiza el estado del juego según corresponda
    ; Luego, vuelve al bucle principal del juego
    ret

 
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

    ; Almacena el carácter leído en guessed_word
    mov [guessed_word], al

    ret

.invalid_input:
    ; Maneja el caso de entrada no válida (puedes mostrar un mensaje de error)
    ret

; Función para verificar si la letra está en la palabra
check_guess:
    ; Carga la letra adivinada desde guessed_word
    mov al, [guessed_word]

    ; Inicializa el puntero a la palabra
    mov rsi, word

    ; Inicializa el contador a cero
    xor rcx, rcx

    ; Comienza a comparar la letra adivinada con las letras de la palabra
    .compare_loop:
        ; Lee una letra de la palabra
        mov bl, [rsi + rcx]

        ; Comprueba si hemos llegado al final de la palabra
        cmp bl, 0
        je .not_found

        ; Compara la letra adivinada con la letra de la palabra (mayúsculas)
        cmp al, bl
        je .found

        ; Compara la letra adivinada con la letra de la palabra (minúsculas)
        sub bl, 32  ; Convierte a mayúscula
        cmp al, bl
        je .found

        ; Si no se encontró la letra, continúa con la siguiente
        inc rcx
        jmp .compare_loop

    .found:
        ; Actualiza la letra adivinada en guessed_word
        mov [guessed_word], al

    .not_found:
        ret

; Función para verificar si el juego ha terminado
check_game_over:
    ; Compara la palabra adivinada (guessed_word) con la palabra original (word)
    ; Compara también el número de intentos restantes (attempts) con cero
    ; Actualiza el estado del juego y muestra un mensaje de victoria o derrota si es necesario

    ; Compara la palabra adivinada con la palabra original
    mov rsi, guessed_word
    mov rdi, word
    mov rcx, [word_length]
    repe cmpsb

    ; Verifica si las cadenas son iguales
    je .word_found

    ; Si no son iguales, decrementa el número de intentos restantes
    dec byte [attempts]

    ; Verifica si se agotaron los intentos
    cmp byte [attempts], 0
    je .game_over_loss

    ret

.word_found:
    ; Verifica si se ha adivinado la palabra completa
    cmp byte [rsi], 0
    je .game_over_win

    ret

.game_over_loss:
    ; Implementa la lógica para el juego perdido (puedes mostrar un mensaje de derrota)
    ; Actualiza el estado del juego según corresponda
    ; Luego, vuelve al bucle principal del juego

    ; Puedes personalizar esta parte para mostrar un mensaje de derrota o realizar cualquier otra acción
    ; Aquí, simplemente imprimiremos un mensaje de derrota y reiniciaremos el juego.

    mov rax, 1        ; syscall number for sys_write
    mov rdi, 1        ; File descriptor 1 (stdout)
    lea rsi, [loss_msg]
    mov rdx, loss_msg_length
    syscall

    ; Reiniciar el juego (puedes agregar la lógica para reiniciar aquí)
    call init_game

    ret

.game_over_win:
    ; Implementa la lógica para el juego ganado (puedes mostrar un mensaje de victoria)
    ; Actualiza el estado del juego según corresponda
    ; Luego, vuelve al bucle principal del juego

    ; Puedes personalizar esta parte para mostrar un mensaje de victoria o realizar cualquier otra acción
    ; Aquí, simplemente imprimiremos un mensaje de victoria y reiniciaremos el juego.

    mov rax, 1        ; syscall number for sys_write
    mov rdi, 1        ; File descriptor 1 (stdout)
    lea rsi, [win_msg]
    mov rdx, win_msg_length
    syscall

    ; Reiniciar el juego (puedes agregar la lógica para reiniciar aquí)
    call init_game

    ret

section .data
    ; Agrega mensajes personalizados para victoria y derrota según tu preferencia
    loss_msg db "Has perdido. ¡Inténtalo de nuevo!", 10
    loss_msg_length equ $ - loss_msg

    win_msg db "¡Felicidades! Has ganado.", 10
    win_msg_length equ $ - win_msg


 

