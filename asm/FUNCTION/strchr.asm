.model tiny
.code
org 100h


start:
        lea di, msg
        mov al, 'Z'
        call strchr
        
        mov ax, 4c00h
        int 21h
     
;====================================================================================
;char* strchr (char* str, unsigned char character);
;di - str
;al - character
;
;dest: di
;returns:di - pointer to a first occurrence of character in str. NULL if not found
;====================================================================================
strchr:
        cld

search_loop:
        cmp byte ptr ds:[di], 0h
        je not_found

        scasb
        je found

        jmp search_loop

not_found:
        xor di, di
        ret

found:
        dec di
        ret


msg db 'PIZZA', 0h

end start
    