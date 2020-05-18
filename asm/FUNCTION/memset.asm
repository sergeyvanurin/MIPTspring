.model tiny
.code
org 100h

start:
        lea di, msg
        mov al, 'E'
        mov cx, 5

        call memset

        mov ax, 4c00h
        int 21h

;========================================================================
;void* memset ( void* ptr, unsigned char value, size_t num );
;di - ptr
;al - value
;cx - num
;
;returns: di - destination
;=========================================================================
memset:
        cld
        rep stosb

        ret


msg db 'HELLO WORLD', 0h

end start