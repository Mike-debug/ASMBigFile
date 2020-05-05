;第二次汇编作业
;浙江大学 魏一鸣
;1781937775@qq.com
.386
data segment use16
x db 6, ?, 6 dup(0)
y db 6, ?, 6 dup(0)
result db 11 dup(0), 0Dh, 0Ah, '$'
data ends
sstack segment stack use16
	dw 100 dup(0)
sstack ends
code segment use16
	assume ds:data, cs:code, ss:sstack
	start:	mov ax, data
			mov ds, ax
			mov ah, 0Ah
			mov dx, offset x
			int 21h
			mov ah, 2
			mov dl, 0Dh
			int 21h
			mov dl, 0Ah
			int 21h
			mov ah, 0Ah
			mov dx, offset y
			int 21h
			mov ah, 2
			mov dl, 0Dh
			int 21h
			mov dl, 0Ah
			int 21h
			mov bx, offset x
			call StringToNumber
			push ax
			mov bx, offset y
			call StringToNumber
			pop cx
			mul cx
			call Print
			call ToDecimal
			call ToHex
			call ToBinary
done:
			mov ah, 4Ch
			int 21h

StringToNumber proc near
			mov ax, 0
			add bx, 2
loop1:
			cmp byte ptr [bx], 0Dh
			je next1
			mov ch, 0
			mov cl, byte ptr [bx]
			sub cl, 30h
			mov dx, 10
			mul dx
			add ax, cx
			add bx, 1
			jmp loop1
next1:
			retn
StringToNumber endp

Print proc near
			push ax
			push dx
			mov bx, offset x
			add bx, 2
			mov ch, 0
			mov cl, x[1]
again1:
			mov ah, 2
			mov dl, [bx]
			int 21h
			inc bx
			loop again1
			mov ah, 2
			mov dl, 2Ah
			int 21h
			mov	bx, offset y
			add bx, 2
			mov ch, 0
			mov cl, [y+1]
again2:
			mov ah, 2
			mov dl, [bx]
			int 21h
			inc bx
			loop again2
			mov ah, 2
			mov dl, 3Dh
			int 21h
			mov dl, 0Dh
			int 21h
			mov dl, 0Ah
			int 21h
			pop dx
			pop ax
			retn
Print endp

ToDecimal proc near
			push dx
			push cx
			push ax
			mov ax, dx
			mov cl, 16
			shl eax, cl
			pop ax
			push ax
			mov si, 9
besides1:
			cmp eax, 0
			je besides2
			mov edx, 0
			mov ecx, 10
			div ecx
			mov byte ptr [result+si], dl
			add byte ptr [result+si], 30h
			dec si
			jmp besides1
besides2:
			add si, 1
			mov dx, offset result
			add dx, si
			mov ah, 09h
			int 21h
			pop ax
			pop cx
			pop dx
			retn
ToDecimal endp

ToHex proc near
			push ax
			push dx
			cmp dh, 0
			jne then1
			cmp dl, 0
			jne then2
			cmp ah, 0
			jne then3
			jmp then4
then1:
			mov bh, dh
			call ToHexPrint
then2:
			mov bh, dl
			call ToHexPrint
then3:
			mov bh, ah
			call ToHexPrint
then4:
			mov bh, al
			call ToHexPrint
			mov ah, 2
			mov dl, 68h
			int 21h
			mov dl, 0Dh
			int 21h
			mov dl, 0Ah
			int 21h
			pop dx
			pop ax
			retn
ToHex endp

ToHexPrint proc near
			push ax
			push dx
			push cx
			mov dh, bh
			mov cl, 4
			shr dh, cl
			cmp dh, 0
			je more3
			cmp dh, 10
			jb more1
			mov dl, 37h
			jmp more2
more1:
			mov dl, 30h
more2:
			add dl, dh
			mov ah, 02h
			int 21h
more3:
			mov dh, bh
			and dh, 0Fh
			cmp dh, 10
			jb more4
			mov dl, 37h
			jmp more5
more4:
			mov dl, 30h
more5:
			add dl, dh
			mov ah, 02h
			int 21h
			pop cx
			pop dx
			pop ax
			retn
ToHexPrint endp

ToBinary proc near
			push ax
			push dx
			cmp dh, 0
			jne tthen1
			cmp dl, 0
			jne tthen2
			cmp ah, 0
			jne tthen3
			jmp tthen4
tthen1:
			mov bh, dh
			call ToBinaryPrint
			push ax
			push dx
			mov ah, 2
			mov dl, 0
			int 21h
			pop dx
			pop ax
tthen2:
			mov bh, dl
			call ToBinaryPrint
			push ax
			mov ah, 2
			mov dl, 0
			int 21h
			pop ax
tthen3:
			mov bh, ah
			call ToBinaryPrint
			push ax
			mov ah, 2
			mov dl, 0
			int 21h
			pop ax
tthen4:
			mov bh, al
			call ToBinaryPrint
			mov ah, 2
			mov dl, 42h
			int 21h
			mov dl, 0Dh
			int 21h
			mov dl, 0Ah
			int 21h
			pop dx
			pop ax
			retn
ToBinary endp

ToBinaryPrint proc near
			push ax
			push dx
			push cx
			push bx
			mov dh, bh
			mov bl, 80h
			mov cx, 8
mmore1:
			and dh, bl
			cmp dh, 0
			jne mmore2
			mov ah, 2
			mov dl, 30h
			int 21h
			jmp mmore3
mmore2:
			mov ah, 2
			mov dl, 31h
			int 21h
mmore3:
			cmp bl, 10h
			jne mmore4
			mov dl, 0
			int 21h
mmore4:
			mov dh, bh
			shr bl, 1
			loop mmore1
			pop bx
			pop cx
			pop dx
			pop ax
			retn
ToBinaryPrint endp
code ends
end start