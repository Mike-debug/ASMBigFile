data segment
video_addr dw 0000h, 160
data ends
code segment
assume cs:code, ds:data
main:
   mov ax, data
   mov ds, ax
   mov ax, 0B800h
   mov es, ax
   mov bx, 0
   mov cx, 2
next:
   mov di, video_addr[bx]
   mov word ptr es:[di], 1741h
   add bx, 2
   sub cx, 1
   jnz next
   mov ah, 1
   int 21h
   mov ah, 4Ch
   int 21h
code ends
end main

