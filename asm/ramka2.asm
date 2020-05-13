.model tiny
.code
org 100h
;-------------------------------------
SCREEN_WIDTH equ 25
SCREEN_LENGTH equ 80
BOX_WIDTH equ 15
BOX_LENGTH equ 40
VIDEO_SEG equ 0b800h
RED_EXCLAMATION equ 4221h
VERTICAL_LINE equ 42bah
HOR_LINE equ 42cdh
TL_CORNER equ 42c9h
TR_CORNER equ 42bbh
BL_CORNER equ 42c8h
BR_CORNER equ 42bch
GREEN_SHADOW equ 2221h
PSP_COMMAND_LINE equ 81h
;-------------------------------------


start:
			mov di, PSP_COMMAND_LINE				;argument adress
			mov cx, 4 + 7						;argument count
			symbols dw 7 DUP(?)
			
get_dimensions:

			call atoi								;
			push ax									;gets dimensions from PSP
			inc di									;
			
			loop get_dimensions

			mov si, 6
			mov cx, 7
			pop bx
			
fill_array:
			pop ax
			shl ax, 8
			add ax, bx
			mov symbols[si], ax
			dec si
			loop fill_array
			
			
			pop bx									;
			pop ax									;puts dimensions into designated registers
			shl bx, 8								;dx - X , di - Y, bh - y, bl - x 
			or bx, ax								;	
			pop di									;
			pop dx									;
			
			push bx									;
			push dx									;
			push di									;
			shr di, 2								;
			shr dx, 2								;
			mov cx, di								;
			shl cx, 8								; zoom arithmetics
			or cx, dx								;
			add bx, cx								;
			shl di, 1								;
			shl dx, 1								;	
			call draw_box							;
			pop di									;
			pop dx									;
			pop bx									;
			
			mov ah, 86h
			mov cx, 2
			int 15h
			
			
			call draw_box
			
			mov ax, 4c00h
			int 21h
			



;--------------------------------------------------
;dx - X of a box			
;di - Y of a box			
;bh - y of a corner			
;bl - x of a corner
;
;draws a box from given dimensions and coordinates
;--------------------------------------------------
draw_box:
			mov ax, symbols[5]
			sub dx, 2
			
			call get_pos
			
			push bx
			mov bx, VIDEO_SEG
			mov es, bx
			pop bx
			
			mov es:[bx], word ptr symbols[0]
			inc bx
			inc bx
			
			mov cx, dx
			call horizontal_line 
			
			mov es:[bx], word ptr symbols[1]
			inc bx
			inc bx
			
			add bx, SCREEN_LENGTH * 2 - 4				;
			sub bx, dx									;	add bx, (SCREEN_LENGTH - di + 2)*2
			sub bx, dx									;
			
			
			mov ax, symbols[6]
			
			mov cx, di

next:		

			push cx
			mov es:[bx], word ptr symbols[4]
			inc bx
			inc bx
			
			mov cx, dx
			call horizontal_line
			
			mov es:[bx], word ptr symbols[4]
			inc bx
			inc bx
			
			mov es:[bx], GREEN_SHADOW
		
			add bx, SCREEN_LENGTH * 2 - 4				;
			sub bx, dx									;	add bx, (SCREEN_LENGTH - di - 2)*2
			sub bx, dx									;
			
			pop cx
			
			loop next
			
			
			
			mov es:[bx], word ptr symbols[2]
			inc bx
			inc bx
			
			mov cx, dx
			mov ax, symbols[5]
			call horizontal_line
			
			mov es:[bx], symbols[3]
			inc bx
			inc bx
			
			mov es:[bx], GREEN_SHADOW
			inc bx
			inc bx
			
			
			add bx, SCREEN_LENGTH * 2 - 4				;
			sub bx, dx									;	add bx, (SCREEN_LENGTH - di - 2)*2
			sub bx, dx
			
			mov cx, dx
			add cx, 2
			mov ax, GREEN_SHADOW
			call horizontal_line
			
			
			
			ret
;---------------------------------------
;calculates position from coordinates
;
;bh - height
;bl - width
;---------------------------------------

get_pos:

				push ax
				
				mov al, 80d
				mul bh
				xor bh, bh
				add ax, bx
				shl ax, 1
				
				mov bx, ax
				
				pop ax
				
				ret

;---------------------------------
;draws line with given symbol from given point
;
;input:
;ax - symbol
;cx - line length
;bx - starting point
;---------------------------------
horizontal_line:
				push di
				push bx
				mov bx, VIDEO_SEG
				mov es, bx
				pop bx
				
				mov di, bx
				rep stosw
				mov bx, di
				
				pop di
				
				ret
				
				
				
;-----------------------------
;transforms ASCII to int from given adress(seperated by comma)
;input:
;di - adress
;output:
;ax - result
;-----------------------------
atoi:
				push cx
				xor ax, ax
				mov bh, 00
				mov cl, 10d
transform:
				mov bl, byte [di]
				cmp bl, ','
				je finish
				
				cmp bl, 0Dh
				je finish
				
				sub bl, '0'
				imul cl
				add ax, bx
				
				inc di
				jmp transform
finish:
				pop cx
				ret
				
end start