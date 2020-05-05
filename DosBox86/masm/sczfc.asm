data segment
poem db 'Stray birds of summer come to my window to sing',0DH,0AH
     db 'and fly away. And yellow leaves of autumn which',0DH,0AH
     db 'have no songs flutter and fall there with a sign.',0Dh,0Ah
len = $ - offset poem
data ends
code segment
assume cs:code, ds:data
main:
    mov ax,data
    mov ds,ax
    mov bx,offset poem
    mov cx,len
next:
    mov ah,2
    mov dl,[bx]
    int 21h
    inc bx
    loop next
    mov ah, 4Ch
    int 21h
code ends
end main