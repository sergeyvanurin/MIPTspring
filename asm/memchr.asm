.model tiny
.code
org 100h

start:
		lea di, msg
        mov al, 'H'
        mov cx, 5

        call memchr
        mov ah, 02h
        mov dl, [si]
        int 21h

memchr:
				xor si, si
				repne scasb
				jnz exit
				
				mov si, di
				dec si
				
				
exit:
				ret

		
msg db 'HELLO', 0h
msg1 db 'WORLD', 0h


end start