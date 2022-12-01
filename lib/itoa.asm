BITS 64

section .text
    global itoa
itoa:
    push rbx
    push rcx
    push rdx

    mov rbx,10              ; Base of the decimal system
    mov rcx,0               ; Accumulator for amount of digits
itoa_div:
    mov rdx,0               ; clear the result register
    div rbx                 ; Divide rax by the number base, in this case 10
    push rdx                ; put the remainder on the stack
    inc rcx                 ; count how many times remainders we have
    cmp rax,0               ; if there was a quotient
    jne	itoa_div            ; keep divinding
    mov rax,rcx             ; keep a copy of the total amount of digits in rax to return
itoa_digit:
    pop rdx                 ; Pop the most recent remainder off the stack
    add rdx,48               ; Convert to a ASCII number, '0' has the number value 48
    mov [rdi],rdx            ; Store in memory
    inc rdi                 ; and increment our pointer to the string memory
    loop itoa_digit         ; loop until there are no more remainders left
                            ; since loop is eqv. to decrementing the rcx register and jumping to the label
    mov byte [rdi],0        ; set the NUL bit at the end of cstrings

    pop	rdx
    pop	rcx
    pop	rbx
    ret                     ; return to the caller
