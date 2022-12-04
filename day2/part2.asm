BITS 64

section .text
    global _start

    extern read_file
    extern print_num
    extern mod3
_start:
    mov rdi,filename
    call read_file

    mov rsi,rax
    mov r8,rax
    mov r9,rbx
    mov rcx,0
    mov rdx,0
    mov rdi,0
score_loop:
    ; read first char
    mov dl, BYTE [rsi]
    cmp dl,0
    je done
    inc rsi
    ; skip space
    inc rsi
    ; read second char
    mov cl, BYTE [rsi]
    inc rsi
    ; skip new line
    inc rsi

    ; check if should be draw
    cmp cl,89
    jne check_lose
    ; must draw
    sub dl,64
    add rdi,3               ; add 3 points for draw
    add rdi,rdx              ; add points based on shape
    jmp score_loop
    
    
    ; check if win and add points
    ; A = 65 = Rock     ; lose=3 ; Win=2
    ; B = 66 = Paper    ; lose=1 ; Win=3
    ; C = 67 = Scissors ; lose=2 ; Win=1
    ; lose
    ; (CHOICE+3 mod 3) + 1
    ; Win
    ; (CHOICE+2 mod 3) + 1
    ; X = 88 = Lose
    ; Y = 89 = Draw
    ; Z = 90 = Win
check_lose:
    cmp cl,88
    jne win
    ; must lose
    ; add points based on losing shape
    push rdi
    mov rdi,rdx
    add rdi,3
    call mod3
    pop rdi
    add rax,1
    add rdi,rax
    jmp score_loop
win:
    push rdi
    mov rdi,rdx
    add rdi,2
    call mod3
    pop rdi
    add rax,1
    add rdi,rax
    add rdi,6
    jmp score_loop

    ; repeat
done:
    call print_num

    mov rdi,r8              ; addr
    mov rsi,r9              ; len
    mov rax,11              ; SYS_MUNMAP
    syscall

    mov rdi,0               ; error_code
    mov rax,60              ; SYS_EXIT
    syscall

section .data
    filename: db "day2/input.txt"
