BITS 64

section .text
    global _start

    extern read_file
    extern print_num
    extern dbg_num
    extern dbg_char
_start:
    mov rdi,filename
    call read_file

    mov rsi,rax
    mov r8,rax
    mov r9,rbx
    mov rcx,0
    mov rax,0
    mov rbx,0
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

    ; add points based on shape
    add rdi,rcx
    sub rdi,87
    ; check if draw and add points
    sub cl,23
    cmp dl,cl
    jne check_winner
    add rdi,3
    jmp score_loop
    
    ; check if win and add points
    ; A = 65 = Rock
    ; B = 66 = Paper
    ; C = 67 = Scissors
    ; X = 88 = Rock
    ; Y = 89 = Paper
    ; Z = 90 = Scissors
check_winner:
    ; rdi    bit0 is whether dl is rock
    ; flags bit0 is whether cl is paper
    ; if both then player b wins 
    cmp dl,65
    setz al
    cmp cl,66
    setz ah
    and al,ah

    cmp dl,66
    setz ah
    cmp cl,67
    setz bl
    and ah,bl
    or al,ah

    cmp dl,67
    setz ah
    cmp cl,65
    setz bl
    and ah,bl
    or al,ah
    test al,1
    jnz win

    jmp score_loop
win:
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
