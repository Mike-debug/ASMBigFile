;************************************汇编作业第三次******************************************
;*姓名：魏一鸣
;*学号：3150100565
;*专业：计算机科学与技术
;********************************************************************************************
;*程序说明：
;*1.可读取文件大小为0B到4,294,967,295B
;*2.本程序特别增加了读取零大小文件的功能
;********************************************************************************************
;*第二次提交说明：
;*第一次提交的不能读取大文件
;*因为在end键的除法处理时使用的是16位寄存器
;*本次提交文件在处理end的除法时使用32寄存器，可以读取大文件
;********************************************************************************************
.386
data segment use16
	filename db 100,?,100 dup(0)			;文件名
	buf db 	256 dup(?)				;放到缓存中的读取到的文件的内容
	handle dw 0					;文件句柄
	filesize dd ?					;文件大小，双字，所以最大文件大小为4,294,967,295B
	hint1 db "Please input filename:", 0Dh, 0Ah, '$';提示的输入文件名
	hint2 db "Cannot open file!", 0Dh, 0Ah, '$'	;打开文件失败时显示的字符串提示
	hint3 db "Cannot close file!", 0Dh, 0Ah, '$'	;关闭文件失败时显示的字符串提示
	s db "00000000: xx xx xx xx|xx xx xx xx|xx xx xx xx|xx xx xx xx  ................", 0Dh, 0Ah, '$'
							;s是用来输出的字符串，以上定义只是格式上的
	pattern db "00000000:            |           |           |                             ", 0Dh, 0Ah, '$'
							;pattern是用来初始化s的
	t db "0123456789ABCDEF"				;t用于十六进制转换
	row db 2					;第几行、需要显示几行
	bytes_on_row db 0h				;每行读多少字节
	index dd 0h					;每行的偏移地址
	bytes_in_buf dw 100h				;buf中有多少字节
	file_size dd 0h					;文件大小
data ends
stack1 segment use16					;堆栈段
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
	mov al, 2					;移动到末尾
	mov bx, handle					;保存句柄
	mov cx, 0
	mov dx, 0
	int 21h
	mov byte ptr file_size[2], dl			;这个写法只是我验证一下
	mov byte ptr file_size[3], dh			;简单的可以写成
	mov byte ptr file_size[0], al			;mov word ptr file_size[2], dx
	mov byte ptr file_size[1], ah			;mov word ptr file_size[0], ax
	
display_by_control:
	call near ptr bytes_in_buf_calculating
	mov ah, 42h
	mov al, 0					;指针移动到开始
	mov bx, handle
	mov cx, word ptr index[2]			;cx:dx构成文件指针偏移地址
	mov dx, word ptr index[0]
	int 21h

	mov ah, 3fh					;开始读入文件，最大1024B
	mov dx, offset buf
	mov cx, bytes_in_buf
	mov bx, handle
	int 21h

	;以下是内存界面显示
	call near ptr show_this_page			;显示一页
	mov ah,0
	int 16h
	
	cmp ah, 1					;01h是Esc的键盘码，如果键盘输入Esc，则结束程序
	je ending

	call near ptr alternation
	jmp display_by_control

	mov bx, handle					;关闭文件
	mov ah, 3eh
	int 21h
	jc error1

ending:
	mov ah, 4ch
	int 21h
error:							;打开文件失败
	mov dx, offset hint2
	call near ptr outputchararray
	mov ah, 4ch
	int 21h
error1:							;关闭文件失败
	mov dx, offset hint3
	call near ptr outputchararray
	mov ah, 4ch
	int 21h
;-------------------------------------------------------------------------------------------
outputchararray proc near				;输出字符串函数，用于主函数中提示文字的输出
	push ax
	mov ah, 09h
	int 21h
	pop ax
	retn
outputchararray endp
;-------------------------------------------------------------------------------------------
convert8bit_to_hex proc near				;把存在bl中的数转成16进制存入s[si]和s[si+1]中
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
convert32bit_to_hex proc near				;把ebx中的32位数字转成十六进制
	push cx
	push si
	push ebx

	xor cx, cx
	mov cx, 4					;每次循环移动8位，左移需要循环4次
convert:
	rol ebx, 8h
	call near ptr convert8bit_to_hex		;调用8位二进制转16进制函数
	inc si
	inc si
	loop convert

	pop ebx
	pop si
	pop cx
	retn
convert32bit_to_hex endp
;-------------------------------------------------------------------------------------------
cleanscreen proc near					;清屏函数
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
coordinate_calculating proc near			;偏移地址计算函数，其实包含了初始化s的功能，即把s初始化为pattern
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
strcpy_s_pattern:					;初始化s
	mov dl,pattern[si]
	mov s[si],dl
	inc si
	loop strcpy_s_pattern
	pop si
	
	push si
	mov si, 0h					;偏移地址在最开始，从s[0]显示
	call near ptr convert32bit_to_hex		;调用32位二进制转16进制函数计算当前行偏移地址
	pop si

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	retn
coordinate_calculating endp
;-------------------------------------------------------------------------------------------
sub_show_this_row  proc near				;ebx中放的是偏移地址offset，buf是内容;bytes_on_row是每行多少字节
	push ax
	push di
	push cx
	push dx
	push bx
	push si
	push bp
	
	cmp cl, 0
	je zero_manage1					;零大小文件跳过ascll码转换过程，不处理
	
	xor bx, bx
	xor dx, dx
	xor cx, cx
	xor di, di
	mov cl, bytes_on_row
	xor si, si
	mov si, 10					;s中内存的内容从s[10]开始修改
	mov di, 59					;s中内存代表的ascll码从s[59]开始修改
move_buf_to_s:
	mov bl, buf[bp]
	mov s[di], bl

	call near ptr convert8bit_to_hex		;调用8位二进制转16进制函数转换ascll码符
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
	call near ptr print				;显示函数
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
	
	cld						;正方向显示
	stosw						;投映到屏幕

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
	cmp s[si], '|'					;把用于分隔竖线的前景色设为高亮度白色
	je lit
	mov ah, 07h
	jmp return
lit:
	mov ah, 0fh					;其它字符的前景色设为白色
	jmp return
color endp
;-------------------------------------------------------------------------------------------
coordinate proc near					;根据row值，计算di坐标，视频坐标
	push ax
	push bx
	
	xor ax, ax
	xor bx, bx
	mov al, row
	dec al
	mov bl, 160					;每行同列坐标相差160
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
row_calculating proc near				;计算当前页需要显示多少行
	push bx
	push ax

	xor ax, ax
	xor bx, bx
	mov ax, bytes_in_buf
	add ax, 0fh
	mov bl, 10h
	div bl						;把缓存中的字节数除以16，即可得到行数，存在row中
	mov row, al

	pop ax
	pop bx
	retn
row_calculating endp
;-------------------------------------------------------------------------------------------
printrows proc near					;显示许多行的函数
	push cx

	xor cx, cx
	mov cl, row
	cmp cl, 0					;读大小为0的文件
	je single					;考虑到0大小文件需要单独处理
	xor bp, bp
displayrow:
	call near ptr bytes_on_row_calculating		;偏移地址计算
	call near ptr show_this_row			;内容显示
	add bp, 10h	
	loop displayrow
	jmp return5	

single:
	call near ptr bytes_on_row_calculating		;偏移地址计算
	call near ptr show_this_row			;内容显示

return5:
	pop cx
	retn
printrows endp
;-------------------------------------------------------------------------------------------
bytes_on_row_calculating proc near			;用来计算当前行有多少字节
	cmp cx, 1
	jne ordinal					;如果不是最后一次循环，当前行必然16字节

	push ax
	push bx
	xor ax, ax
	xor bx, bx
	mov ax, bytes_in_buf				;根据当前缓存中的字节数和当前页行数决定当前行显示的字节数
	mov bl, 10h
	div bl						;显示当前页的字节数除以16，得到行数，和每行字节数
	cmp ah, 0
	je adjust					;若刚好整除，则每行字节数应当为16字节
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
show_this_row proc near					;显示一行的函数
	push ax
	xor ax, ax
	mov al, row					;存放row值
	push ax
	push ebx

	sub row, cl					;用row和当前index计算将要显示行的偏移地址，放到ebx中
	inc row						;但是因为index初始本来为零，因此实际现实中把ebx再减10h
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
	cmp eax, 100h					;如果偏移地址大小与文件大小差大于256，则满屏显示，缓存中放256字节
	jae full					;否则放的字节数为两者差
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
alternation proc near					;对于键盘输入做出相应的选择，Esc键处理在主函数中
	push ebx
	push eax
	push edx
	push ecx
							;根据键盘码选择相应的动作
	cmp ah, 49h					;pageup的键盘码
	je pageup
	cmp ah, 51h					;pagedown的键盘码
	je pagedn
	cmp ah, 47h					;home的键盘码
	je home
	cmp ah, 4fh					;end的键盘码
	je ending4
	jmp return3

pageup:
	cmp index, 100h					;判断目前偏移地址大小
	jb pageup_initialize				;如果偏移地址已经小鱼一页的字符数（256），则直接从偏移地址为0的地方开始显示一页
	sub index, 100h					;否则向上翻页
	jmp return3
pageup_initialize:
	mov index, 0
	jmp return3

pagedn:
	xor ebx, ebx
	mov ebx, index
	add ebx, 100h					;计算偏移地址如果成功向下翻页后的值
	cmp ebx, file_size				;然后与文件大小比较
	jae return3					;如果比文件大小还大，则显示最后部分
	cmp ebx, index					;如果最后产生进位，也显示最后部分，因为进位后的实际偏移地址值必然大于文件大小
	jb return3
	mov index, ebx
	jmp return3

home:
	mov index, 0					;home键显示偏移地址为0的页面
	jmp return3

ending4:						;end键
	xor edx, edx
	xor eax, eax
	cmp file_size, 0				;判断文件大小是不是0
	je return3					;若是，不做操作
	mov eax, file_size
	mov ebx, file_size
	mov ecx, 100h
	div ecx						;用除法计算文件最后一页有多少字节
	cmp edx, 0					;如果计算最后一页是0字节，则显示上一页，即最后256字节
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
newline proc near					;回车换行函数，在输入文件名后需要换行
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