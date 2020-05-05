code segment
assume cs:code
main:
    mov ax,0B800h
    mov es,ax
    xor di,di
    mov cx,80*25
    mov ah,17h
    mov al,'A'
    cld
    rep stosw
    mov ah,0
    int 16h
    mov ah,4Ch
    int 21h
code ends
end main