code segment
assume cs:code
main:
    mov ax,0B800h
    mov es,ax
    mov ah,7
    mov al,0
    mov bh,0
    mov ch,0
    mov cl,0
    mov dh,24
    mov dl,79
    int 10h



    mov bx,0
    mov di,0
    xor al,al
again0:                     ;换列
    push bx
    push di
    add bx,160*24
again1:                     ;输行
    mov ah,4                ;输出字符
    cld
    stosw

    push ax
    and ax,00ffh
    mov cl,10h
    div cl
    mov ch,ah

    add al,30h
    mov ah,2                ;输出十位数
    cmp al,39h
    ja convert2

cv2:
    cld
    stosw

    mov al,ch
    add al,30h              ;输出个位数
    cmp al,39h
    ja convert1
cv1:
    cld
    stosw
    
    pop ax

    inc al
    cmp al,0h
    je done                ;到0FF结束
    
    sub di,6
    add di,160
    cmp di,bx
    jbe again1

    pop di
    add di,14
    pop bx
    add bx,14
    cmp bx,140
    jbe again0


    mov ah,0
    int 16h
done:
    mov ah,4Ch
    int 21h
    
convert1:
    add al,7h
    jmp cv1

convert2:
    add al,7h
    jmp cv2

    code ends
end main