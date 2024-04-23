section .data
    alphabet: db "", 0x09, "", 0x0A, "", 0x0C, 0x0D, "  !", 0x22, "#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~", 0x7f

section .text
global _print
    ;rsi = string
    ;rdx = length
    _print:
        push rax
        push rcx
        push rdi

        mov rax, 1
        mov rdi, 1
        syscall

        pop rdi
        pop rcx
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

        .loop:
            add rax, 1
            call _input_char

            ; check if it's a newline
            cmp byte [rax], 0x0A
            jne .loop

        pop rdx
        pop rsi
        pop rdi
        pop rax

    ret

global _print_nibble
    ; rax = nibble
    _print_nibble:
        push rax

        and rax, 0x0F
        
        cmp rax, 0x09
        jbe .print_alpha
        jmp .print_int

        .print_alpha:
            add rax, 0x30
            call _printchar
            jmp .end
        
        .print_int:
            add rax, 0x37
            call _printchar
            jmp .end

        .end:

        pop rax
    ret

global _print_reg
    ; rax = register
    _print_reg:
        push rax
        push rbx

        mov rbx, rax
        mov rax, '0'
        call _printchar
        mov rax, 'x'
        call _printchar
        mov rax, rbx

        mov rbx, 0

        .loop1:
            cmp rbx, 16
            je .end

            rol rax, 4
            call _print_nibble

            add rbx, 1
            jmp .loop1

        .end:

        pop rbx
        pop rax
    ret