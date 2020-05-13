.model tiny
.code
org 100h
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


start:
			mov bx, VIDEO_SEG
			mov es, bx
			mov bx, (SCREEN_LENGTH * (SCREEN_WIDTH - BOX_WIDTH) / 2 + (SCREEN_LENGTH - BOX_LENGTH) / 2)*2
			mov cx, 0h
			mov ax, 0h
			jmp loop2_start
loop1_start:
			cmp cx, BOX_LENGTH - 2
			je loop2_return
			cmp ax, 0
			je draw_border
			cmp ax, BOX_WIDTH - 1
			je draw_border
			mov es:[bx], RED_EXCLAMATION
border_return:
			inc bx
			inc bx
			inc cx
			cmp cx, BOX_LENGTH - 2
			je vert_shadow
vert_return:
			cmp ax, BOX_WIDTH - 1
			je hor_shadow
hor_ret:
			jmp loop1_start
loop2_start:
			cmp ax, BOX_WIDTH
			je loop2_end
			mov es:[bx], VERTICAL_LINE
			inc bx
			inc bx
			jmp loop1_start
loop2_return:
			mov es:[bx], VERTICAL_LINE
			inc bx
			inc bx
			inc ax
			add bx, BOX_LENGTH * 2
			mov cx, 0h
			jmp loop2_start
loop2_end:
			mov bx, (SCREEN_LENGTH * (SCREEN_WIDTH - BOX_WIDTH) / 2 + (SCREEN_LENGTH - BOX_LENGTH) / 2)*2
			mov es:[bx], TL_CORNER
			add bx, (BOX_LENGTH - 1) * 2
			mov es:[bx], TR_CORNER
			mov word ptr es:[bx + 2], 0000h
			add bx, (SCREEN_LENGTH * (BOX_WIDTH - 2) + BOX_LENGTH + 1) * 2
			mov es:[bx], BL_CORNER
			add bx, (BOX_LENGTH - 1) * 2
			mov es:[bx], BR_CORNER
			mov es:[bx + (SCREEN_LENGTH + 1) * 2], GREEN_SHADOW
			mov ax, 4c00h
			int 21h
draw_border:
			mov es:[bx], HOR_LINE
			jmp border_return
vert_shadow:
			mov es:[bx + 2], GREEN_SHADOW
			jmp vert_return
hor_shadow:
			mov es:[bx + SCREEN_LENGTH * 2], GREEN_SHADOW
			jmp hor_ret
			
end start