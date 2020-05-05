data segment
filename db "abc.txt", 0
handle dw 0
buf    db 10 dup(0)
data ends
code segment
assume cs:code, ds:data
main:
   mov ax, data
   mov ds, ax
   mov ah, 3Dh; open
   mov al, 0; ReadOnly
   mov dx, offset filename
   int 21h
   jc error
   mov handle, ax; ±£´æÎÄ¼þ¾ä±ú
   mov ah, 3Fh; read
   mov bx, handle
   mov cx, 3
   mov dx, offset buf
   int 21h
   mov ah, 3Eh; close file
   mov bx, handle
   int 21h
   mov buf[3], '$'
   mov ah, 9
   mov dx, offset buf
   int 21h
error:
   mov ah, 4Ch
   int 21h
code ends
end main