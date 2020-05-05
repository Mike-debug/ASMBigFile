/*--------------------------------------------------------------------------------------------*/
/*ͷ�ļ�*/
#include<stdio.h>
#include<math.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include<time.h>
#include <graphics.h>
#include "bitmap.h"

/*--------------------------------------------------------------------------------------------*/
/*�궨��*/
#define	SCRMOD	0x103
#define	SWIDTH	800L
#define	SHEIGHT	600L

/*--------------------------------------------------------------------------------------------*/
/*��������*/
/*������Ļ��ʽ��m=0x103: 800x600��256ɫ*/
void setscr(int m); 
/*������Ļ��ɫ�壬u:rgbrgbrgb......(3*num: 0..63)��start:��ʼ������num:������ɫ��*/
void setrgb(BYTE *u, int start, int num); 
/*���㣺ֻ��256ɫ*/
void setpix(int x, int y, int color);
/*���ߣ�ֻ��256ɫ*/
void setlin(BYTE *u, int x, int y, int n);
/*�ر�ͼ�ν��棬ʹDOS����ָ����ֽ���ߴ�*/
void CloseGraph(void);

/*--------------------------------------------------------------------------------------------*/
/*����������*/
int main(void)
{
/*�������������*/
	int					i, j, k;   				/*ѭ�����Ʊ���*/
	int 				colors, pge, ofs;		/*��ɫ����ɫ����ҳ����ƫ��*/
	long				adr;					/*��ַ*/
	float				x;
	BYTE				u[2000], v[256];		/*��ȡbmpͼ��ĸ����ص�RGB��ɫ��������ɫ��*/
	FILE				*fp;					/*bmp�ļ�ָ��*/
	BITMAPFILEHEADER	bf;						/*bmp�ļ��ļ�ͷ*/
	BITMAPINFOHEADER	bi;						/*bmp�ļ�ͼͷ*/
	RGBQUAD				rgb[256];				/*��ɫ��*/

/*�޹�*/
/*	BYTE far *vgabase =(BYTE far *)MK_FP(0xA000,0);*/

/*��bmp�ļ�*/
	if((fp=fopen("k398a.bmp","rb"))==NULL){
		printf("Cannot open bmp image\n");
		exit(0);
	}

/*��ȡbmpͼ���ļ�ͷ��ͼͷ*/
	fread(&bf, sizeof(bf), 1, fp);
	fread(&bi, sizeof(bi), 1, fp);

/*��ӡbmpͼ���ļ�������Ϣ*/
	printf("Hello, world --> %d\n", sizeof(bf));/*�ļ�ͷ��С*/
	printf("bfSize --> %lx\n", bf.bfSize);		/*�����ļ��Ĵ�С*/
	printf("biSize:  %ld\n", bi.biSize);		/*ͼͷ�Ĵ�С*/
	printf("biWidth: %ld\n", bi.biWidth);		/*λͼ���*/
	printf("biHeight:%ld\n", bi.biHeight);		/*λͼ�߶�*/
	printf("biPlanes:%d\n",  bi.biPlanes);		/*��ɫλ��������Ϊ1*/
	printf("biBitCount:%d\n", bi.biBitCount);	/*ÿ������ɫλ��1��2��4��8��24��*/ 
	getchar();/*��ʾ��ͣ��*/


/*--------------------------------------------------------------------------------------------*/
/*�����ɫ����ɫ��*/
	colors=1<<bi.biBitCount;

/*��ȡbmp�ĵ�ɫ��*/
	fread(rgb, sizeof(RGBQUAD), colors, fp);/*��ȡ��ɫ����Ϣ*/
	
/*��ӡbmpͼ�����ε����ص�ɫ����Ϣ��������ʾҪ��bmpͼ�����ص���Ϣ��ת����¼���ֱ��¼����ʾ�洢��*/
	for(j=0,i=0; i<colors; i++){
		/*��ӡ��ɫ���256����ɫ�ľ���RGBֵ��ÿ��ͼ��ĵ�ɫRGBֵ��һ��*/
		printf("%3d: %3d,%3d,%3d\n", i, rgb[i].rgbRed, rgb[i].rgbGreen, rgb[i].rgbBlue);

		/*256ɫ�ٲ�ɫ��ʾ*/
		/*
		u[j++]=rgb[i].rgbRed>>2;
		u[j++]=rgb[i].rgbGreen>>2;
		u[j++]=rgb[i].rgbBlue>>2;
		*/
		
		/*�Ҷ���ʾ�����*/
		k = rgb[i].rgbRed*0.3
		  + rgb[i].rgbGreen*0.59
		  + rgb[i].rgbBlue*0.11;
		v[i]=k;
		u[i*3+0]=u[i*3+1]=u[i*3+2]=k>>2;
		
	}
	getchar();/*��ʾ��ͣ��*/
	
/*������Ļ�ߴ�*/
	setscr(0x103);

/*������*/
/*	for(i=0; i<256*3; i++)u[i]=(i/3)>>2;*/

/*������Ļ��ɫ��*/
	setrgb(u, 0, colors);

/*������ʾ*/
	for(j=0; j<bi.biHeight; j++){
		/*����һ������*/
		fread(u, 1, bi.biWidth, fp);

		/*16ɫ��ʾһ��*/
		/*
		for(i=0; i<bi.biWidth; i++){
			setpix(100+i, bi.biHeight-j, ((i&1)==0)?(u[i]>>4):(u[i]&15));
		}
		*/

		/*256ɫ��ʾһ��*/
		setlin(u, 100, bi.biHeight-j, bi.biWidth);
	}

/*�ر��ļ�*/
	if(fclose(fp)){
		printf("Cannot close bmp image\n");
		exit(0);
	}
/*�ر�ͼ�ν���*/
	CloseGraph();
	return 0;
}


/*--------------------------------------------------------------------------------------------*/
/*��������*/
void setscr(int m)
{
	asm{
		mov		ax,4f02h
		mov		bx,m
		int		10h
	}
}
void setrgb(BYTE *u, int start, int num)
{
	asm{
		mov		ax,1012h
		mov		bx,start
		mov		cx,num
		mov		dx,[bp+6]
		push	ss
		pop		es
		int		10h
	}
}
void setpix(int x, int y, int color)
{
	asm{
		mov		ax,800
		mul		y
		add		ax,x
		adc		dx,0
		mov		di,ax
		mov		ax,4f05h
		xor		bx,bx
		int		10h
		mov		ax,0A000h
		mov		es,ax
		mov		ax,color
		stosb
	}
}
void setlin(BYTE *u, int x, int y, int n)
{
	asm{
		mov		ax,800
		mul		y
		add		ax,x
		adc		dx,0
		mov		di,ax
		mov		ax,4f05h
		xor		bx,bx
		int		10h
		mov		ax,0A000h
		mov		es,ax
		push		ds
		push		ss
		pop		ds
		mov		si,[bp+6]
		mov		cx,n
		rep		movsb
		pop		ds
	}
}
/*�ر�ͼ�ν��棬ʹDOS����ָ����ֽ���ߴ�*/
void CloseGraph(void){
	getch();	//closegraph();
	asm{
		mov		ax,3
		int		10h
	}
} 
