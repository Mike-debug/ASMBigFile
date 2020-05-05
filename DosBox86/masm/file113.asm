;************************************�����ҵ������******************************************
;*������κһ��
;*ѧ�ţ�3150100565
;*רҵ���������ѧ�뼼��
;********************************************************************************************
.386
data segment use16
	filename db 100,?,100 dup(0)
	buf db 	256 dup(?)
	handle dw 0
	filesize dd ?
	hint1 db "Please input filename:", 0Dh, 0Ah, '$'
	hint2 db "Cannot open file!", 0Dh, 0Ah, '$'
	s db "00000000: xx xx xx xx|xx xx xx xx|xx xx xx xx|xx xx xx xx  ................", 0Dh, 0Ah, '$'
	pattern db "00000000:            |           |           |                             ", 0Dh, 0Ah, '$'
	t db "0123456789ABCDEF"
	row db 2					;�ڼ���
	bytes_on_row db 0h				;ÿ�ж������ֽ�
	index dd 0h				;��ʼ�е�ƫ�Ƶ�ַ
	bytes_in_buf dw 100h				;buf���ж����ֽ�
	file_size dd 0h
data ends
stack1 segment use16
	dd 1000 dup(0)
stack1 ends
code segment use16
assume cs:code, ss:stack1, ds:data
main:
	mov ax, data
	mov ds, ax
	
	mov dx, offset hint1
	call near ptr outputchararray			;��ʾ�����ļ���

	mov ah, 0ah					;�����ļ���
	mov dx, offset filename
	int 21h
	call near ptr newline
	call near ptr endfile

	mov ah, 3dh					;���ļ�
	mov al, 0
	mov dx, offset filename[2]
	int 21h

	jc error					;�жϴ򿪳ɹ����
	mov handle, ax					;������

	mov ah, 42h					;���ļ���С
	mov al, 2; ��Ӧlseek()�ĵ�3������,
		; ��ʾ��EOFΪ���յ�����ƶ�
	mov bx, handle
	mov cx, 0; \ ��Ӧlseek()�ĵ�2������
	mov dx, 0; /
	int 21h
	mov byte ptr file_size[2], dl
	mov byte ptr file_size[3], dh
	mov byte ptr file_size[0], al
	mov byte ptr file_size[1], ah

display_by_control:
	call near ptr bytes_in_buf_calculating
	mov ah, 42h
	mov al, 0; ��Ӧlseek()�ĵ�3������,
		; ��ʾ��ƫ��0��Ϊ���յ�����ƶ�
	mov bx, handle
	mov cx, word ptr index[2]; \cx:dx��һ�𹹳�
	mov dx, word ptr index[0]; /32λֵ=offset
	int 21h

	mov ah, 3fh					;��ʼ�����ļ������1024B
	mov dx, offset buf
	mov cx, bytes_in_buf
	mov bx, handle
	int 21h

	;�������ڴ������ʾ
	call near ptr show_this_page
	mov ah,0
	int 16h
	
	cmp ah, 1
	je ending

	call near ptr alternation
	jmp display_by_control

	mov bx, handle					;�ر��ļ�
	mov ah, 3eh
	int 21h
	jc error

ending:
	mov ah, 4ch
	int 21h
error:
	mov dx, offset hint2
	call near ptr outputchararray
	mov ah, 4ch
	int 21h
;-------------------------------------------------------------------------------------------
outputchararray proc near
	push ax
	mov ah, 09h
	int 21h
	pop ax
	retn
outputchararray endp
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
coordinate_calculating proc near			;ƫ�Ƶ�ַ����
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

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	retn
coordinate_calculating endp
;-------------------------------------------------------------------------------------------
sub_show_this_row  proc near					;ebx�зŵ���ƫ�Ƶ�ַoffset��buf������;bytes_on_row��ÿ�ж����ֽ�
	push ax
	push di
	push cx
	push dx
	push bx
	push si
	push bp
	
	cmp cl, 0
	je zero_manage1
	
	xor bx, bx
	xor dx, dx
	xor cx, cx
	xor di, di
	mov cl, bytes_on_row				;��������������10h����bytes_on_row��֮��Ҫ��
	xor si, si
	mov si, 10
	mov di, 59
move_buf_to_s:
	mov bl, buf[bp]
	mov s[di], bl

	call near ptr convert8bit_to_hex			
	inc bp
	inc di
	add si, 3h
	loop move_buf_to_s

zero_manage1:
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

	pop bp
	pop si
	pop bx
	pop dx
	pop cx
	pop di
	pop ax
	retn    
sub_show_this_row endp
;-------------------------------------------------------------------------------------------
print proc near						;�˺�������sub_show_this_row����Ͷӳ����Ļ
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
show_this_page proc near
;	mov ebx, index
	call near ptr cleanscreen			;������������c�����ļ�����������ͬ����������������
	call near ptr row_calculating			;���㵱ǰҳ��Ҫ��ʾ������
	call near ptr printrows				;��ʾһ��
	retn
show_this_page endp
;-------------------------------------------------------------------------------------------
endfile proc near					;�ú����������ļ������0�������ļ���
	push si
	push dx
	
	mov si, 2
compare:
	inc si
	cmp filename[si], 1fh				;����ascll��������ļ����ַ�ascll�붼���ڵ���20h�������ո�
	jae compare

	mov filename[si], 0

	pop dx
	pop si
	retn
endfile endp
;-------------------------------------------------------------------------------------------
row_calculating proc near				;;���㵱ǰҳ��Ҫ��ʾ������
	push bx
	push ax

	xor ax, ax
	xor bx, bx
	mov ax, bytes_in_buf
	add ax, 0fh
	mov bl, 10h
	div bl
	mov row, al

	pop ax
	pop bx
	retn
row_calculating endp
;-------------------------------------------------------------------------------------------
printrows proc near
	push cx

	xor cx, cx
	mov cl, row
	cmp cl, 0					;����СΪ0���ļ�
	je single
	xor bp, bp
displayrow:
	call near ptr bytes_on_row_calculating
	call near ptr show_this_row
	add bp, 10h	
	loop displayrow
	jmp return5	

single:
	call near ptr bytes_on_row_calculating
	call near ptr show_this_row

return5:
	pop cx
	retn
printrows endp
;-------------------------------------------------------------------------------------------
bytes_on_row_calculating proc near			;�������㵱ǰ���ж����ֽ�
	cmp cx, 1
	jne ordinal

	push ax
	push bx
	xor ax, ax
	xor bx, bx
	mov ax, bytes_in_buf
	mov bl, 10h
	div bl
	cmp ah, 0
	je adjust
	jmp assign
adjust:
	mov ah, 10h
assign:
	mov bytes_on_row, ah

	pop bx
	pop ax
	jmp return1

ordinal:
	mov bytes_on_row, 10h
return1:
	retn
bytes_on_row_calculating endp
;-------------------------------------------------------------------------------------------
show_this_row proc near
	push ax
	xor ax, ax
	mov al, row
	push ax
	push ebx

	sub row, cl
	inc row
zero_manage:
	xor ebx, ebx
	mov bl, row
	shl bx, 4
	add ebx, index
	sub ebx, 10h
	call near ptr coordinate_calculating		;ƫ�Ƶ�ַ����
	call near ptr sub_show_this_row			;��ʾ��buf[bp]��ʼ��bytes_on_row���ֽ�
	jmp ending6

ending6:
	pop ebx
	pop ax
	mov row, al
	pop ax
	retn
show_this_row endp
;-------------------------------------------------------------------------------------------
bytes_in_buf_calculating proc near			;�������ж����ֽڵļ���
	push ebx
	push eax

	mov eax, file_size
	mov ebx, index
	sub eax, ebx
	cmp eax, 100h
	jae full
	jmp rest
full:
	mov bytes_in_buf, 100h
	jmp ending2
rest:
	mov bytes_in_buf, ax
ending2:
	pop eax
	pop ebx
	retn
bytes_in_buf_calculating endp
;-------------------------------------------------------------------------------------------
alternation proc near					;���ڼ�������������Ӧ��ѡ��
	push ebx
	push eax
	push edx
	push ecx

	cmp ah, 49h
	je pageup
	cmp ah, 51h
	je pagedn
	cmp ah, 47h
	je home
	cmp ah, 4fh
	je ending4
	jmp return3

pageup:
	cmp index, 100h
	jb pageup_initialize
	sub index, 100h
	jmp return3
pageup_initialize:
	mov index, 0
	jmp return3

pagedn:
	xor ebx, ebx
	mov ebx, index
	add ebx, 100h
	cmp ebx, file_size
	jae return3
	mov index, ebx
	jmp return3

home:
	mov index, 0
	jmp return3

ending4:
	xor edx, edx
	xor eax, eax
	cmp file_size, 0
	je return3
	mov eax, file_size
	mov ebx, file_size
	rol eax, 16
	mov dx, ax
	rol eax, 16
	mov cx, 100h
	div cx
	cmp dx, 0
	je exactly
	sub ebx, edx
	mov index, ebx
	jmp return3
exactly:
	sub ebx, 100h
	mov index, ebx
	jmp return3

return3:
	pop ecx
	pop edx
	pop eax
	pop ebx
	retn
alternation endp
;-------------------------------------------------------------------------------------------
newline proc near					;�س����к���
	push ax
	mov ah, 2					;����س��ͻ���
	mov dl, 0Dh
	int 21h
	mov ah, 2
	mov dl, 0Ah
	int 21h;������з�
	pop ax
	retn
newline endp
;-------------------------------------------------------------------------------------------
code ends
end main