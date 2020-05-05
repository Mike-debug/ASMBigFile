;第三次汇编作业
;完成者：车天一
;邮箱：776946432@qq.com
;学号：3160105470
;谢谢老师
data segment
	filename db 80,?,80 dup(?)
	buf dw 	128,?,128 dup(?)
	handle dw 0
	filesize dd ?
	buf1 db "Please input filename:", 0Dh, 0Ah, '$'
	buf2 db "Cannot open file!", 0Dh, 0Ah, '$'
	s db "00000000: xx xx xx xx|xx xx xx xx|xx xx xx xx|xx xx xx xx  ................", 0Dh, 0Ah, '$'
	pattern db "00000000:            |           |           |                             ", 0Dh, 0Ah, '$'
	t db "0123456789ABCDEF"
data ends

stack1 segment stack
	dd 100 dup(0)
stack1 ends

.386
code segment use16
	assume cs:code, ds:data, ss:stack1
	start:	mov ax, data
			mov ds, ax
			lea dx, buf1
			mov ah, 09h
			int 21h
			lea dx, filename
			mov ah, 0Ah
			int 21h
			lea bx, filename
			add bx, 2
			mov dh, 0
			mov dl, byte ptr filename[1]
			add bx, dx
			mov byte ptr [bx], 0
			mov ah, 3Dh
			mov al, 0
			lea dx, filename
			add dx, 2
			int 21h
			lea bx, handle
			mov word ptr [bx], ax
			mov ah, 02h
			mov dl, 0Dh
			int 21h
			mov dl, 0Ah
			int 21h
			jnc next1
			lea dx, buf2
			mov ah, 09h
			int 21h
			mov ah, 4Ch
			mov al, 0
			int 21h
	next1:	
			mov ah, 42h
			mov al, 2
			lea bx, handle
			mov bx, word ptr [bx]
			mov cx, 0
			mov dx, 0
			int 21h
			mov word ptr filesize[2], dx
			mov word ptr filesize[0], ax
			mov eax, 0
	loop1:	
			mov ebx, dword ptr filesize[0]
			sub ebx, eax
			cmp ebx, 256
			jb next2
			mov ebx, 256
			jmp next2
	next2:	
			push eax
			push ebx
			mov bx, handle
			mov edx, eax
			mov cl, 16
			shr edx, cl
			mov cx, ax
			mov ah, 42h	
			mov al, 0
			int 21h
			mov ah, 3Fh
			pop ebx
			mov cx, bx
			push ebx
			mov bx, handle
			mov dx, offset buf
			int 21h
			pop ebx
			pop eax
			call show_this_page
			push eax
			mov ah, 0
			int 16h
			mov bx, ax
			pop eax
			cmp bx, 4900h
			jne done1
			sub eax, 256
			cmp eax, 0
			jae done4
			mov eax, 0
			jmp done4
		done1:
			cmp bx, 5100h
			jne done2
			mov edx, eax
			add edx, 256
			cmp edx, dword ptr filesize[0]
			jae done4
			mov eax, edx
			jmp done4
		done2:
			cmp bx, 4700h
			jne done3
			mov eax, 0
			jmp done4
		done3:
			cmp bx, 4F00h
			jne done4	
			mov edx, dword ptr filesize[0]
			mov ecx, 0
			mov cx, dx
			sub edx, ecx
			mov eax, edx
			cmp eax, dword ptr filesize[0]
			jne done4
			mov eax, dword ptr filesize[0]
			sub eax, 256
		done4:
			cmp bx, 011Bh
			jne loop1
			mov ah, 3Eh
			mov bx, handle
			int 21h
			mov ah, 4Ch
			int 21h
			
char2hex proc near;al,xx dx,offset s
	push ebx
	push ecx
	mov si, ax
	mov cl, 4
	shr si, cl
	lea bx, t
	mov ch, byte ptr [bx+si]
	mov bx, dx
	mov byte ptr [bx], ch
	mov si, ax
	and si, 0Fh
	lea bx, t
	mov ch, byte ptr [bx+si]
	mov bx, dx
	mov byte ptr [bx+1], ch
	pop ecx
	pop ebx
	retn
char2hex endp

long2hex proc near; eax:offset dx:offset s
	push ebx
	push ecx
	mov ebx, eax
	mov cx, 0
looplong:
	cmp cl, 4
	jae nextlong
	push ecx
	mov cl, 8
	rol ebx, cl
	pop ecx
	push eax
	push edx
	mov ah, 0
	mov al, bl
	add dx, cx
	add dx, cx
	call char2hex
	pop edx
	pop eax
	add ecx, 1
	jmp looplong
nextlong:
	pop ecx
	pop ebx
	retn
long2hex endp

show_this_row proc near; eax:offset bx:row dx:bytes_on_row
	push ecx
	push ebx
	mov bx, data
	mov es, bx
	mov si, offset pattern
	mov di, offset s
	mov cx, 75
	cld
	rep movsb
	pop ebx
	mov cl, 4
	shl bx, 4
	push edx
	lea dx, s
	call long2hex
	pop edx
	mov cx, 0
loopshow1:
	cmp cx, dx
	jae nextshow1
	push eax
	push edx
	push ebx
	lea si, buf
	add si, bx
	pop ebx
	add si, cx
	mov ah, 0
	mov al, byte ptr [si]
	lea dx, s
	add dx, 10
	add dx, cx
	add dx, cx
	add dx, cx
	call char2hex
	pop edx
	pop eax
	inc cx
	jmp loopshow1
nextshow1:
	lea si, buf
	add si, bx
	lea di, s
	add di, 59
	mov cx, dx
	cld
	rep movsb
	mov cx, 0B800h
	mov es, cx
	mov si, 0
	push ebx
	mov cx, 10
loopshow3:
	add si, bx
	loop loopshow3
	pop ebx
	mov cx, 0
loopshow4:
	cmp cx, 75
	jae nextshow4
	push ebx
	push edx
	mov dx, si
	lea si, s
	add si, cx
	mov bh, byte ptr [si]
	mov si, dx
	add si, cx
	add si, cx
	mov byte ptr es:[si], bh
	inc si
	cmp cx, 59
	jae nextshow3
	cmp byte ptr [bx], '|'
	jne nextshow3
	mov byte ptr es:[si], 0Fh
	jmp doneshow
nextshow3:
	mov byte ptr es:[si], 07h
doneshow:
	mov si, dx
	pop edx
	pop ebx
	inc cx
	jmp loopshow4
nextshow4:
	pop ecx
	retn
show_this_row endp

clear_this_page proc near
	push eax
	push ecx
	mov ax, 20h
	mov cx, 0B800h
	mov es, cx
	mov edi, 0
	mov ecx, 1280
	cld
	rep stosw
	pop ecx
	pop eax
	retn
clear_this_page endp

show_this_page proc near; eax:offset bx:bytes_in_buf
	push ecx
	push edx
	call clear_this_page
	mov dx, bx
	add dx, 15
	mov cl, 4
	shr dx, cl
	mov cx, 0
loopshowpage:
	cmp cx, dx
	jae nextshowpage
	push edx
	sub dx, 1
	cmp cx, dx
	je doneshowpage1
	mov dx, 16
	jmp doneshowpage2
doneshowpage1:
	mov dx, bx
	push eax
	push ecx
	mov ax, cx
	mov cl, 4
	shl ax, cl
	sub dx, ax
	pop ecx
	pop eax
doneshowpage2:
	push ebx
	push ecx
	push eax
	mov ebx, 0
	mov bx, cx
	mov cx, 16
loopshowpage1:
	add eax, ebx
	loop loopshowpage1
	call show_this_row
	pop eax
	pop ecx
	pop ebx
	pop edx
	inc cx
	jmp loopshowpage
nextshowpage:
	pop edx
	pop ecx
	retn
show_this_page endp

code ends
end start