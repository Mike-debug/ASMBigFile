;�ڶ��λ����ҵ
;κһ��
;3150100565
;�ƿ�1704
;1781937775@qq.com
.386
data segment use16					;����ʹ��32λ�Ĵ���
	num1 db 6; �������������ַ��������س���Ϊ6	;��һ���������
	       db ?;  ʵ��������ַ���
	       db 6 dup(?) ;����������ַ�
	num2 db 6; �������������ַ��������س���Ϊ6	;�ڶ����������
	       db ?;  ʵ��������ַ���
	       db 6 dup(?) ;����������ַ�
	decinum db 10 dup(0),0dh,0ah,'$'			;���ڴ��ʮ����������
data ends
stack1 segment stack use16
	dw 1000h dup(?)					;��ջ��
stack1 ends


code segment use16
	assume cs:code,ds:data,ss:stack1;
start:
	mov ax, data
	mov ds, ax					;�ε�ַ��ֵ

	mov ah, 0Ah					;�����һ����������λ�ַ�����
	mov dx, offset num1
	int 21h
	call near ptr newline				;���ûس����к���
	
	mov ah, 0Ah					;����ڶ�����������λ�ַ�����
	mov dx, offset num2
	int 21h
	call near ptr newline				;���ûس����к���

output1:	
	xor cx, cx;cx=0
	mov cl, num1[1];cl=ʵ��������
	jcxz output2;��������ַ���Ϊ0������ת��output2
	mov si, offset num1+2;ds:si->�������ַ��������ַ�
	call near ptr output				;����ѭ���������

	mov dl, '*'					;�˺�*���
	call near ptr Tester				;Tester����Ϊ�����ǰdl��ӦASCLL���ַ�
output2:
	xor cx, cx;cx=0
	mov cl, num2[1];cl=ʵ��������
	jcxz done;��������ַ���Ϊ0������ת��done
	mov si, offset num2+2;ds:si->�������ַ��������ַ�
	call near ptr output				;����ѭ���������

	mov dl, '='
	call near ptr Tester
	call near ptr newline				;���ûس����к���
	
	xor bx, bx
	xor cx, cx
	xor dx, dx
	mov di, 2h
	mov cl, num1[1]
load1:							;����һ�������뵽bx��
	push cx
	mov cl, num1[di]
	sub cl, 30h
	call near ptr multi10				;ÿ����һ���ַ���bx��10���ټ�����ַ���ʾ������
	add bx, cx
	inc di
	pop cx
	loop load1

	mov ax, bx
	xor bx, bx
	xor cx, cx
	xor dx, dx
	mov di, 2h
	mov cl, num2[1]
load2:							;���ڶ��������뵽bx��
	push cx
	mov cl, num2[di]
	sub cl, 30h
	call near ptr multi10				;ÿ����һ���ַ���bx��10���ټ�����ַ���ʾ������
	add bx, cx
	inc di
	pop cx
	loop load2
	
	mul bx						;dx:ax���Ѿ�����������
	
	call near ptr decimal				;ʮ������ʾ
	call near ptr hex				;ʮ��������ʾ
	call near ptr binary				;��������ʾ


done:
	mov ah, 4Ch					;��������
	int 21h
;==========================================================================================================
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
;==========================================================================================================
output proc near					;�����ǰdx:dl��ʼ���ַ���
again:
	mov ah, 2
	mov dl, [si];��������ַ��������ȡ���ַ���
	int 21h;��ʾȡ�����ַ�
	inc si;׼��ȡ����һ���ַ�
	loop again
	retn
output endp
;==========================================================================================================
multi10 proc near					;bx��10��������bx�д�ŵ�ֵ��10
	push dx
	push cx
	xor dx, dx
	xor cx, cx
	mov dx, bx					;dx=bx
	mov cl, 3					
	shl bx, cl					;bx����3λ���൱�ڳ�8
	shl dx, 1					;dx����1λ���൱�ڳ�2
	add bx, dx					;bx=bx+dx,,��ʱbxΪ������ʼʱʮ��
	pop cx
	pop dx
	retn
multi10 endp
;==========================================================================================================
hex proc near						;ʮ���������������ͨ��ѭ����λʵ��
	push cx
	push dx

	mov bx, dx					
	call near ptr rotate_hex			;���������������16λ��ʮ��������
	mov bx, ax
	call near ptr rotate_hex			;���������������16λ��ʮ��������
	mov dl, 'h'					;���ʮ�����Ʊ�־��h��
	call near ptr Tester				;Tester����ԭ��������������dl�������Ĵ����е�ֵ�ģ�������������ַ�
	call near ptr newline				;���ûس����к���
	pop dx
	pop cx

	retn
hex endp
;==========================================================================================================
convert proc near					;������9��ʮ�������ַ�ת������ĸ
	cmp dl, 39h
	ja is_above
	jmp convert_done
is_above:
	add dl, 7h					;���ڴ���9��ʮ������������Ҫת������ĸ������ASCLL�룬����7
convert_done:
	retn
convert endp
;==========================================================================================================
rotate_hex proc near					;��ʮ��������ʾbx�е��ַ�
	push ax
	push cx
	push dx
	xor ax, ax
	xor cx, cx
	mov cl, 4					;���������ȴ洢��dx:ax�У�ʮ������λռ4��������λ����Ҫѭ���ƶ�4��ʵ��
rotate:
	push cx
	xor cx, cx
	mov cx, 4					;ÿ���ƶ��ĸ�bit
	rol bx, cl
	mov dx, bx
	and dx, 0fh
	add dl, 30h					;����ASCLL�뵽��ʾ����
	call near ptr convert				;������9������ת������ĸ
	mov ah, 02h
	int 21h
	pop cx
	loop rotate
	
	pop dx
	pop cx
	pop ax
	retn
rotate_hex endp
;==========================================================================================================
Tester proc near					;Tester����ԭ��������������dl�������Ĵ����е�ֵ�ģ���ΪҲ��������
	push ax						;����ַ�������Ҳ����������
	xor ax, ax
	mov ah, 02h
	int 21h
	pop ax
	retn
Tester endp
;==========================================================================================================
binary proc near					;�������������
	push cx
	push dx
	
	mov bx, dx					;�������dx�е�����
	call near ptr four_bit				;��Ϊ���ǵ��ո�������⣬���԰Ѹ���λ�����
	call near ptr fit_12				;�������ʣ��12λ
	
	mov dl, ' '
	call near ptr Tester

	mov bx, ax					;��ͬ���ķ������ax�е���ֵ
	call near ptr four_bit				
	call near ptr fit_12

	mov dl, 'B'					;"B"Ϊ�����Ʊ�־
	call near ptr Tester
	call near ptr newline				;���ûس����к���
	pop dx
	pop cx
	retn
binary endp
;==========================================================================================================
fit_12 proc near					;���ʮ��λ���������ֺ���
	push dx
	push cx
	xor cx, cx
	mov cl, 03h

Three_group:
	mov dl, ' '
	call near ptr Tester
	call near ptr four_bit				;�����������������λ�����ƺ���
	
	loop Three_group
	
	pop cx
	pop dx
	retn
fit_12 endp
;==========================================================================================================
four_bit proc near					;�����λ�����ƺ���
	push dx
	push cx
	xor cx, cx
	mov cl, 04h					;ͨ��������λ4��ʵ��
iteration:
	rol bx, 1
	jnc out_0					;ͨ���жϷ���λCF���������0����1
out_1:
	mov dl, '1'
	call near ptr Tester
	jmp endout
out_0:
	mov dl, '0'
	call near ptr Tester
endout:
	loop iteration
	pop cx
	pop dx
	retn
four_bit endp
;==========================================================================================================
decimal proc near					;ʮ�����������
	push ax
	push dx
	push cx
	push si

	xor cx, cx
	mov cx, 10h	
	push ax
	mov ax, dx
	shl eax, cl
	pop ax						;�������������eax�У�eax��������

	mov ebx, 0ah					;ebx������
	mov si, 9					;si��������decinum��ƫ�Ƶ�ַ
	mov ecx, 10					;���������ý�����Ϊʮλʮ������������ֻ��Ҫѭ��10�μ���
circulation:
	xor edx, edx
	div ebx						;eaxÿ�γ���ebx������������edx�У�eax��Ϊ��
	mov byte ptr [decinum+si], dl			;��dl�е��������浽������
	add byte ptr [decinum+si], 30h			;�������б��浽ʮ������ֵת������Ӧ��ASCLL�ַ�
	dec si						;si�Լ���׼�������һ����������һλ
	loop circulation

	inc si						;ȡ�����������si�����һ�Σ����Լ���
locate:							;��λ��ţ���λ������decinum��ʮ�������ĵ�һ����Ϊ��ĵ�ַ
	mov dl, decinum[si]				;��һ��ѭ����ʵ�ǰѱ����׵�ַ��ֵ��dl����Ϊ֮��ѭ�����õ�si����������ֱ������si����0
	inc si						;si�Լӣ�ȡ����λ
	cmp dl, '0'					;ÿ�ΰ�dl�͡�0�����Ƚϣ�����õ�dl���㣬�����ѭ��
	je locate

	dec si
	mov cx, 10
	sub cx, si
	mov bp, offset decinum				;�ѱ������ַ���ƫ�Ƶ�ַ��ֵ��bp
	add si, bp					;si����bpΪ�׸������ַ��Ŀ�ʼ
	call near ptr output				;��������ַ�������
;display:						
;	mov dl, decinum[si]				;������һ�������ʽ������ַ����
;	call near ptr Tester
;	inc si
;	loop display

decimalend:						;����ʮ������������ı��
	call near ptr newline				;�س�����
	pop si
	pop cx
	pop dx
	pop ax
	retn
decimal endp
;==========================================================================================================
code ends			
	end start					;�������
