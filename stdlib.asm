section .data

section .text
global _malloc
    _malloc:
        push rax

        mov rax, 0x0C
        syscall

        pop rax