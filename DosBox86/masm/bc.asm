;************************************�����ҵ������******************************************
;*������κһ��
;*ѧ�ţ�3150100565
;*רҵ���������ѧ�뼼��
;********************************************************************************************
.386
data segment use16
	filename db 80,?,80 dup(?)
	buf db 	128,?,128 dup(?)
;	buf db 	"fcwk51@#xx!~ xx ", 0Dh, 0Ah, '$'
	handle dw 0
	filesize dd ?
	buf1 db "Please input filename:", 0Dh, 0Ah, '$'
	buf2 db "Cannot open file!", 0Dh, 0Ah, '$'
	s db "00000000: xx xx xx xx|xx xx xx xx|xx xx xx xx|xx xx xx xx  ................", 0Dh, 0Ah, '$'
	pattern db "00000000:            |           |           |                             ", 0Dh, 0Ah, '$'
	t db "0123456789ABCDEF"
	row db 1
	bytes_on_row db 14
	index dd 4142EFEFh
data ends
stack1 segment use16
	dd 1000 dup(0)
stack1 ends
code segment use16
assume cs:code, ss:stack1, ds:data
main:
	mov ax, data
	mov ds, ax
	
	;mov bx, 'AB'					;\
	;shl ebx, 16					; |��indexʹ��֮ǰ����δ�����������ebx
	;mov bx, 0fefeh					;/
	mov ebx, index
	;mov si, 10
	call near ptr show_this_row
	;mov si, 0h					 ; \  
	;mov cx, 75					 ;  /��δ������ڲ��Ժ���show_this_row�Ƿ���ȷ
	;call near ptr output_s				 ;/

	call near ptr displayaword

	;mov bl, 254					;\
	;mov bh, 254					 ;\
	;shl ebx, 16					  ;\
	;mov bl, 254					   ;\
	;mov bh, 254					    ;\
	;mov si, 0h					    ;/��δ������ڲ��Ժ���convert8bit_to_hex��convert32bit_to_hex�Ƿ���ȷ
	;call near ptr convert32bit_to_hex		   ;/
	;						  ;/	
	;mov cx, 75h					 ;/
	;call near ptr output_s				;/

ending:
	mov ah, 4ch
	int 21h
;-------------------------------------------------------------------------------------------
convert8bit_to_hex proc near				;�Ѵ���bl�е���ת��16���ƴ���s[bp]��
	push ax
	push cx
	push si
	push bx

	xor cx, cx
	xor ax, ax

	mov al, bl
	and al,0f0h
	shr al, 4					;al�д��4λ
	mov si, ax
	mov ch, t[si]					;ch�д�Ÿ�4λ

	xor ax, ax

	mov al, bl
	and al,0fh					;al�д��4λ
	mov si, ax
	mov cl, t[si]					;cl���ǵ�4λ

	pop bx
	pop si
	mov s[si], ch
	inc si
	mov s[si], cl

	dec si
	pop cx
	pop ax
	retn

convert8bit_to_hex endp
;-------------------------------------------------------------------------------------------
Tester proc near					;Tester����ԭ��������������dl�������Ĵ����е�ֵ�ģ���ΪҲ��������
	push ax						;����ַ�������Ҳ����������
	xor ax, ax
	mov ah, 02h
	int 21h
	pop ax
	retn
Tester endp
;-------------------------------------------------------------------------------------------
convert32bit_to_hex proc near				;��ebx�е�32λ����ת��ʮ������
	push cx
	push si
	push ebx

	xor cx, cx
	mov cx, 4
convert:
	rol ebx, 8h
	call near ptr convert8bit_to_hex
	inc si
	inc si
	loop convert

	pop ebx
	pop si
	pop cx
	retn
convert32bit_to_hex endp
;-------------------------------------------------------------------------------------------
output_s proc near					;�ú������ڷ��Դ�����ַ���s
	push si
	push cx
	push dx
	push ax

	xor cx, cx
	mov cx, 75
	mov si, 0
output:
	mov dl, s[si]
	call near ptr Tester
	inc si
	cmp si, 75
	jna output

	pop ax
	pop dx
	pop cx
	pop si
	retn
output_s endp
;-------------------------------------------------------------------------------------------
cleanscreen proc near
	push ax
	push bx
	push cx
	push dx

	mov ax,0B800h
	mov es,ax					;�Դ��ַ
	mov ah,7					;���¾���
	mov al,0					;����
	mov bh,0					;������հײ�������Ϊ��ɫ
	mov ch,0					;�������Ͻ�������
	mov cl,0					;�������Ͻ�������
	mov dh,15					;�������½�������
	mov dl,74					;�������½�������
	int 10h
	
	pop dx
	pop cx
	pop bx
	pop ax
	retn
cleanscreen endp
;-------------------------------------------------------------------------------------------
show_this_row proc near
	push ax
	push bx
	push cx
	push dx
	push si

	push si
	xor cx, cx
	xor si, si
	xor dx, dx
	mov cx, 75
strcpy_s_pattern:
	mov dl,pattern[si]
	mov s[si],dl
	inc si
	loop strcpy_s_pattern
	pop si
	
	push si
	mov si, 0h
	call near ptr convert32bit_to_hex
	pop si

	;mov si, 0h					 ; \  
	;mov cx, 75					 ;  /��δ������ڲ��Ժ���show_this_row�Ƿ���ȷ
	;call near ptr output_s				 ;/

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	retn
show_this_row endp
;-------------------------------------------------------------------------------------------
displayaword  proc near					;ebx�зŵ���ƫ�Ƶ�ַoffset��buf������;bytes_on_row��ÿ�ж����ֽ�
	push ax
	push di
	push cx
	push si
	push bp
	push dx
	push bx

	call near ptr cleanscreen			;������������c�����ļ�����������ͬ����������������

	xor bx, bx
	xor dx, dx
	xor cx, cx
	xor di, di
	mov cl, bytes_on_row				;��������������10h����bytes_on_row��֮��Ҫ��
	xor si, si
	xor bp, bp
	mov si, 10
	mov di, 59
move_buf_to_s:
	mov bl, buf[bp]
	mov s[di], bl
	;mov dl, bl					;\
	;call near ptr Tester				;/ �öκ������ڲ���blȷʵ������buf�е��ַ�
	call near ptr convert8bit_to_hex			
	inc bp
	inc di
	add si, 3h
	loop move_buf_to_s


	xor cx, cx					;�Ӵ�ʱ��ʼ���һ���ַ�
	mov cx, 75
	xor si, si
	call near ptr coordinate			;����coordinate���������
showaline:
	call near ptr color				;������Ҫһ���ж�ahΪ07h����0fh�ĺ���
	mov al, s[si]
	call near ptr print
	add di, 2
	inc si
	loop showaline

	mov ah,0
	int 16h

	pop bx
	pop dx
	pop bp
	pop si
	pop cx
	pop di
	pop ax
	retn    
displayaword endp
;-------------------------------------------------------------------------------------------
print proc near						;�˺�������displayaword����Ͷӳ����Ļ
	push cx
	push di
	
	cld
	stosw

	pop di
	pop cx
	retn
print endp
;-------------------------------------------------------------------------------------------
color proc near						;�ú��������ж�����ַ�����ɫ������
	cmp si, 59
	jb ifor
	mov ah, 07h
return:
	retn
ifor:
	cmp s[si], '|'
	je lit
	mov ah, 07h
	jmp return
lit:
	mov ah, 0fh
	jmp return
color endp
;-------------------------------------------------------------------------------------------
coordinate proc near					;����rowֵ������bi���꣬��Ƶ����
	push ax
	push bx
	
	xor ax, ax
	xor bx, bx
	mov al, row
	dec al
	mov bl, 160
	mul bl
	mov di, ax

	pop dx
	pop ax
	retn
coordinate endp
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
code ends
end main