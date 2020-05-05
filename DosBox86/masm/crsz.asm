data segment
s db 10 dup(0)
t db 10 dup(0)
data ends
code segment 
assume cs:code,ds:data
;input proc
;```
;input endp
input:
	push ax
	push di
	mov ah,1
	int 21h
	cmp al,0Dh
	je input_done
	mov [di],al
	inc di
	jmp input
input_done:
	mov byte ptr [di],0;必须加byte ptr,因为不加则宽度不确定
	pop di
	pop ax
	ret
main:
	mov ax,data
	mov ds,ax
	mov di,offset s
	call input
	mov di,offset t
	call input
	mov ah,4Ch
	int 21h
code ends
end main