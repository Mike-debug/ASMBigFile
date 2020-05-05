data segment
    A dw 1234h
    B dw 5678h
    C dw 1545h
    D dw 7841h
    S1 dw ?
    S2 dw ?
data ends
code segment
assume cs:code, ds:data, ss:stk
main:
    mov ax, data
    mov ds, ax
    mov ax, A
    imul B
    mov cx, ax
    mov bx, dx
    mov ax, B
    sub ax, D
    imul C
    sub cx, ax
    sbb bx, dx
    sub cx, 50
    sbb dx, 0
    mov ax, cx
    mov dx, bx
    xor bx, bx
    mov cx, A
    add cx, B
    adc bx, 0
    add cx, 20
    adc bx, 0
    idiv cx
    mov S1, ax
    mov S2, dx
    mov ah, 4Ch
    int 21h
code ends
stk segment
    dw 100h dup(0)
stk ends
end main
    