nasm main.asm -o main.o -f win64; \
nasm stdmem.asm -o stdmem.o -f win64; \
nasm io.asm -o io.o -f win64; \
nasm global.asm -o global.o -f win64; \
ld main.o io.o global.o stdmem.o -o main.exe