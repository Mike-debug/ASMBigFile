code segment
assume cs:code; cs����Ҫ��ֵ���Զ�����code
main:
   jmp begin
i  dw 0
begin:
   mov ax, 0013h
   int 10h
   mov ax, 0A000h
   mov es, ax
   ;(320/2, 200/2)
   mov di, (100-20)*320+(160-20); (160-20,100-20)
   ;mov cx, 41; rows=41
   mov i, 41
next_row:
   ;push cx
   push di
   mov al, 4; color=red
   mov cx, 41; dots=41
next_dot:
   mov es:[di], al
   add di, 1
   sub cx, 1
   jnz next_dot
   pop di; ���Ͻ�(x,y)��Ӧ�ĵ�ַ
   ;pop cx; cx=41
   add di, 320; ��һ�е����ĵ�ַ
   ;sub cx, 1; ����-1
   sub i, 1
   jnz next_row
   mov ah,0
   int 16h;bios��������,����int 21h��01h����
   mov ax, 0003h
   int 10h; �л���80*25�ı�ģʽ
   mov ah, 4Ch
   int 21h
code ends
end main