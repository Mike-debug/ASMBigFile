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