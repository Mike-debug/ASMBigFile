    code segment
assume cs:code
main:
    mov ax,0B800h
    mov es,ax               ;�Դ��ַ
    mov ah,7                ;���¾���
    mov al,0                ;����
    mov bh,0                ;������հײ�������Ϊ��ɫ
    mov ch,0                ;�������Ͻ�������
    mov cl,0                ;�������Ͻ�������
    mov dh,24               ;�������½�������
    mov dl,79               ;�������½�������
    int 10h



    mov bx,0
    mov di,0
    xor al,al
again0:                     ;����ѭ��
    push bx
    push di
    add bx,160*24
again1:                     ;����ѭ��
    mov ah,4                ;���Ascll�ַ�
    cld
    stosw

    push ax
    and ax,00ffh            ;�����ַ�ASCLL��
    mov cl,10h
    div cl
    mov ch,ah

    add al,30h
    mov ah,2                ;���ʮλ��
    cmp al,39h
    ja convert2             ;����ʮ������Ҫת��

cv2:
    cld
    stosw

    mov al,ch
    add al,30h              ;�����λ��
    cmp al,39h
    ja convert1             ;����ʮ������Ҫת��
cv1:
    cld
    stosw
    
    pop ax

    inc al
    cmp al,0h               ;�����ʱ��ֹͣ���
    je done                 ;��0FF����
    
    sub di,6
    add di,160              ;ͬһ������һ��
    cmp di,bx
    jbe again1

    pop di                  
    add di,14               ;�����7��
    pop bx
    add bx,14
    cmp bx,140              ;���������10��
    jbe again0


    mov ah,0
    int 16h
done:
    mov ah,4Ch
    int 21h
    
convert1:                   ;����ʮ��ʮ��������ת��
    add al,7h
    jmp cv1

convert2:
    add al,7h
    jmp cv2

    code ends
end main