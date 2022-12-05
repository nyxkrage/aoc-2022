BITS 64

section .text
    global char_to_logical_num


char_to_logical_num:
    push rbx
    push rcx
    push rdx
    push rsi
    
    mov rax,0
    sub rdi,38
    cmp rdi,58
    setg al
    mov rbx,58
    mul rbx
    sub rdi,rax
    mov rax,rdi

    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
