.model tiny
.code
org 100h


start:
				xor ax, ax
				mov bh, 00
				mov di, 81h
				mov cl, 10d
transform:
				mov bl, byte [di]
				cmp bl, 36d
				je finish
				
				;cmp bl, 48
				;jl error
				
				;cmp bl, 57
				;jl error
				
				sub bl, 48
				imul cl
				add ax, bx
				
				inc di
				jmp transform
finish:
				mov ax, 4c00h
				int 21h
end start