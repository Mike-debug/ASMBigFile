data segment
	filename db "abc.txt",0
	buf db 100 dup(?)
	handle dw ?
data ends
stack segment
	dd 1000 dup(0)
stack ends
code segment
assume cs:code, ss:stack, ds:data
main:
	mov ax, data
	mov ds, ax
	
	mov ah, 0
	int 16h
	mov dl, ah
	call near ptr Tester
	mov dl, al
	call near ptr Tester

done:
	mov ah, 4ch
	int 21h
;-------------------------------------------------------------------------------------------
Tester proc near					;Tester函数原来是我用来测试dl和其他寄存器中的值的，因为也可以用来
	push ax						;输出字符，所以也保留下来了
	xor ax, ax
	mov ah, 02h
	int 21h
	pop ax
	retn
Tester endp
;-------------------------------------------------------------------------------------------f
code ends
end main