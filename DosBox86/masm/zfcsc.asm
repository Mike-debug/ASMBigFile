data segment
	zf db 'Hello Tom!', 0dh, 0ah, '$'
data ends
code segment
assume ds:data, cs:code
main:
	mov ax, data
	mov ds, ax
	mov dx, offset zf
	mov al, 4	
	mov ah, 9
	int 21h
	mov ah, 4Ch
	int 21h
code ends	
end main