.model tiny
.code
org 100h
start:
				lea si, msg1
				lea di, msg2
				call strcmp
				ret

;==================================
;int strcmp ( const char* str1, const char* str2 );
;si - str1
;di - str2
;
;returns: al - relatonship between strings
;=============================================
strcmp:			
				cld
				push di
				mov di, si
				call strlen
				pop di
				
				cld
				repe cmpsb
				je same
				jl less
				jg greater
same:
				mov al, 0
				ret
less:
				mov al, -1
				ret
greater:
				mov al, 1
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
				
				
				
msg1			db 'hello world',0dh
msg2			db 'Hello world',0dh

end start
				