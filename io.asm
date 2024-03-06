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

global _input
; rax = address to store input
    _input:
        push rbp
        mov rbp, rsp
        sub rsp, $16

        mov qword [rbp], 0 ; offset
        mov [rbp - $8], rax ; address to store input

        push rdi
        push rsi
        push rdx

        loop1:
            ; read 1 byte from stdin
            mov rax, 0
            mov rdi, 0
            mov rsi, input_buffer
            mov rdx, 1
            syscall

            mov rax, [rbp] ; number to offset
            mov rdi, [rbp - $8] ; address to store input
            mov dl, [input_buffer] ; input
            mov byte [rdi + rax], dl ; store input

            add qword [rbp], 1

            ; check if it's a newline
            cmp byte [input_buffer], 0x0A
            jne loop1

        pop rdx
        pop rcx
        pop rbx

        mov rax, [rbp - $8] ; address to store input

        add rsp, $16
        pop rbp
        ret
