comment #
    y          x
16位段地址:32位偏移地址
t是一张表
t+y->64位的值, 其中的32位表示y这个段的段首地址
这种寻址模式称为保护模式(protected mode)
    y          x
16位段地址:16位偏移地址
y*10h+x得到物理地址这种寻址模式称为实模式(real
mode)。dos启动后，它会把cpu切换到实模式，而非
保护模式; windows/linux启动后，它会把cpu切换到
保护模式。
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
   mov eax, 0; 被乘数
   mov si, 0; 数组s的下标
again:
   cmp s[si], 0; 判断是否到达数组的结束标志
   je done
   mov ebx, 10
   mul ebx; EDX:EAX=乘积, 其中EDX=0
          ; 或写成imul eax, ebx
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

