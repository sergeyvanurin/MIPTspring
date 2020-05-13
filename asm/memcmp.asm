.model tiny
.code
org 100h

start:
		lea si, msg
        mov cx, 100
        lea di, msg1
        call memcmp
		
		ret

memcmp:
memcmp_loop:
				repe cmpsb
				jl lower
				jg greater
				jmp equal
lower:
				mov al, -1
				ret
equal:
				mov al, 0
				ret

greater:
				mov al, 1
				ret
				
				
				
msg db 'HELLO', 0h
msg1 db 'WORLD', 0h


end start