code segment
assume cs:code, ds:code, es:code
main:
   push cs
   pop ds; DS=CS
   push cs
   pop es; ES=CS
   cld
   mov ah, 2
   mov dl, 'A'
   int 21h
   mov si, offset begin_flag
   mov di, 1000h
   mov cx, offset end_flag-offset begin_flag
   rep movsb
   mov cx, offset end_flag - offset main
   mov di, offset main
   mov bx, 1000h
   jmp bx
begin_flag:
   jmp next
next:
   mov al, 0
   rep stosb
   mov ah, 2
   mov dl, 'B'
   int 21h
   mov ah, 4Ch
   int 21h
end_flag:
code ends
end main