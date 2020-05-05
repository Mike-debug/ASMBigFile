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



    mov bx,0
    mov di,0
    xor al,al
again0:                     ;换列循环
    push bx
    push di
    add bx,160*24
again1:                     ;换行循环
    mov ah,4                ;输出Ascll字符
    cld
    stosw

    push ax
    and ax,00ffh            ;计算字符ASCLL码
    mov cl,10h
    div cl
    mov ch,ah

    add al,30h
    mov ah,2                ;输出十位数
    cmp al,39h
    ja convert2             ;大于十的数需要转换

cv2:
    cld
    stosw

    mov al,ch
    add al,30h              ;输出个位数
    cmp al,39h
    ja convert1             ;大于十的数需要转换
cv1:
    cld
    stosw
    
    pop ax

    inc al
    cmp al,0h               ;溢出的时候停止输出
    je done                 ;到0FF结束
    
    sub di,6
    add di,160              ;同一列增加一行
    cmp di,bx
    jbe again1

    pop di                  
    add di,14               ;间隔是7列
    pop bx
    add bx,14
    cmp bx,140              ;输出不超过10列
    jbe again0


    mov ah,0
    int 16h
done:
    mov ah,4Ch
    int 21h
    
convert1:                   ;大于十的十六进制数转换
    add al,7h
    jmp cv1

convert2:
    add al,7h
    jmp cv2

    code ends
end main