    code segment
assume cs:code
main:
    mov ax,0B800h
    mov es,ax               ;显存地址
    mov ah,7                ;向下卷屏
    mov al,0                ;清屏
    mov bh,0                ;清屏后空白部分属性为黑色
    mov ch,0                ;清屏左上角行坐标
    mov cl,0                ;清屏左上角列坐标
    mov dh,24               ;清屏右下角行坐标
    mov dl,79               ;清屏右下角列坐标
    int 10h

	mov di, 0;
	mov ah, 17h
	mov al, 'A'
	cld
	stosw
	stosw

    mov ah,0
    int 16h
done:
    mov ah,4Ch
    int 21h
    

    code ends
end main