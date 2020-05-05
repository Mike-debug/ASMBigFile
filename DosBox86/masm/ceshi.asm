data segment
abc db 4,3,2,1  
    db 'ABCD'
xyz dw 1234h,5678h,0,0FFFFh
data ends
code segment
assume cs:code,ds:data
main:
    mov ax.data
    mov ds,ax
    mov ah,abc
    add ah,abc+2
    mov al,abc*4
    mov si,[abc+2]
    mov ch,abc[4]
    mov cl,[xyz+2]
    mov dx,xyz[1]
    mov ah,4ch
    int 21h
code ends
end main