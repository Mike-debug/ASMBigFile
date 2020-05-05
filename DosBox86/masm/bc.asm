;************************************汇编作业第三次******************************************
;*姓名：魏一鸣
;*学号：3150100565
;*专业：计算机科学与技术
;********************************************************************************************
.386
data segment use16
	filename db 80,?,80 dup(?)
	buf db 	128,?,128 dup(?)
;	buf db 	"fcwk51@#xx!~ xx ", 0Dh, 0Ah, '$'
	handle dw 0
	filesize dd ?
	buf1 db "Please input filename:", 0Dh, 0Ah, '$'
	buf2 db "Cannot open file!", 0Dh, 0Ah, '$'
	s db "00000000: xx xx xx xx|xx xx xx xx|xx xx xx xx|xx xx xx xx  ................", 0Dh, 0Ah, '$'
	pattern db "00000000:            |           |           |                             ", 0Dh, 0Ah, '$'
	t db "0123456789ABCDEF"
	row db 1
	bytes_on_row db 14
	index dd 4142EFEFh
data ends
stack1 segment use16
	dd 1000 dup(0)
stack1 ends
code segment use16
assume cs:code, ss:stack1, ds:data
main:
	mov ax, data
	mov ds, ax
	
	;mov bx, 'AB'					;\
	;shl ebx, 16					; |在index使用之前，这段代码用来操作ebx
	;mov bx, 0fefeh					;/
	mov ebx, index
	;mov si, 10
	call near ptr show_this_row
	;mov si, 0h					 ; \  
	;mov cx, 75					 ;  /这段代码用于测试函数show_this_row是否正确
	;call near ptr output_s				 ;/

	call near ptr displayaword

	;mov bl, 254					;\
	;mov bh, 254					 ;\
	;shl ebx, 16					  ;\
	;mov bl, 254					   ;\
	;mov bh, 254					    ;\
	;mov si, 0h					    ;/这段代码用于测试函数convert8bit_to_hex和convert32bit_to_hex是否正确
	;call near ptr convert32bit_to_hex		   ;/
	;						  ;/	
	;mov cx, 75h					 ;/
	;call near ptr output_s				;/

ending:
	mov ah, 4ch
	int 21h
;-------------------------------------------------------------------------------------------
convert8bit_to_hex proc near				;把存在bl中的数转成16进制存入s[bp]中
	push ax
	push cx
	push si
	push bx

	xor cx, cx
	xor ax, ax

	mov al, bl
	and al,0f0h
	shr al, 4					;al中存高4位
	mov si, ax
	mov ch, t[si]					;ch中存放高4位

	xor ax, ax

	mov al, bl
	and al,0fh					;al中存低4位
	mov si, ax
	mov cl, t[si]					;cl中是低4位

	pop bx
	pop si
	mov s[si], ch
	inc si
	mov s[si], cl

	dec si
	pop cx
	pop ax
	retn

convert8bit_to_hex endp
;-------------------------------------------------------------------------------------------
Tester proc near					;Tester函数原来是我用来测试dl和其他寄存器中的值的，因为也可以用来
	push ax						;输出字符，所以也保留下来了
	xor ax, ax
	mov ah, 02h
	int 21h
	pop ax
	retn
Tester endp
;-------------------------------------------------------------------------------------------
convert32bit_to_hex proc near				;把ebx中的32位数字转成十六进制
	push cx
	push si
	push ebx

	xor cx, cx
	mov cx, 4
convert:
	rol ebx, 8h
	call near ptr convert8bit_to_hex
	inc si
	inc si
	loop convert

	pop ebx
	pop si
	pop cx
	retn
convert32bit_to_hex endp
;-------------------------------------------------------------------------------------------
output_s proc near					;该函数用于非显存输出字符串s
	push si
	push cx
	push dx
	push ax

	xor cx, cx
	mov cx, 75
	mov si, 0
output:
	mov dl, s[si]
	call near ptr Tester
	inc si
	cmp si, 75
	jna output

	pop ax
	pop dx
	pop cx
	pop si
	retn
output_s endp
;-------------------------------------------------------------------------------------------
cleanscreen proc near
	push ax
	push bx
	push cx
	push dx

	mov ax,0B800h
	mov es,ax					;显存地址
	mov ah,7					;向下卷屏
	mov al,0					;清屏
	mov bh,0					;清屏后空白部分属性为黑色
	mov ch,0					;清屏左上角行坐标
	mov cl,0					;清屏左上角列坐标
	mov dh,15					;清屏右下角行坐标
	mov dl,74					;清屏右下角列坐标
	int 10h
	
	pop dx
	pop cx
	pop bx
	pop ax
	retn
cleanscreen endp
;-------------------------------------------------------------------------------------------
show_this_row proc near
	push ax
	push bx
	push cx
	push dx
	push si

	push si
	xor cx, cx
	xor si, si
	xor dx, dx
	mov cx, 75
strcpy_s_pattern:
	mov dl,pattern[si]
	mov s[si],dl
	inc si
	loop strcpy_s_pattern
	pop si
	
	push si
	mov si, 0h
	call near ptr convert32bit_to_hex
	pop si

	;mov si, 0h					 ; \  
	;mov cx, 75					 ;  /这段代码用于测试函数show_this_row是否正确
	;call near ptr output_s				 ;/

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	retn
show_this_row endp
;-------------------------------------------------------------------------------------------
displayaword  proc near					;ebx中放的是偏移地址offset，buf是内容;bytes_on_row是每行多少字节
	push ax
	push di
	push cx
	push si
	push bp
	push dx
	push bx

	call near ptr cleanscreen			;清屏函数，和c语言文件描述有所不同，但都有清屏功能

	xor bx, bx
	xor dx, dx
	xor cx, cx
	xor di, di
	mov cl, bytes_on_row				;这里曾用立即数10h代替bytes_on_row，之后要改
	xor si, si
	xor bp, bp
	mov si, 10
	mov di, 59
move_buf_to_s:
	mov bl, buf[bp]
	mov s[di], bl
	;mov dl, bl					;\
	;call near ptr Tester				;/ 该段函数用于测试bl确实传递了buf中的字符
	call near ptr convert8bit_to_hex			
	inc bp
	inc di
	add si, 3h
	loop move_buf_to_s


	xor cx, cx					;从此时开始输出一行字符
	mov cx, 75
	xor si, si
	call near ptr coordinate			;计算coordinate即输出坐标
showaline:
	call near ptr color				;这里需要一个判断ah为07h或者0fh的函数
	mov al, s[si]
	call near ptr print
	add di, 2
	inc si
	loop showaline

	mov ah,0
	int 16h

	pop bx
	pop dx
	pop bp
	pop si
	pop cx
	pop di
	pop ax
	retn    
displayaword endp
;-------------------------------------------------------------------------------------------
print proc near						;此函数用于displayaword函数投映到屏幕
	push cx
	push di
	
	cld
	stosw

	pop di
	pop cx
	retn
print endp
;-------------------------------------------------------------------------------------------
color proc near						;该函数用于判断输出字符的颜色和亮度
	cmp si, 59
	jb ifor
	mov ah, 07h
return:
	retn
ifor:
	cmp s[si], '|'
	je lit
	mov ah, 07h
	jmp return
lit:
	mov ah, 0fh
	jmp return
color endp
;-------------------------------------------------------------------------------------------
coordinate proc near					;根据row值，计算bi坐标，视频坐标
	push ax
	push bx
	
	xor ax, ax
	xor bx, bx
	mov al, row
	dec al
	mov bl, 160
	mul bl
	mov di, ax

	pop dx
	pop ax
	retn
coordinate endp
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
code ends
end main