.model tiny
.code
org 100h


start:
        lea si, msg
        mov cx, 100
        lea di, msg1

        call memcmp

        mov ax, 4c00h
        int 21h

;==================================================================
;int memcmp ( const void * ptr1, const void * ptr2, size_t num );
;si - ptr1
;di - ptr2
;cx - num
;
;dest: si, di, ax
;returns: al - relationship between first differrnet charachter
;==================================================================
memcmp:
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

                
msg db 'HELLO', 0h
msg1 db 'HELL', 0h


end start