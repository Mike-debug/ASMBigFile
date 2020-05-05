/*--------------------------------------------------------------------------------------------*/
/*头文件*/
#include<stdio.h>
#include<math.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include<time.h>
#include <graphics.h>
#include "bitmap.h"

/*--------------------------------------------------------------------------------------------*/
/*宏定义*/
#define	SCRMOD	0x103
#define	SWIDTH	800L
#define	SHEIGHT	600L

/*--------------------------------------------------------------------------------------------*/
/*函数声明*/
/*设置屏幕方式，m=0x103: 800x600，256色*/
void setscr(int m); 
/*设置屏幕调色板，u:rgbrgbrgb......(3*num: 0..63)，start:起始索引，num:设置颜色数*/
void setrgb(BYTE *u, int start, int num); 
/*画点：只对256色*/
void setpix(int x, int y, int color);
/*画线：只对256色*/
void setlin(BYTE *u, int x, int y, int n);
/*关闭图形界面，使DOS界面恢复文字界面尺寸*/
void CloseGraph(void);

/*--------------------------------------------------------------------------------------------*/
/*主函数定义*/
int main(void)
{
/*主程序参数定义*/
	int					i, j, k;   				/*循环控制变量*/
	int 				colors, pge, ofs;		/*调色板颜色数、页数、偏移*/
	long				adr;					/*地址*/
	float				x;
	BYTE				u[2000], v[256];		/*读取bmp图像的各像素点RGB颜色分量、调色板*/
	FILE				*fp;					/*bmp文件指针*/
	BITMAPFILEHEADER	bf;						/*bmp文件文件头*/
	BITMAPINFOHEADER	bi;						/*bmp文件图头*/
	RGBQUAD				rgb[256];				/*调色板*/

/*无关*/
/*	BYTE far *vgabase =(BYTE far *)MK_FP(0xA000,0);*/

/*打开bmp文件*/
	if((fp=fopen("k398a.bmp","rb"))==NULL){
		printf("Cannot open bmp image\n");
		exit(0);
	}

/*读取bmp图形文件头和图头*/
	fread(&bf, sizeof(bf), 1, fp);
	fread(&bi, sizeof(bi), 1, fp);

/*打印bmp图像文件基本信息*/
	printf("Hello, world --> %d\n", sizeof(bf));/*文件头大小*/
	printf("bfSize --> %lx\n", bf.bfSize);		/*整个文件的大小*/
	printf("biSize:  %ld\n", bi.biSize);		/*图头的大小*/
	printf("biWidth: %ld\n", bi.biWidth);		/*位图宽度*/
	printf("biHeight:%ld\n", bi.biHeight);		/*位图高度*/
	printf("biPlanes:%d\n",  bi.biPlanes);		/*颜色位面数，总为1*/
	printf("biBitCount:%d\n", bi.biBitCount);	/*每象数颜色位（1，2，4，8，24）*/ 
	getchar();/*显示间停顿*/


/*--------------------------------------------------------------------------------------------*/
/*计算调色板颜色数*/
	colors=1<<bi.biBitCount;

/*读取bmp的调色板*/
	fread(rgb, sizeof(RGBQUAD), colors, fp);/*读取调色板信息*/
	
/*打印bmp图形数段的像素点色素信息，按照显示要求将bmp图像像素点信息经转化后录入或直接录入显示存储中*/
	for(j=0,i=0; i<colors; i++){
		/*打印调色板的256种颜色的具体RGB值，每个图像的调色RGB值不一样*/
		printf("%3d: %3d,%3d,%3d\n", i, rgb[i].rgbRed, rgb[i].rgbGreen, rgb[i].rgbBlue);

		/*256色假彩色显示*/
		/*
		u[j++]=rgb[i].rgbRed>>2;
		u[j++]=rgb[i].rgbGreen>>2;
		u[j++]=rgb[i].rgbBlue>>2;
		*/
		
		/*灰度显示代码段*/
		k = rgb[i].rgbRed*0.3
		  + rgb[i].rgbGreen*0.59
		  + rgb[i].rgbBlue*0.11;
		v[i]=k;
		u[i*3+0]=u[i*3+1]=u[i*3+2]=k>>2;
		
	}
	getchar();/*显示间停顿*/
	
/*设置屏幕尺寸*/
	setscr(0x103);

/*？？？*/
/*	for(i=0; i<256*3; i++)u[i]=(i/3)>>2;*/

/*设置屏幕调色板*/
	setrgb(u, 0, colors);

/*逐行显示*/
	for(j=0; j<bi.biHeight; j++){
		/*读入一行数据*/
		fread(u, 1, bi.biWidth, fp);

		/*16色显示一行*/
		/*
		for(i=0; i<bi.biWidth; i++){
			setpix(100+i, bi.biHeight-j, ((i&1)==0)?(u[i]>>4):(u[i]&15));
		}
		*/

		/*256色显示一行*/
		setlin(u, 100, bi.biHeight-j, bi.biWidth);
	}

/*关闭文件*/
	if(fclose(fp)){
		printf("Cannot close bmp image\n");
		exit(0);
	}
/*关闭图形界面*/
	CloseGraph();
	return 0;
}


/*--------------------------------------------------------------------------------------------*/
/*函数定义*/
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
/*关闭图形界面，使DOS界面恢复文字界面尺寸*/
void CloseGraph(void){
	getch();	//closegraph();
	asm{
		mov		ax,3
		int		10h
	}
} 
