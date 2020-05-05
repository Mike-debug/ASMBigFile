#include <stdio.h>
#include <graphics.h>
#include "bitmap.h"

#define	SCRMOD	0x103
#define	SWIDTH	800L
#define	SHEIGHT	600L

/**************************
 *  设置屏幕方式
 * m=0x103: 800x600,256色
 **************************/
void setscr(int m)
{
	asm{
		mov		ax,4f02h
		mov		bx,m
		int		10h
	}
}
/**************************
 *  设置屏幕调色板
 * u:rgbrgbrgb......(3*num: 0..63)
 * start:起始索引
 * num:设置颜色数
 **************************/
void setrgb(BYTE *u, int start, int num)
{
	asm{
		mov		ax,1012h
		mov		bx,start
		mov		cx,num
		mov		dx,[bp+4]
		push	ss
		pop		es
		int		10h
	}
}
/**************************
 *  画点：只对256色
 **************************/
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
/**************************
 *  画线：只对256色
 **************************/
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
		mov		si,[bp+4]
		mov		cx,n
		rep		movsb
		pop		ds
	}
}

int main(int argc, char *argv[])
{
	int	i, j, k, colors, pge, ofs;
	long	adr;
	float	x;
	BYTE	u[2000];
	FILE				*fp;
	BITMAPFILEHEADER	bf;
	BITMAPINFOHEADER	bi;
	RGBQUAD				rgb[256];
//	BYTE far *vgabase =(BYTE far *)MK_FP(0xA000,0);

	if((fp=fopen("k398a.bmp","rb"))==NULL)exit();

	printf("Hello, world --> %d\n", sizeof(bf));
	fread(&bf, sizeof(bf), 1, fp);
	printf("bfSize --> %lx\n", bf.bfSize);
	fread(&bi, sizeof(bi), 1, fp);
	printf("biSize:  %ld\n", bi.biSize);
	printf("biWidth: %ld\n", bi.biWidth);	//位图宽度
	printf("biHeight:%ld\n", bi.biHeight);	//位图高度
	printf("biPlanes:%d\n",  bi.biPlanes);	//颜色位面数，总为1
	printf("biBitCount:%d\n", bi.biBitCount);	//每象数颜色位（1，2，4，8，24）
	colors=1<<bi.biBitCount;

	fread(rgb, sizeof(RGBQUAD), colors, fp);
	j=0;
	for(i=0; i<colors; i++){
		printf("%3d: %3d,%3d,%3d\n", i,
			rgb[i].rgbRed,
			rgb[i].rgbGreen,
			rgb[i].rgbBlue);
		u[j++]=rgb[i].rgbRed>>2;
		u[j++]=rgb[i].rgbGreen>>2;
		u[j++]=rgb[i].rgbBlue>>2;
	}

	getch();
	setscr(0x103);	//设置800x600图形方式
	printf("biSize:  %ld\n", bi.biSize);

	//for(i=0; i<colors; i++)
	setrgb(u, 0, 256);
	for(j=0; j<bi.biHeight; j++){
		fread(u, 1, bi.biWidth, fp);
		setlin(u, 0, bi.biHeight-j, bi.biWidth);
//		for(i=0; i<bi.biWidth; i++){
//			setpix(i, bi.biHeight-j, u[i]);
//		}
	}

	getch();	//closegraph();

	/*返回文本方式*/
	asm{
		mov		ax,3
		int		10h
	}
	return 0;
}
