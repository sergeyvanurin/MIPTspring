.model tiny
.code
org 100h



start:
		; Checking if memchr works
        ;lea di, msg
        ;mov al, 'P'
        ;mov cx, 5

        ;call memchr
        ;mov ah, 02h
        ;mov dl, [si]
        ;int 21h
    ; 


    ; Checking if memset works
    ;    mov al, 0AAh
    ;    mov cx, 10
        
    ;    call memset
    ; 

     ; Checking if memcpy works
     ;   lea si, msg
     ;   mov cx, 10
     ;   lea di, msg
     ;   add di, 16h
        
     ;   call memcpy
    ; 

     ; Checking if memcmp works
        lea si, msg
        mov cx, 100
        lea di, msg1
        call memcmp
    ; 

    ; Checking if strlen works
    ;    lea di, msg   
    ;    call strlen
    ; 

    ; Checking if strchr works
    ;    lea di, msg
    ;    mov al, 4Fh
    ;    call strrchr
    ; 

    ; Checking if strcpy works
    ;    lea di, msg
    ;    lea si, msg
    ;    call strcpy
    ; 

	mov ax, 4c00h
	int 21h
	
;----------------------
;ds - pointer to a string
;di - found character(0 if not found)
;al - character to find
;cx - max length 
;----------------------
memchr:
				xor di, di
				repne scasb
				jnz finish
				jmp not_found
finish:
				add di, ds
				ret
not_found:
				xor di, di
				ret
				
;-----------------------------
;di-pointer
;al-byte to set
;cx-count 
;
;-----------------------------		
memset:
				rep stosb
				ret


;-----------------------------
;cx - count
;si - source
;di - dest
;
;-----------------------------
memcpy:
loop2_start:
				mov es:[di], es:[si]
				inc di
				inc si
				loop loop2_start
			

;-------------------
;di - pounter 1
;si - pointer 2
;cx - length
;al - result
;-------------------			
memcmp:
memcmp_loop:
				cmp es:[di], es:[si]
				jl lower
				jg greater
				loop memcmp_loop
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
				
				
;-----------------------------				
;si - pointer
;	
;cx - result				
;-----------------------------
strlen:
				xor cx, cx
				
loop3_start:	
				cmp es:[si], 0dh
				je finish3
				inc cx
				jmp loop3_start
finish3:
				ret



;------------------
;ah - symbol to find
;si - pointer
;
;------------------
strchr:
strchr_loop:
				cmp byte ptr es:[si], ah
				je chr_found
				cmp byte ptr es:[si], 0dh;
				je chr_not_found  
				
				