;************************************汇编作业第三次******************************************
;*姓名：魏一鸣
;*学号：3150100565
;*专业：计算机科学与技术
;********************************************************************************************
.386
data segment use16
	filename db 100,?,100 dup(0)
	buf db 	256 dup(?)
	handle dw 0
	filesize dd ?
	hint1 db "Please input filename:", 0Dh, 0Ah, '$'
	hint2 db "Cannot open file!", 0Dh, 0Ah, '$'
	s db "00000000: xx xx xx xx|xx xx xx xx|xx xx xx xx|xx xx xx xx  ................", 0Dh, 0Ah, '$'
	pattern db "00000000:            |           |           |                             ", 0Dh, 0Ah, '$'
	t db "0123456789ABCDEF"
	row db 2					;第几行
	bytes_on_row db 0h				;每行读多少字节
	index dd 0h				;初始行的偏移地址
	bytes_in_buf dw 100h				;buf中有多少字节
	file_size dd 0h
data ends
stack1 segment use16
	dd 1000 dup(0)
stack1 ends
code segment use16
assume cs:code, ss:stack1, ds:data
main:
	mov ax, data
	mov ds, ax
	
	mov dx, offset hint1
	call near ptr outputchararray			;提示输入文件名

	mov ah, 0ah					;输入文件名
	mov dx, offset filename
	int 21h
	call near ptr newline
	call near ptr endfile

	mov ah, 3dh					;打开文件
	mov al, 0
	mov dx, offset filename[2]
	int 21h

	jc error					;判断打开成功与否
	mov handle, ax					;保存句柄

	mov ah, 42h					;读文件大小
	mov al, 2; 对应lseek()的第3个参数,
		; 表示以EOF为参照点进行移动
	mov bx, handle
	mov cx, 0; \ 对应lseek()的第2个参数
	mov dx, 0; /
	int 21h
	mov byte ptr file_size[2], dl
	mov byte ptr file_size[3], dh
	mov byte ptr file_size[0], al
	mov byte ptr file_size[1], ah

display_by_control:
	call near ptr bytes_in_buf_calculating
	mov ah, 42h
	mov al, 0; 对应lseek()的第3个参数,
		; 表示以偏移0作为参照点进行移动
	mov bx, handle
	mov cx, word ptr index[2]; \cx:dx合一起构成
	mov dx, word ptr index[0]; /32位值=offset
	int 21h

	mov ah, 3fh					;开始读入文件，最大1024B
	mov dx, offset buf
	mov cx, bytes_in_buf
	mov bx, handle
	int 21h

	;以下是内存界面显示
	call near ptr show_this_page
	mov ah,0
	int 16h
	
	cmp ah, 1
	je ending

	call near ptr alternation
	jmp display_by_control

	mov bx, handle					;关闭文件
	mov ah, 3eh
	int 21h
	jc error

ending:
	mov ah, 4ch
	int 21h
error:
	mov dx, offset hint2
	call near ptr outputchararray
	mov ah, 4ch
	int 21h
;-------------------------------------------------------------------------------------------
outputchararray proc near
	push ax
	mov ah, 09h
	int 21h
	pop ax
	retn
outputchararray endp
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
coordinate_calculating proc near			;偏移地址计算
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

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	retn
coordinate_calculating endp
;-------------------------------------------------------------------------------------------
sub_show_this_row  proc near					;ebx中放的是偏移地址offset，buf是内容;bytes_on_row是每行多少字节
	push ax
	push di
	push cx
	push dx
	push bx
	push si
	push bp
	
	cmp cl, 0
	je zero_manage1
	
	xor bx, bx
	xor dx, dx
	xor cx, cx
	xor di, di
	mov cl, bytes_on_row				;这里曾用立即数10h代替bytes_on_row，之后要改
	xor si, si
	mov si, 10
	mov di, 59
move_buf_to_s:
	mov bl, buf[bp]
	mov s[di], bl

	call near ptr convert8bit_to_hex			
	inc bp
	inc di
	add si, 3h
	loop move_buf_to_s

zero_manage1:
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

	pop bp
	pop si
	pop bx
	pop dx
	pop cx
	pop di
	pop ax
	retn    
sub_show_this_row endp
;-------------------------------------------------------------------------------------------
print proc near						;此函数用于sub_show_this_row函数投映到屏幕
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
show_this_page proc near
;	mov ebx, index
	call near ptr cleanscreen			;清屏函数，和c语言文件描述有所不同，但都有清屏功能
	call near ptr row_calculating			;计算当前页需要显示多少行
	call near ptr printrows				;显示一行
	retn
show_this_page endp
;-------------------------------------------------------------------------------------------
endfile proc near					;该函数用于在文件名后加0，结束文件名
	push si
	push dx
	
	mov si, 2
compare:
	inc si
	cmp filename[si], 1fh				;根据ascll码表，所有文件名字符ascll码都大于等于20h（包括空格）
	jae compare

	mov filename[si], 0

	pop dx
	pop si
	retn
endfile endp
;-------------------------------------------------------------------------------------------
row_calculating proc near				;;计算当前页需要显示多少行
	push bx
	push ax

	xor ax, ax
	xor bx, bx
	mov ax, bytes_in_buf
	add ax, 0fh
	mov bl, 10h
	div bl
	mov row, al

	pop ax
	pop bx
	retn
row_calculating endp
;-------------------------------------------------------------------------------------------
printrows proc near
	push cx

	xor cx, cx
	mov cl, row
	cmp cl, 0					;读大小为0的文件
	je single
	xor bp, bp
displayrow:
	call near ptr bytes_on_row_calculating
	call near ptr show_this_row
	add bp, 10h	
	loop displayrow
	jmp return5	

single:
	call near ptr bytes_on_row_calculating
	call near ptr show_this_row

return5:
	pop cx
	retn
printrows endp
;-------------------------------------------------------------------------------------------
bytes_on_row_calculating proc near			;用来计算当前行有多少字节
	cmp cx, 1
	jne ordinal

	push ax
	push bx
	xor ax, ax
	xor bx, bx
	mov ax, bytes_in_buf
	mov bl, 10h
	div bl
	cmp ah, 0
	je adjust
	jmp assign
adjust:
	mov ah, 10h
assign:
	mov bytes_on_row, ah

	pop bx
	pop ax
	jmp return1

ordinal:
	mov bytes_on_row, 10h
return1:
	retn
bytes_on_row_calculating endp
;-------------------------------------------------------------------------------------------
show_this_row proc near
	push ax
	xor ax, ax
	mov al, row
	push ax
	push ebx

	sub row, cl
	inc row
zero_manage:
	xor ebx, ebx
	mov bl, row
	shl bx, 4
	add ebx, index
	sub ebx, 10h
	call near ptr coordinate_calculating		;偏移地址计算
	call near ptr sub_show_this_row			;显示从buf[bp]开始的bytes_on_row个字节
	jmp ending6

ending6:
	pop ebx
	pop ax
	mov row, al
	pop ax
	retn
show_this_row endp
;-------------------------------------------------------------------------------------------
bytes_in_buf_calculating proc near			;缓存中有多少字节的计算
	push ebx
	push eax

	mov eax, file_size
	mov ebx, index
	sub eax, ebx
	cmp eax, 100h
	jae full
	jmp rest
full:
	mov bytes_in_buf, 100h
	jmp ending2
rest:
	mov bytes_in_buf, ax
ending2:
	pop eax
	pop ebx
	retn
bytes_in_buf_calculating endp
;-------------------------------------------------------------------------------------------
alternation proc near					;对于键盘输入做出相应的选择
	push ebx
	push eax
	push edx
	push ecx

	cmp ah, 49h
	je pageup
	cmp ah, 51h
	je pagedn
	cmp ah, 47h
	je home
	cmp ah, 4fh
	je ending4
	jmp return3

pageup:
	cmp index, 100h
	jb pageup_initialize
	sub index, 100h
	jmp return3
pageup_initialize:
	mov index, 0
	jmp return3

pagedn:
	xor ebx, ebx
	mov ebx, index
	add ebx, 100h
	cmp ebx, file_size
	jae return3
	mov index, ebx
	jmp return3

home:
	mov index, 0
	jmp return3

ending4:
	xor edx, edx
	xor eax, eax
	cmp file_size, 0
	je return3
	mov eax, file_size
	mov ebx, file_size
	rol eax, 16
	mov dx, ax
	rol eax, 16
	mov cx, 100h
	div cx
	cmp dx, 0
	je exactly
	sub ebx, edx
	mov index, ebx
	jmp return3
exactly:
	sub ebx, 100h
	mov index, ebx
	jmp return3

return3:
	pop ecx
	pop edx
	pop eax
	pop ebx
	retn
alternation endp
;-------------------------------------------------------------------------------------------
newline proc near					;回车换行函数
	push ax
	mov ah, 2					;输出回车和换行
	mov dl, 0Dh
	int 21h
	mov ah, 2
	mov dl, 0Ah
	int 21h;输出换行符
	pop ax
	retn
newline endp
;-------------------------------------------------------------------------------------------
code ends
end main