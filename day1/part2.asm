BITS 64

section .text
    global _start

    extern atoi
    extern print_num
_start:
; TODO: FIX USING READ_FILE
    mov rdi,filename        ; filename
    mov rsi,0               ; flags
    mov rdx,0               ; mode
    mov rax,2               ; SYS_OPEN
    syscall

    sub rsp,12000        ; reserve 1024 bytes on stack

	mov rdi,rax             ; fd
	mov rsi,rsp             ; buf
	mov rdx,12000         ; bufsize
    mov rax,0               ; system call (read)
	syscall

    mov rax,3               ; SYS_CLOSE
    syscall

    ; convert to int and sum
    ; until empty line
    ; compare with previous group
    ; if larger keep the new sum
    ; otherwise store new sum
    ; then repeat
    mov r8,0                ; initialize running sum as 0
    mov r9,0                ; the largest sum
    mov r10,0                ; the largest sum
    mov r11,0                ; the largest sum
    mov rdi,rsp             ; str
read_group:
    call atoi               ; convert to number
    inc rdi                 ; skip the newline that is left from atoi
    add r8,rax              ; add to sum
    movzx rsi, byte [rdi]   ; Get the current character
    cmp rsi,10              ; Check for \n
    je next_group           ; Start on new group
    cmp rsi,0              ; Check for \n
    je next_group           ; Start on new group
    jmp read_group          ; otherwise keep going

next_group:
    inc rdi                 ; skip the newline
    cmp r8,r9               ; compare running sum and greatest sum
    jge first_greatest
    cmp r8,r10              ; compare running sum and second greatest sum
    jge second_greatest
    cmp r8,r11              ; compare running sum and third greatest sum
    jge third_greatest
    jmp finish_greatest
first_greatest:
    mov r11,r10
    mov r10,r9
    mov r9,r8
    jmp finish_greatest
second_greatest:
    mov r11,r10
    mov r10,r8
    jmp finish_greatest
third_greatest:
    mov r11,r8
    jmp finish_greatest

finish_greatest:
    mov r8,0                ; reset the running sum
    cmp rsi,0               ; null byte we have reached the end of the string
    je done                 
    jmp read_group

    

done:
    add r9,r11
    add r9,r10
    mov rdi,r9
    call print_num

    mov rdi,0               ; error_code
    mov rax,60              ; SYS_EXIT
    syscall

section .data
    filename: db "day1/input.txt"
