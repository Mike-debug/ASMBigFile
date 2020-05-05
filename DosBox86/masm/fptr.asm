data segment
video_addr dw 0000h, 0B800h, 160, 0B800h
;上述定义也可以写成:
;video_addr dd 0B8000000h, 0B80000A0h
data ends
code segment
assume cs:code, ds:data
main:
   mov ax, data
   mov ds, ax
   mov bx, 0
   mov cx, 2
next:
   les di, dword ptr video_addr[bx]
   mov word ptr es:[di], 1741h
   add bx, 4
   sub cx, 1
   jnz next
   mov ah, 1
   int 21h
   mov ah, 4Ch
   int 21h
code ends
end main

