#include<math.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include<time.h>
#include <stdio.h>
#include <graphics.h>
void Hint(void);
unsigned long int GetFileSize(FILE* fp);
void PrintPixel(unsigned int x, unsigned int y, unsigned int size, unsigned int color);
void DrawCharacter(char *u, int abscissa, int ordinate, unsigned int size, unsigned int color, unsigned int italics);
void ClearScreen(void);
int main(void)
{
	/*参数定义*/
	char				*s;/*正文内容指针*/
	/*s[108]="浙，江大学浙江大学浙江大学浙江大学浙江大学浙江大学浙江大学浙江大学浙江大学浙江大学浙江大学浙江大学浙江大",*/
	char				u[32];
	unsigned int		q, w;
	long int 			ofs;
	FILE				*fp, *text;/*字体文件和文本文件*/
	unsigned int 		cursor1; 
	unsigned int  		size=01;
	int				 	*abscissa, *ordinate;
	unsigned int 		color; 
	unsigned int 		italics=0;
	unsigned long int	FileSize;
	
/*计算文件大小并读取*/
	if((text=fopen("text.dat","rb"))==NULL){
		printf("Cannot open file\n");
		exit(0);
	}
	FileSize=GetFileSize(text);
	printf("FileSize=%d\n",FileSize);
	getchar();
	s=(char*)malloc(FileSize*sizeof(char));
	/*fscanf(text,"%s",s);*/
	fseek(text,0,SEEK_SET);
	fread(s,1,FileSize,text);
	if(fclose(text)){
		printf("Cannot close file\n");
		exit(0);
	}
	
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
	Hint();
	scanf("%d",&color);
	ClearScreen();
	
	*abscissa=0; 
	/*显示*/
	for(cursor1=0;cursor1<FileSize;cursor1+=2){
		
		q=(s[cursor1]-0xA1)&0xFF;
		w=(s[cursor1+1]-0xA1)&0xFF;
		ofs=(q*94+w)*32L;

		fseek(fp, ofs, SEEK_SET);
		fread(u, 1, 32, fp);
		
		if(s[cursor1]==0x0D&&s[cursor1+1]==0x0A){
			*abscissa=0;
			*ordinate+=18;
		}
		else{
			DrawCharacter(u, *abscissa, *ordinate, size, color, italics);
			*abscissa+=size*16;
			if(*abscissa>=640)*ordinate+=18;
			*abscissa%=640;	
		}	
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
unsigned long int GetFileSize(FILE* fp){
	unsigned long int head, tail;
	head=ftell(fp);
	fseek(fp,0,SEEK_END);
	tail=ftell(fp);
	rewind(fp);
	return tail-head;
}
void Hint(void){
	printf("Input the color:\n");
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
		
	return;
} 
