data segment
	file1 db 'filedemo.asm',0;Դ�ļ���
	file2 db 'filecopy.asm',0;Ŀ���ļ���
	handle1 dw 0		;Դ�ļ����
	handle2 dw 0		;Ŀ���ļ����
	buf db 0		;���ݻ�����
data ends
code segment
assume cs:code,ds:data
main:
	mov ax, data
	mov ds, ax
	mov ah, 3dh					;���ļ����ܺ�
	mov al, 0					;al=0,ֻ����ʽ
	mov dx, offset file1				;ds:dx->Դ�ļ���
	int 21h						;��Դ�ļ�
	jc exit						;���д���תexit
	mov [handle2], ax				;����Ŀ���ļ����
	mov ah, 3ch					;�����ļ����ܺ�
	mov cx, 0					;cx=0 ��ͨ�����ļ�
	mov dx, offset file2				;ds:dx->Ŀ���ļ���
	int 21h						;����Ŀ���ļ�
	jc exit						;���д���תexit
	mov [handle2], ax				;����Ŀ���ļ����
again:
	mov ah, 3fh					;��ȡ�ļ����ܺ�
	mov bx, [handle1]				;bx=Դ�ļ����
	mov cx, 1					;cx=1ÿ�ζ�ȡһ���ֽ�
	mov dx, offset buf				;ds:dx->���ݻ�����
	int 21h						;��ȡ�ļ�
	jc done						;ÿ�ζ�ȡһ���ֽ�
	or ax, ax					;
	jz done						;��ax==0���ʾԴ�ļ������������ݿɶ���תdone

	mov ah, 40h					;д���ļ����ܺ�
	mov bx, [handle2]				;bx=Ŀ���ļ����
	mov cx, 1					;cx=1, ÿ��д��һ���ֽ�
	mov dx, offset buf				;ds:dx->���ݻ�����
	int 21h						;д���ļ�
	mov ah, 2					;��ʾ�ַ��Ź���
	mov dl, [buf]					;dl=�������е�����
	int 21h						;����Ļ����ʾ�������е�����
	jmp again					;ѭ��
done:
	mov ah,3eh					;�ر��ļ����ܺ�
	mov bx, [handle1]				;bx=Դ�ļ����
	int 21h						;�ر�Դ�ļ�
	mov ah, 3eh					;
	mov bx, [handle2]
	int 21h						;�ر�Ŀ���ļ�
exit:
	mov ah, 4ch
	int 21h						;��������
code ends
end main