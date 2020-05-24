all: printf

printf: printf.o tests.o
	ld -macosx_version_min 10.7.0 -lSystem -o printf tests.o printf.o

printf.o: printf.asm
	nasm -f  macho64 -g printf.asm

tests.o: tests.asm
	nasm -f  macho64 -g tests.asm