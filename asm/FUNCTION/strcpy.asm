.model tiny
.code
org 100h


start:
		lea di, msg1
		lea si, msg2
		call strcpy

		mov ax, 4c00h
		int 21h

;=====================================================
;char * strcpy( char * destptr, const char * srcptr );
;di - destpr
;si - srcptr
;
;dest: al, cx
;returns: di - destintaion ptr
;=====================================================
strcpy:
		push di
		mov di, si
		call strlen
		inc cx
		pop di
		
		rep movsb

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
				
				
msg1	db 'PIZZA', 0dh
msg2	db 'time', 0dh

end start