.386 ; ��ʾ�����л���32λ�ļĴ���
data segment use16; use16��ʾƫ��ʹ��16λ
t db "0123456789ABCDEF"
x dd 2147483647
data ends

code segment use16
assume cs:code, ds:data
main:
   mov ax, data    ;\
   mov ds, ax      ; / ds:bx->t[0]
   mov bx, offset t;/
   mov ecx, 8
   mov eax, x
next:
   rol eax, 4
   push eax
   and eax, 0Fh
   xlat
   mov ah, 2
   mov dl, al
   int 21h
   pop eax
   sub ecx, 1
   jnz next
   mov ah, 4Ch
   int 21h
code ends
end main