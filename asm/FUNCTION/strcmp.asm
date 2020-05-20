.model tiny
.code
org 100h


start:
		lea si, msg1
		lea di, msg2
		call strcmp
				
		mov ax, 4c00h
		int 21h

;==================================================
;int strcmp ( const char* str1, const char* str2 );
;si - str1
;di - str2
;
;returns: al - relatonship between strings
;==================================================
strcmp:			
		cld
		push di
		call strlen
		pop di
		inc cx
		
		cld
		repe cmpsb
		jl less
		jg greater

		mov al, 0
		ret
less:
		mov al, -1
		ret
greater:
		mov al, 1
		ret
				
;==================================================
;size_t strlen ( const char* str );
;di - str
;
;dest: al
;returns: cx - string length
;==================================================			
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
				
				
				
msg1	db 'hello worldddd',0dh
msg2	db 'hello worldddd',0dh

end start
				