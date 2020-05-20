.model tiny
.code
org 100h


start:
        lea si, msg1
        lea di, msg2
        call strcmp
                
        mov ax, 4c00h
        int 21h

;==================================================
;int strcmp ( const char* str1, const char* str2 );
;si - str1
;di - str2
;
;dest: si, di, al, cx
;returns: al - relatonship between strings
;==================================================
strcmp:			
        cld
        push di
        call strlen
        pop di
        inc cx
        
        cld
        repe cmpsb
        je equal

        mov al, [si - 1]
        mov ah, [di - 1]

        sub al, ah
        ret

equal:
        mov al, 0
        ret
                
;==================================================
;size_t strlen ( const char* str );
;di - str
;
;dest: al
;returns: cx - string length
;==================================================			
strlen:
        cld
        xor cx, cx
        mov al, 0dh
                
loop_start:	
        scasb
        je finish
        inc cx
        jmp loop_start
finish:
        ret
                
                    
msg1	db 'hello worldddd',0dh
msg2	db 'hello worlddda',0dh

end start
                