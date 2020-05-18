.model tiny
.code
org 100h

start:
			lea di, msg1
			lea si, msg2

strcpy:
			push di
			mov di, si
			call strlen
			dec cx
			pop di
			
cpy_loop_start:
			movsb
			cmp byte ptr ds:[di], 0dh
			jne cpy_loop_start
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
				
				
msg1			db 'LIZA', 0dh
msg2			db 'loh', 0dh

end start