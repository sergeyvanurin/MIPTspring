;nasm -f  macho64 -g printf.asm
;ld -macosx_version_min 10.7.0 -lSystem -o printf printf.o
global start
;------------------------------------------------------------------------------------------
section .data
print_buffer: times 256 db 1
                        db 0
number_buffer: times 32 db 0
msg: db 'I %s %x. %d%%%c%b', 0
string1: db 'love', 0

jump_table:
            dq binary_case                                 ; b
            dq char_case                                   ; c
            dq integer_case                                ; d
            times ('h' - 'e' + 1) dq default_case          ; e f g h (4 буквы)
            dq integer_case                                ; i
            times ('n' - 'j' + 1) dq default_case          ; j k l m n (5 букв)
            dq octa_case                                   ; o 
            times ('r' - 'p' + 1) dq default_case          ; p q r (3 буквы)
            dq string_case                                 ; s
            times ('w' - 't' + 1) dq default_case          ; t u v w (4 буквы)
            dq hex_case                                    ; x
;------------------------------------------------------------------------------------------

section .text

;-------------------------------------константы--------------------------------------------
BUFFER_BOUND equ 0
ALPHABET_OFFSET equ 'b'
SYSCALL_EXIT equ 0x2000001
SYSCALL_OUT equ 0x2000004
ARG_OFFSET equ 2
HEX_LETTER_OFFSET equ 7
JMP_TABLE_UPPER_BOUND equ 22
;------------------------------------------------------------------------------------------

start:
            push 127                         ;
            push '!'                         ;
            push -100                        ; 
            push 3802                        ;
                                             ; } передача аргументов и вызов функции printf
            lea rax, [rel string1]           ;
            push rax                         ;
                                             ;
            lea rax, [rel msg]               ;
            push rax                         ;
            call printf                      ;

            mov rax, SYSCALL_EXIT            ;
            mov rbx, 0                       ; } выход
            syscall                          ;

;==========================================================================================
;функция printf (format_string, arg1, ...);
;Печетает форматную строчку
;
;in: в соответствии c формамтной строчкой
;dest: rax, rbx, rcx, rdx, rsi, rdi, r8, r10, r11, r12
;==========================================================================================
printf:
            push rbp                        ;сохранение rbp
            mov rbp, rsp                    ;смещение rsp в rbp

            mov r11, ARG_OFFSET             ;создание счетчика аргументов
            lea r12, [rel jump_table]       ;адрес таблицы прыжков

            mov rsi, [rbp + r11 * 8]        ;указатель на строчку 
            lea rdi, [rel print_buffer]     ;указатель на буффер
            inc r11                         ;увеличение счетчика аргументов

loop_start:
            cmp byte [rsi], byte 0          ;проверка на конец форматной строчки
            je loop_ending

            cmp byte [rdi], BUFFER_BOUND             ;проверка на конец буфера
            jne .no_overflow                ;выгрузка если конец
            call dump_buffer

.no_overflow:
            cmp byte [rsi], '%'             ;поиск форматных идентификаторов
            je printf_argument
			
            movsb                           ;передвижение символов в буффер

			jmp loop_start                  ;

loop_ending:
            call dump_buffer                ;выгрузка буффера  

            mov rsp, rbp                    ;
            pop rbp                         ; } возвращение стека в первоначальный вид и выход из функции

            ret

printf_argument:
            inc rsi                         ;передвижение каретки на идентификатор 

            xor rcx, rcx                    ;обнуление rcx

            mov cl, byte [rsi]              ;
            sub cl, ALPHABET_OFFSET         ; } вычисление смещения для таблицы прыжков
            cmp cl, JMP_TABLE_UPPER_BOUND   ; 
            ja default_case                 ;

            mov rax, [rbp + r11 * 8]        ;перемещние в rax аргумента из стека
            inc r11                         ;смещение на след. аргумент
            
            mov rcx, [r12 + rcx * 8]        ;помешение в rcx нужного адреса из таблицы перехода
            jmp rcx                         ;переход на нужный кейс

default_case:                           
            cmp byte [rsi], '%'             ;проверка на % кейс
            je percentage_case              

argument_end:
            inc rsi                         ;передвижение каретки на след. символ
            jmp loop_start                  ;возврат к обработке форматной строки

percentage_case:
            mov [rdi], byte '%'             ;
            inc rdi                         ; } перенос '%' в буффер
            jmp argument_end                ;
            
string_case:
            cmp byte [rax], 0               ;проверка конца строчки 
            je argument_end                 ;возврат если конец

            cmp byte [rdi], BUFFER_BOUND             ;
            jne .no_overflow                ; } проверка буффера на переполнение
            call dump_buffer                ;

.no_overflow: 
            mov r10b, [rax]                 ;
            mov [rdi], r10b                 ;
            inc rdi                         ; } перенос символов из строки в буфер
            inc rax                         ;

            jmp string_case                 

char_case:
            cmp byte [rdi], BUFFER_BOUND             ;
            jne .no_overflow                ; } проверка буфера на переполнение
            call dump_buffer                ;

.no_overflow:
            mov byte [rdi], al              ;
            inc rdi                         ; } перенос символа в буфер и возврат
            jmp argument_end                ;

integer_case:
            xor rcx, rcx                    ;обнуление rcx
            lea rbx, [rel number_buffer]    ;перенос в rbx адрес числового буффера
            mov r8, 10

division_loop:
            xor rdx, rdx                    ;обнуление rdx
            div r8                          ;деление на 10
            add rdx, '0'                    ;перевод в ascii символ

            mov [rbx], dl                   ;перемещние цифры в числовой буфер
            inc rbx
            inc rcx                         ;inc счетчика цифр

            cmp rax, 0                      ;проверка на последнюю цифру
            jne division_loop

            dec rbx
            call number_print 
            jmp argument_end

binary_case:
            mov cl, 1                       ;перенос base в cl
            call decimal_to_baseN

            jmp argument_end

octa_case:
            mov cl, 3                       ;перенос base в cl
            call decimal_to_baseN

            jmp argument_end

hex_case:
            mov cl, 4                      ;перенос base в cl
            call decimal_to_baseN

            jmp argument_end

;==========================================================================================
;функция decimal_to_baseN(base_power)
;переводит десятичное число в другую систему счисления с базой N = 2 ^ base_power
;
;in: cl - степень двойки, eax - десятичное число
;dest: rdx, rcx, rax, rbx, 
;==========================================================================================
decimal_to_baseN:
            xor dh, dh
            lea rbx, [rel number_buffer]

            mov ch, 1                       ;
            shl ch, cl                      ; } создание маски в ch
            dec ch                          ;

mask_loop:
            mov dl, al                      ;перенос al в dl
            and dl, ch                      ;применение маски на dl

            add dl, '0'                     ;перевод в ascii символ
            cmp dl, '9'                     ;проверка на букву (hex кейс)
            jng not_letter
            add dl, HEX_LETTER_OFFSET       ;смещение если буква

not_letter:
            mov [rbx], dl                   ;перемещение в числовой буфер
            inc rbx
            inc dh

            shr eax, cl                     ;сдвиг к след. цифре

            cmp eax, 0                      ;проверка на конец числа
            jne mask_loop

            xor rcx, rcx                    ;
            mov cl, dh                      ; } создание счетчика

            dec rbx
            call number_print           
            
            ret

;==========================================================================================
;функция number_print(int counter)
;выводит number_buffer в print_buffer в нужном порядке
;
;in: rcx - кол-во цифр, rdi - указатель на print_buffer, rbx - указатель на number_buffer
;dest: rax
;==========================================================================================
number_print:
            cmp byte [rdi], BUFFER_BOUND    ;
            jne .no_overflow                ; } проверка на переполнение 
            call dump_buffer                ;

.no_overflow:
            mov al, [rbx]                   ;
            mov [rdi], al                   ;
            inc rdi                         ; } перемещние числа в прямом порядке в буффер
            dec rbx                         ;
            loop number_print               ;

            ret

;==========================================================================================
;функция dump_buffer()
;выводит содержимое буффера на экран 
;
;in: rdi - указатель на буффер
;==========================================================================================
dump_buffer:
            push rcx
            push rbx
            push rax
            push rdx
            push rsi                        
            push r11

            mov rdx, rdi                    
            lea rsi, [rel print_buffer]     ;
            sub rdx, rsi                    ;  расчет длины буфера 
            mov rdi, 1                      ;
            mov rax, SYSCALL_OUT            ;  вывод буфера длины rdx из rsi
            syscall                         ;

            lea rdi, [rel print_buffer]

            pop r11
            pop rsi                         
            pop rdx
            pop rax
            pop rbx
            pop rcx

            ret