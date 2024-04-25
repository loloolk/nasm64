section .data
    hello: db "Hello, World!", 0x0
    len: equ $ - hello

    goodbye: db "Goodbye, World!", 0x0
    len2: equ $ - goodbye

section .text
    extern _init_alloc
    extern _alloc
    extern _dealloc
    extern _mem_status

    extern _print
    extern _newline
    extern _println
    extern _printchar
    extern _print_nibble
    extern _print_reg

    extern _input
    
    extern _exit

global _start
    _start:
        call _init_alloc

        mov rsi, hello
        mov rdx, len
        call _println

        mov rax, 10
        call _alloc
        mov rbx, rax

        call _input

        mov rsi, rbx
        mov rdx, 10
        call _println

        mov rax, 10
        call _alloc
        mov rcx, rax

        call _input

        mov rsi, rcx
        mov rdx, 10
        call _println

        mov rsi, rbx
        mov rdx, 10
        call _println

        mov rax, rbx
        call _dealloc

        mov rax, rcx
        call _dealloc

        call _mem_status
            
        call _exit

