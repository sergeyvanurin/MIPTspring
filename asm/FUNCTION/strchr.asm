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
;returns:di - pointer to a first occurrence of character in str. NULL if not found
;====================================================================================
strchr:
		cld

search_loop:
		scasb
		jne search_loop

		cmp byte ptr ds:[di], 0dh
		je not_found

		dec di
		ret
not_found:
		xor di, di
		ret


msg db 'PIZZA', 0dh

end start
	