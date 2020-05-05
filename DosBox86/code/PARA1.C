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
/*��������*/
	/*�ļ�ָ��*/
	FILE *fp;
	/*�ļ���С*/
	unsigned long int Size;
	/*�ı�����ָ��*/
	char *text;
	
/*���ļ�*/	 
	if((fp=fopen("text.txt","rb"))==NULL){
		printf("Cannot open text file\n");
		exit(0);
	}
	
/*�����ļ���С*/
	fseek(fp,0,SEEK_END);
	Size=ftell(fp);
	rewind(fp);
	/*printf("Size=%ld\n",Size);*/

/*��ȡ�ļ�����*/
	text=(char*)malloc(Size*sizeof(char));
	fread(text, sizeof(char), Size, fp);
	/*for(i=0;i<Size;i+=2)printf("%c%c",text[i],text[i+1]);*/

/*ɨ����ʾ*/
	Scan(text);

/*������ԭ*/	
	getchar();
	system("cls");

/*�ر��ļ�*/
	if(fclose(fp)){
		printf("Cannot close text file\n");
		exit(0);
	}
	return 0;
}

void Scan(char *text){
/*��������*/
	/*�����ļ�ָ��*/
	FILE *font;
	/*�ļ���С*/
	unsigned long int Size;
	/*ѭ�����Ʊ���*/ 
	int i, j;
	/*��ʼ�������*/
	int *cx, *cy;
	/*��ɫ*/
	unsigned int color; 
	/*�����ı�*/ 
	unsigned char text1[50]="�㽭��ѧ\0"; 
	
	cx=(int *)malloc(sizeof(int));
	cy=(int *)malloc(sizeof(int));
	*cx=*cy=0;
/*�����ļ���С*/
	Size=strlen(text);
	
	/*printf("Size=%ld\n",Size);*/
/*�������ļ�*/
	if((font=fopen("Hzk16","rb"))==NULL){
		printf("Cannot open fonr file\n");
		exit(0);
	}
	initgraph(cx,cy,"");
	for(i=0;i<480;++i)
		for(j=0;j<640;++j){
			/*���ɨ��λ�ó����ı���Χ������*/
			if((i*480+j)>(Size/16+1)*18*640){
				color=BLACK;
				putpixel(j,i,color); 
				break;
			}
			
			color=GetColor(i,j,text,font);
			putpixel(j,i,color);
		}
/*�ر������ļ�*/
	if(fclose(font)){
		printf("Cannot close font file\n");
		exit(0);
	}

	return;
}
int GetColor(int x, int y, char* text, FILE *font){
/*��������*/
	/*����λ��*/
	unsigned int location;
	/*��λ��*/
	unsigned long int q, w;
	/*������*/
	unsigned char u[32];
	/*��ǰ����*/
	unsigned char Sino[2];
	/*�����������ļ��е�λ��*/
	unsigned long int offset;
	/*ɨ����ں��ֵ����е�λ��*/
	unsigned int hx, hy;
	/*ɨ�������byte*/	 
	unsigned int byte;
	/*ɨ����ڵ�ǰbyte�еĵڼ�λ*/	 
	unsigned int bit;
	/*���ڱȽϵ�byte*/
	unsigned char Cur=0x01;
	/*����ѭ������*/
	unsigned char i;
	/*�ļ���С*/
	unsigned long int Size;
	/*��¼�ļ�*/
	FILE* record;
/*�򿪼�¼�ļ�*/
	record=fopen("record.txt","a");
/*�����ļ���С*/
	Size=strlen(text)-1;
	 
/*�о���ʾ��ɫ*/
	if(x%18==16||x%18==17)	
		return BLACK;
/*����ɨ����������ֵ�λ��*/ 
	location=x/LineSpace*LettersPerLine+y/Adjaceney;
	/*printf("%d\n",location);*/

/*���㵱ǰ����*/
	Sino[0]=text[2*location];
	Sino[1]=text[2*location+1];
/*���㵱ǰ������λ��*/
	q=(Sino[0]-0x0A1)&0x0FF;
	w=(Sino[1]-0x0A1)&0x0FF;
/*���㺺���������ļ��е�λ��*/
	offset=(q*94L+w)*32L;
/*��ȡ������*/
	fseek(font,offset,SEEK_SET);
	fread(u,1,32L,font);
	/*DrawCharacter(u, 200, 200, 1, YELLOW, 0);*/
/*����ɨ����ں��ֵ����е�λ��*/
	hx=x%18;
	hy=y%16;
/*����ɨ����ں��ֵ����е�byte*/
	byte=2*hx+y/8;
/*����ɨ����ڵ�ǽbyte�еĵڼ�λ���ӵ�λ�����0λ*/
	bit=7-hy%8;
	for(i=0;i<bit;++i)
		Cur<<=1;
/*��������ı���Χ�����غ�ɫ*/
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
/*���㷵��ɫ��*/ 	
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