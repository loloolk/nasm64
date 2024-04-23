; consider changing to 64 bits?
; add 512 limit to loops
section .data 
    _std_mem_brk_start: dq 0 ; 8 bytes
    _std_mem_pointers: dw 512 dup(0)
    _std_mem_sizes: dw 512 dup(0)
    _std_mem_last_pointer: dw 0
    hello: db "Hello, World!", 0x0
    len: equ $ - hello

section .text
    extern _print
    extern _newline
    extern _println
    extern _printchar
    extern _print_reg

    ; ax, index of pointer
    _handle_last_pointer: ; go over sizes
        push rax
        push rbx
        push rcx
        push rdx

        mov rbx, 0
        mov bx, [_std_mem_last_pointer]
        shl rbx, 1 ; rbx = last_pointer * 2 (since its a word)
        shl rax, 1 ; rax = index * 2 (since its a word)\

        cmp ax, bx
        je .if1
        
        lea rcx, [_std_mem_pointers + rax] ; rcx = &pointers[index]
        mov rdx, 0 ; rdx = 0
        mov dx, [_std_mem_pointers + rbx] ; rdx = &pointers[last_pointer]
        mov [rcx], dx

        mov word [_std_mem_pointers + rbx], 0

        lea rcx, [_std_mem_sizes + rax] ; rcx = &sizes[index]
        mov rdx, 0 ; rdx = 0
        mov dx, [_std_mem_sizes + rbx] ; rdx = &sizes[last_pointer]
        mov [rcx], dx

        mov word [_std_mem_sizes + rbx], 0

        jmp .end

        .if1: ; go over again
            add rax, _std_mem_pointers ; rax = &pointers[i]
            mov word [rax], 0 ; pointers[i] = 0

            sub rax, _std_mem_pointers ; rax = i
            
            add rax, _std_mem_sizes ; rax = &sizes[i]
            mov word [rax], 0 ; sizes[i] = 0

            jmp .end

        .end:

        sub word [_std_mem_last_pointer], 1

        pop rdx
        pop rcx
        pop rbx
        pop rax
    ret

    global _alloc
    ; size in ax
    ; returns address in rax
    _alloc:
        push rbx ; index counter
        push rcx ; all purpose
        push rdx ; last_pointer

        push rbp
        mov rbp, rsp
        sub rsp, 16 ; 16 bits / 2 bytes to store the address of the allocated space [loc]
        
        mov rbx, 1 ; rbx = index

        .loop1:
            cmp word [_std_mem_sizes + rbx * 2], 0  ; if sizes[i] == 0
            je .endloop1 ; break

            add ax, 2 ; size += 2
            cmp word [_std_mem_sizes + rbx * 2], ax ; if sizes[i] >= size + 2
            jge .if1 ; jump to if1

            add rbx, 1 ; rbx++
            jmp .loop1 ; continue loop

            .if1:
                mov rcx, 0 ; rcx = 0
                mov cx, [_std_mem_pointers + rbx * 2] ; cx = pointers[i]
                mov [rsp], cx ; loc = pointers[i]

                add rcx, [_std_mem_brk_start] ; rcx = &MEMORY[pointers[i]]
                mov [rcx], ax ; MEMORY[pointers[i]] = size

                cmp word [_std_mem_sizes + rbx * 2], ax ; if sizes[i] == size + 2
                je .if2

                ; else
                add [_std_mem_pointers + rbx * 2], ax ; pointers[i] += size + 2
                sub [_std_mem_sizes + rbx * 2], ax ; sizes[i] += size + 2

            jmp .end

            .if2:
                    
                mov rax, rbx ; rax = i
                call _handle_last_pointer

            jmp .end
        
        .endloop1:
            mov rcx, 0
            mov cx, [_std_mem_pointers] ; rcx = pointers[0]
            mov [rsp], cx ; loc = pointers[0]

            mov rdx, [_std_mem_brk_start] ; rdx = &MEMORY[pointers[0]]
            mov [rdx + rcx], ax ; MEMORY[pointers[0]] = size

            add ax, 2 ; size += 2
            add [_std_mem_pointers], ax ; pointers[0] += size

        .end:

        mov rax, 0
        mov ax, [rsp] ; rax = loc
        add rax, [_std_mem_brk_start] ; rax = &MEMORY[loc]
        
        add rsp, 16
        pop rbp

        pop rdx
        pop rcx
        pop rbx
    ret


    global _dealloc
    ; address in rax, although only the first 16 bits are used
    _dealloc: ; do I need to sub by brk?
        push rax ; address
        push rbx ; index 1
        push rcx ; index 2
        push rdx ; free space

        push rbp
        mov rbp, rsp
        sub rsp, 32
        ; 2 bytes to store the address of the final location [new_loc]
        ; 2 bytes to store the size of the memory block [size]
        mov rdx, 0
        mov dx, [rax] ; bx = size
        add dx, 2 ; bx = size + 2
        mov [rsp + 16], dx ; [size] = size + 2

        sub rax, [_std_mem_brk_start] ; rax = address - brk

        lea dx, [rax + rdx] ; rbx = address + size + 2
        cmp dx, [_std_mem_pointers] ; if address + size + 2 == pointers[0]
        mov [rsp], dx ; new_loc = address + size + 2

        ; rbx becomes 1, index of first loop (i)
        mov rbx, 1

        je .if1

        jmp .loop2

        .if1: ; The new location is equal to the end of the memory
            mov [_std_mem_pointers], ax

            .loop1:
                cmp word [_std_mem_sizes + rbx * 2], 0 ; if sizes[i] == 0
                je .endloop1 ; break

                lea rcx, [_std_mem_pointers + rbx * 2] ; rcx = &pointers[i]
                mov rcx, [rcx] ; rcx = pointers[i]

                lea rdx, [_std_mem_sizes + rbx * 2] ; rdx = &sizes[i]
                mov rdx, [rdx] ; rdx = sizes[i]

                add rcx, rdx ; rcx = pointers[i] + sizes[i]

                cmp rcx, rax ; if pointers[i] + sizes[i] == address
                je .if1_2

                add rbx, 1 ; rax++
                jmp .loop1 ; continue loop

                .if1_2:
                    mov rcx, [_std_mem_pointers + rbx * 2] ; rcx = pointers[i]
                    mov [_std_mem_pointers], rcx ; pointers[0] = pointers[i]

                    mov rax, rbx ; rax = i
                    call _handle_last_pointer

                    jmp .endloop1
            
            .endloop1:
                jmp .end
        
        .loop2: ; start scanning for the new location
            cmp word [_std_mem_sizes + rbx * 2], 0 ; if sizes[i] == 0
            je .endloop2 ; break

            mov cx, [_std_mem_pointers + rbx * 2] ; rcx = pointers[i]
            cmp cx, [rsp] ; if pointers[i] == new_loc
            je .if2

            add cx, [_std_mem_sizes + rbx * 2] ; rcx = pointers[i] + sizes[i]

            cmp cx, ax ; if pointers[i] + sizes[i] == address
            je .if3

            add rbx, 1 ; rbx++
            jmp .loop2 ; continue loop

            .if2:
                mov [_std_mem_pointers + rbx * 2], ax ; pointers[i] = address
                mov cx, [rsp + 16] ; cx = size
                add [_std_mem_sizes + rbx * 2], cx ; sizes[i] += size + 2

                ; cx becomes 1, index of second loop (j)
                mov rcx, 1

                .loop2_1:
                    cmp word [_std_mem_sizes + rcx * 2], 0 ; if sizes[j] == 0
                    je .endloop2_1 ; break

                    mov dx, [_std_mem_pointers + rcx * 2] ; rdx = pointers[j]
                    add dx, [_std_mem_sizes + rcx * 2] ; rdx = pointers[j] + sizes[j]
                    cmp dx, ax ; if pointers[j] + sizes[j] == address
                    je .if2_1

                    add rcx, 1 ; rcx++
                    jmp .loop2_1 ; continue loop

                    .if2_1:
                        mov dx, [_std_mem_sizes + rbx * 2] ; rdx = sizes[i]
                        add [_std_mem_sizes + rcx * 2], dx ; sizes[j] += sizes[i]

                        mov rax, rbx ; rax = i
                        call _handle_last_pointer
                        jmp .endloop2_1
                
                .endloop2_1:
                    jmp .end

            .if3:
                mov cx, [rsp + 16] ; cx = size
                add [_std_mem_sizes + rbx * 2], cx ; sizes[i] += size + 2

                ; cx becomes 1, index of second loop (j)
                mov rcx, 1

                .loop2_2:
                    cmp word [_std_mem_sizes + rcx * 2], 0 ; if sizes[j] == 0
                    je .endloop2_2 ; break

                    mov dx, [_std_mem_pointers + rcx * 2] ; rdx = pointers[j]
                    cmp dx, [rsp] ; if pointers[j] == new_loc
                    je .if2_2

                    add rcx, 1 ; rcx++
                    jmp .loop2_2 ; continue loop

                    .if2_2:
                        mov dx, [_std_mem_sizes + rcx * 2] ; rdx = sizes[j]
                        add [_std_mem_sizes + rbx * 2], dx ; sizes[i] += sizes[j]

                        mov rax, rcx ; rax = j
                        call _handle_last_pointer
                        jmp .endloop2_2

                .endloop2_2:
                    jmp .end


        .endloop2:
            add word [_std_mem_last_pointer], 1 ; last_pointer++
            mov rdx, 0 ; rdx = 0
            mov dx, [_std_mem_last_pointer] ; rdx = last_pointer
            mov [_std_mem_pointers + rdx * 2], ax ; pointers[last_pointer] = address
            mov cx, [rsp + 16] ; cx = size
            mov [_std_mem_sizes + rdx * 2], cx ; sizes[last_pointer] = size

        .end:

        add rsp, 32
        pop rbp

        pop rdx
        pop rcx
        pop rbx
        pop rax
    ret      

global _init_malloc
    _init_malloc:
        push rax
        push rdi

        mov rax, 12
        mov rdi, 0
        syscall

        mov [_std_mem_brk_start], rax

        lea rdi, [rax + 0x1000]
        mov rax, 12
        syscall

        pop rdi
        pop rax
    ret


global _start
    _start:
        call _init_malloc
        mov rax, [_std_mem_brk_start]
        ;call _print_reg
        call _newline

        mov rax, 0x60
        call _alloc
        mov rbx, rax

        mov rax, 0x60
        call _alloc
        mov rcx, rax

        mov rax, 0x60
        call _alloc
        mov rdx, rax

        mov rax, rbx
        call _dealloc

        mov rax, rcx
        call _dealloc

        mov rax, 0x60
        call _alloc

        mov rax, rdx
        call _dealloc

        mov rax, 0x0
        call _newline
        call _newline
        call _newline

        mov ax, [_std_mem_last_pointer]
        call _print_reg
        call _newline

        mov ax, [_std_mem_pointers]
        call _print_reg
        call _newline

        mov ax, [_std_mem_pointers + 2]
        call _print_reg
        call _newline

        mov ax, [_std_mem_sizes]
        call _print_reg
        call _newline

        mov ax, [_std_mem_sizes + 2]
        call _print_reg
        call _newline


        mov rax, 60
        mov rdi, 0
        syscall
