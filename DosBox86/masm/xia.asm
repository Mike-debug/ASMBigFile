data segment
addr1 dw offset beep
addr2 dw exit
data ends
code segment
assume cs:code,ds:data
begin:
    mov bx, offset are_you_ready?
    jmp bx;
main:
    mov ax,data
    mov ds,ax
    jmp begin
are_you_ready?:
    jmp [addr1]
exit:
    mov ah, 4Ch
    int 21h
beep:
    mov ah,2
    mov dl,7
    int 21h
    jmp [addr2]
code ends
end main