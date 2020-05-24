extern my_printf
global start
;------------------------------------------------------------------------------------------------------
SYSCALL_EXIT            equ 0x2000001
SYSCALL_OUT             equ 0x2000004
NEW_LINE                equ 0Ah
;------------------------------------------------------------------------------------------------------
section .data
;------------------------------------------------------------------------------------------------------
msg1:                   db 'I %s %x. %d%%%c%b%c', 0
string1:                db 'love', 0
target1:                db "TARGET1: I love EDA. 100%!11111111", NEW_LINE, 0
target1Len              equ $ - target1

msg2:                   db 'This is a %s%c', 0
string2:                db 'TEST', 0
target2:                db "TARGET2: This is a TEST", NEW_LINE, 0
target2Len              equ $ - target2

msg3:                   db 'decimal:%d binary:%b octal:%o hex:%x%c', 0
target3:                db "TARGET3: decimal:1337 binary:10100111001 octal:2471 hex:539", NEW_LINE, 0
target3Len              equ $ - target3
;------------------------------------------------------------------------------------------------------
section .text

start:
            push NEW_LINE
            push 127
            push '!'                        
            push 100                        
            push 3802                                               
            lea rax, [rel string1]          
            push rax                               
            lea rax, [rel msg1]              
            push rax                        
            call my_printf
            add rsp, 7 * 8        

            mov rax, SYSCALL_OUT
            mov rdi, 1
            lea rsi, [rel target1]
            mov rdx, target1Len
            syscall

            push NEW_LINE
            lea rax, [rel string2]
            push rax
            lea rax, [rel msg2]
            push rax
            call my_printf
            add rsp, 3 * 8

            mov rax, SYSCALL_OUT
            mov rdi, 1
            lea rsi, [rel target2]
            mov rdx, target2Len
            syscall

            push NEW_LINE
            push 1337
            push 1337
            push 1337
            push 1337
            lea rax, [rel msg3]
            push rax
            call my_printf
            add rsp, 6 * 8

            mov rax, SYSCALL_OUT
            mov rdi, 1
            lea rsi, [rel target3]
            mov rdx, target3Len
            syscall

            mov rax, SYSCALL_EXIT           ;
            mov rbx, 0                      ; } выход
            syscall                         ;

print_string:
            
