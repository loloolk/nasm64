section .data
global _brk_start
    _brk_start: dq 0
    _heap_allocations: dq 0

section .text
global _init_malloc
    _init_malloc:
        push rax
        push rdi

        push rbp
        mov rbp, rsp

        mov rax, 12
        mov rdi, 0
        syscall

        mov [_brk_start], rax

        pop rbp

        pop rdi
        pop rax
        ret

global _malloc
; rdi = size
; returns in rax
    _malloc:
        push rdi

        mov rax, [_brk_start]

        lea rdi, [rax + rdi]
        mov rax, 12
        syscall

        mov [_brk_start], rax

        pop rdi
        ret

global _exit
    _exit:
        mov rax, 60
        xor edi, edi
        syscall
