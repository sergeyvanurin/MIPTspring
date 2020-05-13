.model tiny
.code
org 100h
;-------------------------------------
SCREEN_WIDTH equ 25
SCREEN_LENGTH equ 80
BOX_WIDTH equ 15
BOX_LENGTH equ 40
VIDEO_SEG equ 0b800h
GREEN_SHADOW equ 2221h
PSP_COMMAND_LINE equ 81h
DIM_COUNT equ 4
ELEM_COUNT equ 7
;-------------------------------------
;symbols[0] TL_CORNER
TL_CORNER equ 0
;symbols[1] TR_CORNER
TR_CORNER equ 2
;symbols[2] BL_CORNER
BL_CORNER equ 4
;symbols[3] BR_CORNER
BR_CORNER equ 6
;symbols[4] VERTICAL_LINE
VERTICAL_LINE equ 8
;symbols[5] HOR_LINE
HOR_LINE equ 10
;symbols[6] INSIDE
INSIDE equ 12
;---------------------------------------


start:
			mov di, PSP_COMMAND_LINE				;argument adress
			mov cx, DIM_COUNT						;argument count
			symbols dw ELEM_COUNT DUP(?)
			
get_dimensions:

			call atoi								;
			push ax									;gets dimensions from PSP
			inc di									;
			
			loop get_dimensions
			
			mov cx, ELEM_COUNT
get_symbols:
			call symbol_to_ascii
			push ax
			
			loop get_symbols
			
			call atoi
			push ax
			
			
			mov si, 12
			mov cx, 7
			pop bx
			shl bx, 8
			
fill_array:
			pop ax
			or ax, bx
			mov symbols[si], ax
			dec si
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
			sub dx, 2
			
			call get_pos
			
			push bx
			mov bx, VIDEO_SEG
			mov es, bx
			pop bx
			
			mov ax, symbols[TL_CORNER]
			mov es:[bx], ax
			inc bx
			inc bx
			
			mov cx, dx
			mov ax, symbols[HOR_LINE]
			call horizontal_line 
			
			mov ax, symbols[TR_CORNER]
			mov es:[bx], ax
			inc bx
			inc bx
			
			add bx, SCREEN_LENGTH * 2 - 4				;
			sub bx, dx									;	add bx, (SCREEN_LENGTH - di + 2)*2
			sub bx, dx									;
			
			
			mov ax, symbols[INSIDE]
			
			mov cx, di

next:		

			push cx
			mov ax, symbols[VERTICAL_LINE]
			mov es:[bx], ax
			inc bx
			inc bx
			
			mov cx, dx
			mov ax, symbols[INSIDE]
			call horizontal_line
			
			mov ax, symbols[VERTICAL_LINE]
			mov es:[bx], ax
			inc bx
			inc bx
			
			mov es:[bx], GREEN_SHADOW
		
			add bx, SCREEN_LENGTH * 2 - 4				;
			sub bx, dx									;	add bx, (SCREEN_LENGTH - di - 2)*2
			sub bx, dx									;
			
			pop cx
			
			loop next
			
			
			mov ax, symbols[BL_CORNER]
			mov es:[bx], ax
			inc bx
			inc bx
			
			mov cx, dx
			mov ax, symbols[HOR_LINE]
			call horizontal_line
			
			mov ax, symbols[BR_CORNER]
			mov es:[bx], ax
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



symbol_to_ascii:
				push cx
				xor ax, ax
				mov ah, 00
				mov al, byte [di]
				pop cx
				inc di
				inc di
				ret
				
end start


8 +- 1