NOTE_1  =  440 ; ����Ƶ��
NOTE_2  =  495
NOTE_3  =  550
NOTE_4  =  587
NOTE_5  =  660
NOTE_6  =  733
NOTE_7  =  825

ONE_BEEP  =  600 ; һ����ʱ600ms
HALF_BEEP =  300 ; ������ʱ300ms

data segment
ticks dw 0
music dw  NOTE_5, ONE_BEEP
dw  NOTE_3, HALF_BEEP
dw  NOTE_5, HALF_BEEP
dw  NOTE_1*2, ONE_BEEP*2
dw  NOTE_6, ONE_BEEP
dw  NOTE_1*2, ONE_BEEP
dw  NOTE_5, ONE_BEEP*2
dw  NOTE_5, ONE_BEEP
dw  NOTE_1, HALF_BEEP
dw  NOTE_2, HALF_BEEP
dw  NOTE_3, ONE_BEEP
dw  NOTE_2, HALF_BEEP
dw  NOTE_1, HALF_BEEP
dw  NOTE_2, ONE_BEEP*4
dw  NOTE_5, ONE_BEEP
dw  NOTE_3, HALF_BEEP
dw  NOTE_5, HALF_BEEP
dw  NOTE_1*2, HALF_BEEP*3
dw  NOTE_7, HALF_BEEP
dw  NOTE_6, ONE_BEEP
dw  NOTE_1*2, ONE_BEEP
dw  NOTE_5, ONE_BEEP*2
dw  NOTE_5, ONE_BEEP
dw  NOTE_2, HALF_BEEP
dw  NOTE_3, HALF_BEEP
dw  NOTE_4, HALF_BEEP*3
dw  NOTE_7/2, HALF_BEEP
dw  NOTE_1, ONE_BEEP*4
dw  NOTE_6, ONE_BEEP
dw  NOTE_1*2, ONE_BEEP
dw  NOTE_1*2, ONE_BEEP*2
dw  NOTE_7, ONE_BEEP
dw  NOTE_6, HALF_BEEP
dw  NOTE_7, HALF_BEEP
dw  NOTE_1*2, ONE_BEEP*2
dw  NOTE_6, HALF_BEEP
dw  NOTE_7, HALF_BEEP
dw  NOTE_1*2, HALF_BEEP
dw  NOTE_6, HALF_BEEP
dw  NOTE_6, HALF_BEEP
dw  NOTE_5, HALF_BEEP
dw  NOTE_3, HALF_BEEP
dw  NOTE_1, HALF_BEEP
dw  NOTE_2, ONE_BEEP*4
dw  NOTE_5, ONE_BEEP
dw  NOTE_3, HALF_BEEP
dw  NOTE_5, HALF_BEEP
dw  NOTE_1*2, HALF_BEEP*3
dw  NOTE_7, HALF_BEEP
dw  NOTE_6, ONE_BEEP
dw  NOTE_1*2, ONE_BEEP
dw  NOTE_5, ONE_BEEP*2
dw  NOTE_5, ONE_BEEP
dw  NOTE_2, HALF_BEEP
dw  NOTE_3, HALF_BEEP
dw  NOTE_4, HALF_BEEP*3
dw  NOTE_7/2, HALF_BEEP
dw  NOTE_1, ONE_BEEP*3
dw  0, 0
data ends

code segment
assume cs:code, ds:data, ss:stk
main:
   mov ax, data
   mov ds, ax
   xor ax, ax
   mov es, ax
   mov bx, 8*4
   mov ax, es:[bx]
   mov dx, es:[bx+2]   ; ȡint 8h���ж�����
   mov cs:old_int8h[0], ax
   mov cs:old_int8h[2], dx; ����int 8h���ж�����
   cli
   mov word ptr es:[bx], offset int_8h
   mov es:[bx+2], cs   ; �޸�int 8h���ж�����
   mov al, 36h
   out 43h, al
   mov dx, 0012h
   mov ax, 34DCh       ; DX:AX=1193180
   mov cx, 1000
   div cx              ; AX=1193180/1000
   out 40h, al
   mov al, ah
   out 40h, al         ; ����ʱ����Ƶ��Ϊ1000��/��
   sti
   mov si, offset music
   cld
again:
   lodsw
   test ax, ax
   jz done
   call frequency
   lodsw
   call delay
   jmp again
done:
   cli
   mov ax, cs:old_int8h[0]
   mov dx, cs:old_int8h[2]
   mov es:[bx], ax
   mov es:[bx+2], dx   ; �ָ�int 8h���ж�����
   mov al, 36h
   out 43h, al
   mov al, 0
   out 40h, al
   mov al, 0
   out 40h, al         ; �ָ�ʱ����Ƶ��Ϊ1193180/65536=18.2��/��
   sti
   mov ah, 4Ch
   int 21h

frequency:
   push cx
   push dx
   mov cx, ax   ; CX=frequency
   mov dx, 0012h
   mov ax, 34DCh; DX:AX=1193180
   div cx       ; AX=1193180/frequency
   pop dx
   pop cx
   cli
   push ax
   mov al, 0B6h
   out 43h, al
   pop ax
   out 42h, al ; n�ĵ�8λ
   mov al, ah
   out 42h, al ; n�ĸ�8λ 
               ; ÿ��n��tick����һ����
               ; ��Ƶ��=1193180/n (��/��)
   sti
   ret

delay:
   push ax
   cli
   in al, 61h
   or al, 3
   out 61h, al; ������
   sti
   pop ax
   mov [ticks], ax
wait_this_delay:
   cmp [ticks], 0
   jne wait_this_delay
   cli
   in al, 61h
   and al, not 3
   out 61h, al; ������
   sti
   ret

int_8h:
   push ax
   push ds
   mov ax, data
   mov ds, ax
   cmp [ticks], 0
   je skip
   dec [ticks]
skip:
   pop ds
   pop ax
   jmp dword ptr cs:[old_int8h]
old_int8h dw 0, 0
code ends

stk segment stack
dw 100h dup(0)
stk ends
end main