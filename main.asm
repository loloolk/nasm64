section .data
    hello: db "Hello, World!", 0x0
    len: equ $ - hello

    goodbye: db "Goodbye, World!", 0x0
    len2: equ $ - goodbye

section .text
    extern _brk_start
    extern _init_malloc
    extern _malloc
    extern _exit

    extern _print
    extern _newline
    extern _println
    extern _printchar
    extern _print_nibble
    extern _print_reg

    extern _input

global _start
    _start:
        call _init_malloc

        mov rsi, hello
        mov rdx, len
        call _println

        mov rdi, 10
        call _malloc

        push rax
        call _print_reg
        call _newline
        pop rax

        call _input

        mov rsi, rax
        mov rdx, 10
        call _println

        mov rdi, 10
        call _malloc

        call _input

        mov rsi, rax
        mov rdx, 10
        call _println

        mov rdi, -10
        call _malloc

        mov rsi, rax
        mov rdx, 10
        call _println
            
        call _exit

