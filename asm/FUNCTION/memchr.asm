.model tiny
.code
org 100h


start:
        lea di, msg
        mov al, 'H'
        mov cx, 5
        
        call memchr
        
        mov ax, 4c00h
        int 21h
        
;=========================================================
;void* memchr ( const void * ptr, unsigned char value, size_t num );
;di - ptr
;al - character to find
;cx - length
;
;dest: di, si
;return: si - pointer to a first value occurrence. NULL if not found
;==========================================================
memchr:
        cld
        repne scasb
        jnz exit
                
        mov si, di
        dec si

        ret
exit:
        xor si, si
        ret

        
msg db 'HELLO', 0h


end start