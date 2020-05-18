.model tiny
.code
org 100h

start:
	   lea di, msg
       mov al, 'Z'
       call strchr
	   ret
     
;====================================================================================
;char* strchr (char* str, unsigned char character);
;di - str
;al - character
;
;returns:di - pointer to a first occurrence of character in str. NULL if not found
;====================================================================================
strchr:
				cld
				mov ah, al
				push di
			  
				call strlen

				pop di
				mov al, ah

				repne scasb
				cmp byte ptr ds:[di], 0dh

				je not_found
				dec di
				ret
not_found:
				xor di, di
				ret

;==========================================
;size_t strlen ( const char* str );
;di - str
;
;dest: al
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

				
msg  			db 'PIZZA', 0dh


end start
				