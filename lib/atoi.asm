BITS 64

section .text
    global atoi
atoi:
    mov rax,0               ; Set initial total to
    mov rax,0
    mov rax,0

atoi_loop:
    movzx rsi, byte [rdi]   ; Get the current character
    cmp rsi,10              ; Check for \n
    je done

    cmp rsi, 48             ; Anything less than 0 is invalid
    jl error

    cmp rsi, 57             ; Anything greater than 9 is invalid
    jg error

    sub rsi, 48             ; Convert from ASCII to decimal
    imul rax, 10            ; Multiply total by 10
    add rax, rsi            ; Add current digit to total

    inc rdi                 ; Get the address of the next character
    jmp atoi_loop

error:
    mov rax, -1             ; Return -1 on error
done:
    ret                     ; return to the caller
