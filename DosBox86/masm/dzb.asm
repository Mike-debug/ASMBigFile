comment #
    y          x
16λ�ε�ַ:32λƫ�Ƶ�ַ
t��һ�ű�
t+y->64λ��ֵ, ���е�32λ��ʾy����εĶ��׵�ַ
����Ѱַģʽ��Ϊ����ģʽ(protected mode)
    y          x
16λ�ε�ַ:16λƫ�Ƶ�ַ
y*10h+x�õ������ַ����Ѱַģʽ��Ϊʵģʽ(real
mode)��dos�����������cpu�л���ʵģʽ������
����ģʽ; windows/linux�����������cpu�л���
����ģʽ��
#
.386
data segment use16
s db "2147483647", 0; 7FFF FFFFh
abc dd 0
data ends
code segment use16
assume cs:code, ds:data
main:
   mov ax, data
   mov ds, ax
   mov eax, 0; ������
   mov si, 0; ����s���±�
again:
   cmp s[si], 0; �ж��Ƿ񵽴�����Ľ�����־
   je done
   mov ebx, 10
   mul ebx; EDX:EAX=�˻�, ����EDX=0
          ; ��д��imul eax, ebx
   mov edx, 0
   mov dl, s[si]; DL='1'
   sub dl, '0'
   add eax, edx
   ;mov dl, s[si]
   ;sub dl, '0'
   ;movzx edx, dl
   ;add eax, edx
   inc si
   jmp again
done:
   mov abc, eax
   mov ah, 4Ch
   int 21h
code ends
end main

