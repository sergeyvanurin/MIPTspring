.model tiny
.code
org 100h

start:
        lea di, msg1
        lea si, msg
        mov cx, 5

        call memset

        mov ax, 4c00h
        int 21h

;======================================================================
;void * memcpy ( void * destination, const void * source, size_t num );
;di - destination
;si - source
;cx - num
;
;returns: di - destination
;======================================================================
memcpy:
        cld
        rep movsb

        ret


msg db 'HELLO', 0h
msg1 db 'WORLD', 0h

end start