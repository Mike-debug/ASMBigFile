
data segment
a db "ABC"
s db "Hello$world!", 0Dh, 0Ah, 0
data ends
code segment
assume cs:code, ds:data
main:
   mov ax, data
   mov ds, ax
   mov bx, 0
next:
   mov dl, s[bx]; 经过编译后变成mov dl, ds:[3+bx]
   cmp dl, 0
   je exit
   mov ah, 2
   int 21h
   add bx, 1
   jmp next
exit:
   mov ah, 4Ch
   int 21h
code ends
end main