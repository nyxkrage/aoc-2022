BITS 64

section .text
    global print_num

    extern itoa
print_num:
    push rsi
    push rdx

    sub rsp,30            ; reserve 1024 bytes on stack

    mov rax,rdi
    mov rdi,rsp
    call itoa

    mov rdi,1               ; fd (SYS_STDOUT)
    mov rsi,rsp             ; buf
    mov rdx,rax             ; bufsize
    mov rax,1               ; SYS_WRITE
    syscall

    add rsp,30

    pop rdx
    pop rsi
    ret
