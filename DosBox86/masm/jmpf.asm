code segment
assume cs:code
main:
	;jmp
	db 0eah
	dw 7856h
	dw 3412h
	;dd 0ffff0000h;�����������
code ends
end main