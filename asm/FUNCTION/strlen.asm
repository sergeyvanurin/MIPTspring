.model tiny
.code
org 100h


start:
        lea di, msg 
        call strlen
        
        mov ax, 4c00h
        int 21h

;==========================================
;size_t strlen ( const char* str );
;di - str
;
;dest: al, di
;returns: cx - string length
;==========================================
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
                
                
                
msg 	db 'Hello world', 0dh


end start