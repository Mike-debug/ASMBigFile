#include<math.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include<time.h>
#include <stdio.h>
#include <graphics.h>
void PrintPixel(unsigned int x, unsigned int y, unsigned int size, unsigned int color);
void DrawCharacter(char *u, int abscissa, int ordinate, unsigned int size, unsigned int color, unsigned int italics);
void ClearScreen(void);
int main(void)
{
	/*参数定义*/
	char				s[10]="浙江大学", u[32];
	unsigned int		q, w;
	long int 			ofs;
	FILE				*fp;
	unsigned int 		cursor1; 
	unsigned int  		size=05;
	int *abscissa, *ordinate;
	unsigned int 		color; 
	unsigned int 		italics;
	
	/*初始化*/
	abscissa=(int*)malloc(sizeof(int));
	ordinate=(int*)malloc(sizeof(int));
	*abscissa=0;
	*ordinate=0;
	initgraph(abscissa, ordinate, "");
	if((fp=fopen("hzk16", "rb"))==NULL){
		printf("Cannot open the font file\n");
		exit(0);
	}
	
	/*设置显示位置和显示尺寸*/
	printf("Input the coodinate:");
	scanf("%d%d",abscissa,ordinate);
	printf("\nInput the size of a pixel:");
	scanf("%u",&size);
	printf("\nInput the color:\n");
	printf("0--BLACK\n");
	printf("1--BLUE\n");
	printf("2--GREEN\n");
	printf("3--CYAN\n");
	printf("4--RED\n");
	printf("5--MAGENTA\n");
	printf("6--BROWN\n");
	printf("7--LIGHTGRAY\n");
	printf("8--DARKGRAY\n");
	printf("9--LIGHTBLUE\n");
	printf("10--LIGHTGREEN\n");
	printf("11--LIGHTCYAN\n");
	printf("12--LIGHTRED\n");
	printf("13--LIGHTMAGENTA\n");
	printf("14--YELLOW\n");
	printf("15--WHITE\n");
	scanf("%d",&color);
	printf("\nItalics or not\n");
	printf("1--Yes\n");
	printf("0--Not\n");
	scanf("%d",&italics);
	ClearScreen();
	
	/*显示*/
	for(cursor1=0;cursor1<8;cursor1+=2){
		q=(s[cursor1]-0xA1)&0xFF;
		w=(s[cursor1+1]-0xA1)&0xFF;
		ofs=(q*94+w)*32L;

		fseek(fp, ofs, SEEK_SET);
		fread(u, 1, 32, fp);
		
		DrawCharacter(u, *abscissa, *ordinate, size, color, italics);
		*abscissa+=size*16;
	}
	
	/*结束清屏*/
	getch();
	system("cls");
	if(fclose(fp)){
		printf("Cannot close the file!\n");
		exit(0);
	}
	
	return 0;
}
void DrawCharacter(char *u, int abscissa, int ordinate, unsigned int size, unsigned int color, unsigned int italics){
	unsigned int i, j, m;
	for(j=0; j<16; ++j){
		m=0x80;
		for(i=0; i<8; ++i){
			if(u[j*2]&m)PrintPixel(abscissa+i*size,ordinate+j*size,size,color);
			m>>=1;
		}
		m=0x80;
		for(i=0; i<8; ++i){
			if(u[j*2+1]&m)PrintPixel(abscissa+i*size+8*size,ordinate+j*size,size,color);
			m>>=1;
		}
		if(italics==1 && j%2==1)
			abscissa+=size;
	}		
	return;
}
void PrintPixel(unsigned int x, unsigned int y, unsigned int size, unsigned int color){
	unsigned int curx, cury;
	for(cury=y;cury<y+size;++cury)
		for(curx=x;curx<x+size;++curx)
			putpixel(curx,cury,color);
	return;
}
void ClearScreen(void){
	int i, j;
	for(i=0;i<40;++i)
		printf("\n");
	return;
}
