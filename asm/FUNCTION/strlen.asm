.model tiny
.code
org 100h

start:
				lea di, msg   
				call strlen
				ret

strlen:
				xor cx, cx
				mov al, 0dh
				
loop_start:	
				scasb
				je finish
				inc cx
				jmp loop_start
finish:
				dec cx
				ret
				
				
				
msg 			db 'LIZZZZZA"', 0dh


end start