#include<stdio.h>
#include<math.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include<time.h>
#include<graphics.h>

#define LineSpace 18
#define Adjaceney 16
#define LettersPerLine 40
/*
#define BLACK 0
#define YELLOW 1
*/
void Scan(char *text);
int GetColor(int x, int y, char* text, FILE *font);
void PrintinText(char * Sinology);
unsigned int Determine(char Sinology);
void PrintPixel(unsigned int x, unsigned int y, unsigned int size, unsigned int color);
void DrawCharacter(char *u, int abscissa, int ordinate, unsigned int size, unsigned int color, unsigned int italics);
int main(void) {
/*参数定义*/
	/*文件指针*/
	FILE *fp;
	/*文件大小*/
	unsigned long int Size;
	/*文本内容指针*/
	char *text;
	
/*打开文件*/	 
	if((fp=fopen("text.txt","rb"))==NULL){
		printf("Cannot open text file\n");
		exit(0);
	}
	
/*计算文件大小*/
	fseek(fp,0,SEEK_END);
	Size=ftell(fp);
	rewind(fp);
	/*printf("Size=%ld\n",Size);*/

/*读取文件内容*/
	text=(char*)malloc(Size*sizeof(char));
	fread(text, sizeof(char), Size, fp);
	/*for(i=0;i<Size;i+=2)printf("%c%c",text[i],text[i+1]);*/

/*扫描显示*/
	Scan(text);

/*清屏还原*/	
	getchar();
	system("cls");

/*关闭文件*/
	if(fclose(fp)){
		printf("Cannot close text file\n");
		exit(0);
	}
	return 0;
}

void Scan(char *text){
/*参数定义*/
	/*字体文件指针*/
	FILE *font;
	/*文件大小*/
	unsigned long int Size;
	/*循环控制变量*/ 
	int i, j;
	/*初始坐标参数*/
	int *cx, *cy;
	/*颜色*/
	unsigned int color; 
	/*例子文本*/ 
	unsigned char text1[50]="浙江大学\0"; 
	
	cx=(int *)malloc(sizeof(int));
	cy=(int *)malloc(sizeof(int));
	*cx=*cy=0;
/*计算文件大小*/
	Size=strlen(text);
	
	/*printf("Size=%ld\n",Size);*/
/*打开字体文件*/
	if((font=fopen("Hzk16","rb"))==NULL){
		printf("Cannot open fonr file\n");
		exit(0);
	}
	initgraph(cx,cy,"");
	for(i=0;i<480;++i)
		for(j=0;j<640;++j){
			/*如果扫描位置超出文本范围，结束*/
			if((i*480+j)>(Size/16+1)*18*640){
				color=BLACK;
				putpixel(j,i,color); 
				break;
			}
			
			color=GetColor(i,j,text,font);
			putpixel(j,i,color);
		}
/*关闭字体文件*/
	if(fclose(font)){
		printf("Cannot close font file\n");
		exit(0);
	}

	return;
}
int GetColor(int x, int y, char* text, FILE *font){
/*参数定义*/
	/*文字位置*/
	unsigned int location;
	/*区位码*/
	unsigned long int q, w;
	/*汉字码*/
	unsigned char u[32];
	/*当前汉字*/
	unsigned char Sino[2];
	/*汉字在字体文件中的位置*/
	unsigned long int offset;
	/*扫描点在汉字点阵中的位置*/
	unsigned int hx, hy;
	/*扫描点所在byte*/	 
	unsigned int byte;
	/*扫描点在当前byte中的第几位*/	 
	unsigned int bit;
	/*用于比较的byte*/
	unsigned char Cur=0x01;
	/*控制循环变量*/
	unsigned char i;
	/*文件大小*/
	unsigned long int Size;
	/*记录文件*/
	FILE* record;
/*打开记录文件*/
	record=fopen("record.txt","a");
/*计算文件大小*/
	Size=strlen(text)-1;
	 
/*行距显示黑色*/
	if(x%18==16||x%18==17)	
		return BLACK;
/*计算扫描点所处文字的位置*/ 
	location=x/LineSpace*LettersPerLine+y/Adjaceney;
	/*printf("%d\n",location);*/

/*计算当前汉字*/
	Sino[0]=text[2*location];
	Sino[1]=text[2*location+1];
/*计算当前汉字区位码*/
	q=(Sino[0]-0x0A1)&0x0FF;
	w=(Sino[1]-0x0A1)&0x0FF;
/*计算汉字在字体文件中的位置*/
	offset=(q*94L+w)*32L;
/*读取汉字码*/
	fseek(font,offset,SEEK_SET);
	fread(u,1,32L,font);
	/*DrawCharacter(u, 200, 200, 1, YELLOW, 0);*/
/*计算扫描点在汉字点阵中的位置*/
	hx=x%18;
	hy=y%16;
/*计算扫描点在汉字点阵中的byte*/
	byte=2*hx+y/8;
/*计算扫描点在挡墙byte中的第几位，从低位算起第0位*/
	bit=7-hy%8;
	for(i=0;i<bit;++i)
		Cur<<=1;
/*如果超出文本范围，返回黑色*/
	if(2*(location+1)>strlen(text)-1)return BLACK;
	/*
	for(i=0;i<32;++i){
		printf("%2X ",u[i]);
		if(i%2==1)printf("\n");
	}
	printf("\n\n\n");
	*/
	
	
	fprintf(record,"(x,y)=(%d,%d)\n",x,y);
	
	/*
	printf("(q,w)=(%d,%d)\n",q,w);
	printf("offset=%d\n",offset);
	printf("Location=%d\n",location);
	printf("Sino=%c%c\n",Sino[0],Sino[1]);
	printf("(hx,hy)=(%d,%d)\n",hx,hy);
	printf("byte=%d\n",byte);
	printf("bit=%d\n",bit);
	printf("(u[byte],Cur)=(%X,%X)\n",u[byte],Cur);
	*/
	
	fprintf(record,"pixel=%X\n\n",(u[byte]&Cur)==0?0:1);
	
	/*PrintinText(u);*/
	fclose(record);
/*计算返回色素*/ 	
	return (u[byte]&Cur)==0?BLACK:YELLOW;
	
}
void PrintinText(char * Sinology) {
	int i,j,m;
	for(j=0; j<16; j++){
		m=0x80;
		for(i=0; i<8; i++){
			if(Sinology[2*j]&m)printf("**");
			else printf("  ");
			m>>=1;
		}
		
		m=0x80;
		for(i=0; i<8; i++){
			if(Sinology[2*j+1]&m)printf("**");
			else printf("  ");
			m>>=1;
		}
		
		printf("\n");
	}
	return;
}
unsigned int Determine(char Sinology) {
	unsigned charm, i,m;
	m=0x80;
	for(i=0; i<8; i++){
		if(Sinology&m)
			return YELLOW;
		else
			m>>=1;
	}
	return BLACK;
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
			;//putpixel(curx,cury,color);
	return;
}
