;Turbo Debugger����ʱ��
;��˵�View->Numeric Processor�鿴С����ջ
data segment
abc dd 3.14
xyz dd 2.0
result dd 0
data ends
code segment
assume cs:code, ds:data
main:
   mov ax, data
   mov ds, ax
   fld abc; ��3.14���뵽С����ջ
   fld xyz; ��2.0���뵽С����ջ
   fmul st, st(1); �������
   fstp result; ��������result��������
   fstp st      ; ����С����ջ�в����ֵ
   mov ah, 4Ch
   int 21h
code ends
end main

