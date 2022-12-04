BITS 64

section .text
    global read_file

    ;; char* read_file(char* filename);
read_file:
    push rdi    ; 48
    push rsi    ; 40
    push rdx    ; 32
    push r8     ; 24
    push r9     ; 16
    push r10    ; 8

    ;; open file
    mov rdi,QWORD [rsp+40]  ; filename
    mov rsi,0               ; flags
    mov rdx,0               ; mode
    mov rax,2               ; SYS_OPEN
    syscall
    mov r8,rax              ; store fd in r8 for later use in mmap

    ;; stat file
    sub rsp,144             ; reserve space on stack for statbuf
    
    mov rdi,r8
    lea rsi,[rsp]
    mov rax,5
    syscall

    ;; mmap file
    mov rdi,0               ; addr (NULL)
    mov esi,DWORD [rsp+48]  ; len
    mov rdx,1               ; prot (PROT_READ)
    mov r10,2               ; flags (MAP_PRIVATE)
                            ; fd (already in r8)
    mov r9,0                ; off
    mov rax,9               ; SYS_MMAP
    syscall
    push rax

    ;; close file
    mov rdi,r8              ; fd
    mov rax,3               ; SYS_CLOSE
    syscall
    pop rax
    mov rbx,r8

    add rsp,144

    pop r10
    pop r9
    pop r8
    pop rdx
    pop rsi
    pop rdi
    ret
