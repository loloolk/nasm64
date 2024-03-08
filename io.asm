section .data
    alphabet: db "", 0x09, "", 0x0A, "", 0x0C, 0x0D, "  !", 0x22, "#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~", 0x7f
    input_buffer: db 0xff

section .text
global _print
    ;rsi = string
    ;rdx = length
    _print:
        push rax
        push rdi

        mov rax, 1
        mov rdi, 1
        syscall

        pop rdi
        pop rax
        ret


global _newline
    _newline:
        push rax
        
        mov rax, 0x0A
        call _printchar

        pop rax
        ret


global _printchar
    ;rax = char (ascii code)
    _printchar:
        push rdx
        push rsi

        add rax, alphabet - 1

        mov rsi, rax
        mov rdx, 1
        call _print

        pop rsi
        pop rdx
        ret


global _println
    ;rsi = string
    ;rdx = length
    _println:
        call _print

        call _newline

        ret

global _input_char
; rax = address to store input
    _input_char:
        push rax
        push rdi
        push rsi
        push rdx

        mov rsi, rax

        mov rax, 0
        mov rdi, 0
        mov rdx, 1
        syscall

        pop rdx
        pop rsi
        pop rdi
        pop rax
        ret


global _input
; rax = address to store input
    _input:
        push rax
        push rdi
        push rsi
        push rdx

        sub rax, 1

        loop1:
            add rax, 1
            call _input_char

            ; check if it's a newline
            cmp byte [rax], 0x0A
            jne loop1

        pop rdx
        pop rsi
        pop rdi
        pop rax

        ret
