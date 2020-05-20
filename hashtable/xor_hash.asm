.686
.MODEL tiny, c
.code

asm_xor_hash proc data:ptr byte
	xor eax, eax
	xor edx, edx

	mov ecx, dword ptr data

hash_loop:
	mov dl, [ecx]

	cmp edx, 0
	je loop_end

	xor eax, edx
	rol eax, 1
	inc ecx

	jmp hash_loop

loop_end:
	ret

asm_xor_hash endp

end