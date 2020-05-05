;第二次汇编作业
;魏一鸣
;3150100565
;计科1704
;1781937775@qq.com
.386
data segment use16					;程序使用32位寄存器
	num1 db 6; 允许输入的最多字符数（含回车）为6	;第一个输入的数
	       db ?;  实际输入的字符数
	       db 6 dup(?) ;保存输入的字符
	num2 db 6; 允许输入的最多字符数（含回车）为6	;第二个输入的数
	       db ?;  实际输入的字符数
	       db 6 dup(?) ;保存输入的字符
	decinum db 10 dup(0),0dh,0ah,'$'			;用于存放十进制运算结果
data ends
stack1 segment stack use16
	dw 1000h dup(?)					;堆栈段
stack1 ends


code segment use16
	assume cs:code,ds:data,ss:stack1;
start:
	mov ax, data
	mov ds, ax					;段地址赋值

	mov ah, 0Ah					;输入第一个乘数（五位字符串）
	mov dx, offset num1
	int 21h
	call near ptr newline				;调用回车换行函数
	
	mov ah, 0Ah					;输入第二个乘数（五位字符串）
	mov dx, offset num2
	int 21h
	call near ptr newline				;调用回车换行函数

output1:	
	xor cx, cx;cx=0
	mov cl, num1[1];cl=实际输入数
	jcxz output2;若输入的字符数为0个则跳转至output2
	mov si, offset num1+2;ds:si->已输入字符串的首字符
	call near ptr output				;调用循环输出函数

	mov dl, '*'					;乘号*输出
	call near ptr Tester				;Tester函数为输出当前dl对应ASCLL码字符
output2:
	xor cx, cx;cx=0
	mov cl, num2[1];cl=实际输入数
	jcxz done;若输入的字符数为0个则跳转至done
	mov si, offset num2+2;ds:si->已输入字符串的首字符
	call near ptr output				;调用循环输出函数

	mov dl, '='
	call near ptr Tester
	call near ptr newline				;调用回车换行函数
	
	xor bx, bx
	xor cx, cx
	xor dx, dx
	mov di, 2h
	mov cl, num1[1]
load1:							;将第一个数读入到bx中
	push cx
	mov cl, num1[di]
	sub cl, 30h
	call near ptr multi10				;每读入一个字符，bx乘10，再加这个字符表示的数字
	add bx, cx
	inc di
	pop cx
	loop load1

	mov ax, bx
	xor bx, bx
	xor cx, cx
	xor dx, dx
	mov di, 2h
	mov cl, num2[1]
load2:							;将第二个数读入到bx中
	push cx
	mov cl, num2[di]
	sub cl, 30h
	call near ptr multi10				;每读入一个字符，bx乘10，再加这个字符表示的数字
	add bx, cx
	inc di
	pop cx
	loop load2
	
	mul bx						;dx:ax中已经存入运算结果
	
	call near ptr decimal				;十进制显示
	call near ptr hex				;十六进制显示
	call near ptr binary				;二进制显示


done:
	mov ah, 4Ch					;结束程序
	int 21h
;==========================================================================================================
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
;==========================================================================================================
output proc near					;输出当前dx:dl开始的字符串
again:
	mov ah, 2
	mov dl, [si];从输入的字符串中逐个取出字符串
	int 21h;显示取出的字符
	inc si;准备取出下一个字符
	loop again
	retn
output endp
;==========================================================================================================
multi10 proc near					;bx乘10函数，把bx中存放的值乘10
	push dx
	push cx
	xor dx, dx
	xor cx, cx
	mov dx, bx					;dx=bx
	mov cl, 3					
	shl bx, cl					;bx左移3位，相当于乘8
	shl dx, 1					;dx左移1位，相当于乘2
	add bx, dx					;bx=bx+dx,,此时bx为函数初始时十倍
	pop cx
	pop dx
	retn
multi10 endp
;==========================================================================================================
hex proc near						;十六进制输出函数，通过循环移位实现
	push cx
	push dx

	mov bx, dx					
	call near ptr rotate_hex			;调用输出运算结果高16位的十六进制数
	mov bx, ax
	call near ptr rotate_hex			;调用输出运算结果低16位的十六进制数
	mov dl, 'h'					;输出十六进制标志“h”
	call near ptr Tester				;Tester函数原来是我用来测试dl和其他寄存器中的值的，这里用来输出字符
	call near ptr newline				;调用回车换行函数
	pop dx
	pop cx

	retn
hex endp
;==========================================================================================================
convert proc near					;将大于9的十六进制字符转换成字母
	cmp dl, 39h
	ja is_above
	jmp convert_done
is_above:
	add dl, 7h					;对于大于9的十六进制数，需要转换成字母，根据ASCLL码，加上7
convert_done:
	retn
convert endp
;==========================================================================================================
rotate_hex proc near					;以十六进制显示bx中的字符
	push ax
	push cx
	push dx
	xor ax, ax
	xor cx, cx
	mov cl, 4					;运算结果首先存储在dx:ax中，十六进制位占4个二进制位，需要循环移动4次实现
rotate:
	push cx
	xor cx, cx
	mov cx, 4					;每次移动四个bit
	rol bx, cl
	mov dx, bx
	and dx, 0fh
	add dl, 30h					;调整ASCLL码到表示数字
	call near ptr convert				;将大于9的数字转换成字母
	mov ah, 02h
	int 21h
	pop cx
	loop rotate
	
	pop dx
	pop cx
	pop ax
	retn
rotate_hex endp
;==========================================================================================================
Tester proc near					;Tester函数原来是我用来测试dl和其他寄存器中的值的，因为也可以用来
	push ax						;输出字符，所以也保留下来了
	xor ax, ax
	mov ah, 02h
	int 21h
	pop ax
	retn
Tester endp
;==========================================================================================================
binary proc near					;二进制输出函数
	push cx
	push dx
	
	mov bx, dx					;首先输出dx中的数字
	call near ptr four_bit				;因为考虑到空格输出问题，所以把高四位先输出
	call near ptr fit_12				;继续输出剩余12位
	
	mov dl, ' '
	call near ptr Tester

	mov bx, ax					;用同样的方法输出ax中的数值
	call near ptr four_bit				
	call near ptr fit_12

	mov dl, 'B'					;"B"为二进制标志
	call near ptr Tester
	call near ptr newline				;调用回车换行函数
	pop dx
	pop cx
	retn
binary endp
;==========================================================================================================
fit_12 proc near					;输出十二位二进制数字函数
	push dx
	push cx
	xor cx, cx
	mov cl, 03h

Three_group:
	mov dl, ' '
	call near ptr Tester
	call near ptr four_bit				;连续调用三次输出四位二进制函数
	
	loop Three_group
	
	pop cx
	pop dx
	retn
fit_12 endp
;==========================================================================================================
four_bit proc near					;输出四位二进制函数
	push dx
	push cx
	xor cx, cx
	mov cl, 04h					;通过连续移位4次实现
iteration:
	rol bx, 1
	jnc out_0					;通过判断符号位CF决定输出是0还是1
out_1:
	mov dl, '1'
	call near ptr Tester
	jmp endout
out_0:
	mov dl, '0'
	call near ptr Tester
endout:
	loop iteration
	pop cx
	pop dx
	retn
four_bit endp
;==========================================================================================================
decimal proc near					;十进制输出函数
	push ax
	push dx
	push cx
	push si

	xor cx, cx
	mov cx, 10h	
	push ax
	mov ax, dx
	shl eax, cl
	pop ax						;完成运算结果导入eax中，eax作被除数

	mov ebx, 0ah					;ebx作除数
	mov si, 9					;si用作变量decinum的偏移地址
	mov ecx, 10					;本程序所得结果最多为十位十进制数，所以只需要循环10次即可
circulation:
	xor edx, edx
	div ebx						;eax每次除以ebx后，余数保存皂edx中，eax中为商
	mov byte ptr [decinum+si], dl			;将dl中的余数保存到变量中
	add byte ptr [decinum+si], 30h			;将变量中保存到十进制数值转换成响应的ASCLL字符
	dec si						;si自减，准备存放下一个余数到高一位
	loop circulation

	inc si						;取余运算结束后si多减了一次，所以加上
locate:							;定位标号，定位到变量decinum中十进制数的第一个不为零的地址
	mov dl, decinum[si]				;第一次循环其实是把变量首地址赋值给dl，因为之后循环会用到si，所以这里直接用了si代替0
	inc si						;si自加，取更低位
	cmp dl, '0'					;每次把dl和‘0’作比较，如果得到dl非零，则结束循环
	je locate

	dec si
	mov cx, 10
	sub cx, si
	mov bp, offset decinum				;把变量首字符的偏移地址赋值给bp
	add si, bp					;si加上bp为首个非零字符的开始
	call near ptr output				;调用输出字符串函数
;display:						
;	mov dl, decinum[si]				;这是另一种输出方式，逐个字符输出
;	call near ptr Tester
;	inc si
;	loop display

decimalend:						;结束十进制输出函数的标号
	call near ptr newline				;回车换行
	pop si
	pop cx
	pop dx
	pop ax
	retn
decimal endp
;==========================================================================================================
code ends			
	end start					;程序结束
