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
    mov cx,1
    mov ah,4
    cld
    rep stosw
    
    inc al
    cmp al,0ffh
    jae done                ;到0FF结束
    sub di,2
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
code ends
end main