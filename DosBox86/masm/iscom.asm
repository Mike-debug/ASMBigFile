code segment
assume cs:code, ds:code
org 100h
main:
    jmp begin
hi db 'It is a COM program.',0dh,0ah,'$'
begin:
    mov ah,9
    mov dx,offset hi
    int 21h   
    mov ah,4ch
    int 21h
code ends
end main