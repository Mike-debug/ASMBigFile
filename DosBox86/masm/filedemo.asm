data segment
	file1 db 'filedemo.asm',0;源文件名
	file2 db 'filecopy.asm',0;目标文件名
	handle1 dw 0		;源文件句柄
	handle2 dw 0		;目标文件句柄
	buf db 0		;数据缓冲区
data ends
code segment
assume cs:code,ds:data
main:
	mov ax, data
	mov ds, ax
	mov ah, 3dh					;打开文件功能好
	mov al, 0					;al=0,只读方式
	mov dx, offset file1				;ds:dx->源文件名
	int 21h						;打开源文件
	jc exit						;若有错则转exit
	mov [handle2], ax				;保存目标文件句柄
	mov ah, 3ch					;创建文件功能号
	mov cx, 0					;cx=0 普通属性文件
	mov dx, offset file2				;ds:dx->目标文件名
	int 21h						;创建目标文件
	jc exit						;若有错则转exit
	mov [handle2], ax				;保存目标文件句柄
again:
	mov ah, 3fh					;读取文件功能号
	mov bx, [handle1]				;bx=源文件句柄
	mov cx, 1					;cx=1每次读取一个字节
	mov dx, offset buf				;ds:dx->数据缓冲区
	int 21h						;读取文件
	jc done						;每次读取一个字节
	or ax, ax					;
	jz done						;若ax==0则表示源文件结束，无内容可读，转done

	mov ah, 40h					;写入文件功能号
	mov bx, [handle2]				;bx=目标文件句柄
	mov cx, 1					;cx=1, 每次写入一个字节
	mov dx, offset buf				;ds:dx->数据缓冲区
	int 21h						;写入文件
	mov ah, 2					;显示字符号功能
	mov dl, [buf]					;dl=缓冲区中的内容
	int 21h						;在屏幕上显示缓冲区中的内容
	jmp again					;循环
done:
	mov ah,3eh					;关闭文件功能号
	mov bx, [handle1]				;bx=源文件句柄
	int 21h						;关闭源文件
	mov ah, 3eh					;
	mov bx, [handle2]
	int 21h						;关闭目标文件
exit:
	mov ah, 4ch
	int 21h						;结束程序
code ends
end main