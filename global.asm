section .data

section .text
global _exit
    _exit:
        mov rax, 60
        xor edi, edi
        syscall
