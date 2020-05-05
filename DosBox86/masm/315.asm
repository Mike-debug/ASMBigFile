code segment
	assume cs:code, ss:stk
main:
	mov ax, 0B800h
	mov es, ax
	xor di, di
	xor bx, bx	
	mov cx, 19h
	mov ax, 3
	int 10h
loop1:
	push cx
	push di
	push bx
	mov cx, 11
loop2:
	push cx
	mov byte ptr es:[di], bh
	mov byte ptr es:[di+1], 04h
	add di, 2
	mov bl, bh
	mov cl, 4
	shr bl, cl
	call Show16
	mov bl, bh
	shl bl, cl
	shr bl, cl
	call Show16
	cmp bh, 231
	jae here
	add bh, 19h
	add di, 8
	pop cx
	loop loop2
	jmp there
here:
	pop cx
there:
	pop bx
	pop di
	pop cx
	add bh, 1
	add di, 160
	loop loop1
	mov ah, 0
	int 17h
	mov ah, 4Ch
	int 21h

Show16 proc near
	cmp bl, 09h
	ja next
	add bl, 30h
	jmp exit
next:
	add bl, 37h
exit:
	mov byte ptr es:[di], bl
	mov byte ptr es:[di+1], 02h
	add di, 2
	retn
Show16 endp
code ends

stk segment stack
	dw 100 dup(0)
stk ends

end main 