.model tiny
.code
org 100h

start:
	; Checking if strchr works
	   lea di, msg
       mov al, 'Z'
       call strchr
	   ret
     

strchr:
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


strlen:
				xor cx, cx
				mov al, 0dh
				
loop_start:	
				scasb
				je finish
				inc cx
				jmp loop_start
finish:
				ret
				
msg  			db 'LIZA', 0dh


end start
				