data segment
	abc db 'B','$'
data ends
stack segment
	dw 1000 dup(?)
stack ends
code segment
assume ds:data,ss:stack,cs:code
main:
	mov ax,data
	mov ds,ax
	mov ah,1
	int 21h
	
	xor dx,dx
	mov ah,2
	mov dl,al
	int 21h

	mov ah,9
	mov dx,offset abc
	int 21h

	mov ah, 4ch
	int 21h
code ends
end main