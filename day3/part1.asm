BITS 64

section .text
    global _start

    extern read_file
    extern print_num
    extern char_to_logical_num
_start:
    mov rdi,filename
    call read_file
    mov rsi,rax
    mov r14,rax
    mov r15,rbx

    ; sum=0
    ; for line in lines
    ;   len=0
    ;   for char in line
    ;     len+1
    ;     if char == '\0'
    ;       goto end
    ;   check_len=len/2
    ;   for i=0 i<check_len i++
    ;     for j=check_len j<len j++
    ;       first_char = line[i]
    ;       if first_char == line[j]
    ;         if first_char > 'a'
    ;           sum+'a'-96
    ;           goto next_line
    ;         if first_char > 'A'
    ;          sum+'a'-64
    ;          goto next_line
    ; print sum

    mov r8,0                ; sum
    mov rbx,0               ; char buffer
    mov rcx,0               ; line length
    mov rdx,0               ; check length
lines_loop:

len_loop:
    mov bl,[rsi+rcx]        ; get current char
    inc rcx
    cmp bl,0                ; end of string
    je done
    cmp bl,10               ; new line
    jne len_loop

    dec rcx                 ; go back to beginning of line

    mov rdx,rcx
    shr rdx,1               ; divide line length by 2

    ; set up i
    mov r9,0
outer_loop:
    ; set up j
    mov r10,rdx
inner_loop:
    mov bl,[rsi+r9]
    cmp bl,[rsi+r10]
    jne continue
    mov rdi,rbx
    call char_to_logical_num
    add r8,rax
    add rsi,rcx
    jmp lines_loop

continue:
    inc r10
    cmp r10,rcx
    jl inner_loop

    inc r9
    cmp r9,rdx
    jl outer_loop

    jmp lines_loop

done:
    mov rdi,r8
    call print_num

    ; SYS_MUNMAP
    mov rdi,r14
    mov rsi,r15
    mov rax,11
    syscall

    ; SYS_EXIT
    mov rdi,0
    mov rax,60
    sycall

section .data
    filename: db "day3/test.txt"
