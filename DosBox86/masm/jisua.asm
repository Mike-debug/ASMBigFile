data segment
    x db 10
    y dw ?
data ends
code segment
assume cs:code,ds:data
main:
    mov al, x
    mul al
    mov cx, ax
    mov al, 8
    mov bl, x
    mul bl
    add ax, cx
    sub ax, 30
    mov y, ax
    mov ah, 2
    int 21h
    mov ah, 4ch
    int 21h
code ends
end main