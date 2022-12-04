BITS 64

section .text
    global mod3
mod3:
    push rcx
    push rdx

    ; https://ridiculousfish.com/blog/posts/labor-of-division-episode-i.html
    mov     eax, edi
    mov     edx, 2863311531
    imul    rax, rdx
    shr     rax, 33
    lea     eax, [rax+rax*2]
    sub     edi, eax
    mov     eax, edi
    
    pop rdx
    pop rcx
    ret
