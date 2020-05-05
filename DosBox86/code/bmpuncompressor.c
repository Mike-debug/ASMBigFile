/*--------------------------------------------------------------------------------------------*/
/*ͷ�ļ�*/
#include<stdio.h>
#include<math.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include<time.h>
#include "bitmap.h"

/*--------------------------------------------------------------------------------------------*/
/*����������*/
int main(void)
{
/*�������������*/
	int					i, j, k;   				/*ѭ�����Ʊ���*/
	int 				colors;					/*��ɫ����ɫ��*/
	unsigned char		*u,*Compressed;						/*��ȡ������Ϣ�ļĴ���*/
	FILE				*OriginalBmp, *NewBmp;	/*bmp�ļ�ָ��*/
	BITMAPFILEHEADER	bf;						/*bmp�ļ��ļ�ͷ*/
	BITMAPINFOHEADER	bi;						/*bmp�ļ�ͼͷ*/
	RGBQUAD				rgb[256];				/*��ɫ��*/
	FILE				*record;				/*��¼��������*/
	unsigned long		CompressedSize;			/*ѹ���д�С*/
	unsigned char		End[2];					/*������־*/
	unsigned char		NewLine[2];				/*���б�־*/
	unsigned char		*buf, *sentry;			/*������ڱ�*/

/*��ʼ��������ڱ�*/
	buf=(unsigned char*)malloc(sizeof(unsigned char)*0x100);
	sentry=(unsigned char*)malloc(sizeof(unsigned char)*0x02);
/*��ʼ�����������б�־*/
	End[0]=0x00;End[1]=0x01;
	NewLine[0]=0x00; NewLine[1]=0x00;
/*��bmp�ļ�*/
	if((OriginalBmp=fopen("New.bmp","rb"))==NULL){
		printf("Cannot open bmp image\n");
		exit(0);
	}
	if((NewBmp=fopen("uncompressed.bmp","wb"))==NULL){
		printf("Cannot create bmp image\n");
		exit(0);
	}
	if((record=fopen("record.txt","w"))==NULL){
		printf("Cannot open record file\n");
		exit(0);
	}
	
/*��ȡbmpͼ���ļ�ͷ*/
	fread(&bf, sizeof(bf), 1, OriginalBmp);
/*��ȡͼͷ*/
	fread(&bi, sizeof(bi), 1, OriginalBmp);

	
	/*��¼�ļ�����ָ��λ�ã���ɾ��*/
	/*
	fprintf(record,"filehead=%X\n",ftell(OriginalBmp));
	fprintf(record,"figurehead=%X\n",ftell(OriginalBmp));
	*/
	fprintf(record,"bfSize��	%lx\n", bf.bfSize);/*�ļ���С*/
	fprintf(record,"Compressed��%ld\n", bi.bmCompression);/*�Ƿ��Ѿ�ѹ��*/
	fprintf(record,"biWidth: 	%ld\n", bi.biWidth);/*ͼ����*/
	fprintf(record,"biHeight:	%ld\n", bi.biHeight);/*ͼ��߶�*/
	fprintf(record,"biBitCount:	%d\n", bi.biBitCount);/*��ɫλ��*/
/*�����ɫ����ɫ��*/
	colors=1<<bi.biBitCount;
	fprintf(record,"colors=		%X\n",colors);
	
	if(bi.bmCompression==0){
		printf("picture no need for uncompressing\n");
		exit(0);
	}
	
/*���ļ�ͷ��ͼͷ��Ϣд��ѹ���ļ�*/
	fwrite(&bf,sizeof(bf),1,NewBmp);
	bi.bmCompression=0;/*��ʾͼ���Ѿ�ѹ��*/
	fwrite(&bi,sizeof(bi),1,NewBmp);

/*��Ϊ��ɫ����ɫ����ͼͷ��������ɫ��Ķ�ȡһ��Ҫ�ŵ�ͼͷ֮��*/
/*��ȡbmp�ĵ�ɫ��*/
	fread(rgb, sizeof(RGBQUAD), colors, OriginalBmp);/*��ȡ��ɫ����Ϣ*/
/*����ɫ����Ϣд��ѹ���ļ�*/
	fwrite(rgb, sizeof(RGBQUAD), colors, NewBmp);
	fprintf(record,"data begin: %X", ftell(OriginalBmp));
/*---------------------------------------------------------------------------------------------------*/
/*��ѹ����*/
	while(1){
		fread(sentry,sizeof(unsigned char),0x02,OriginalBmp);
		if(strcmp(End,sentry)==0)break;
		else if(strcmp(NewLine,sentry)!=0){
			if(sentry[0]!=0x00)
				fwrite(sentry+1,sizeof(unsigned char),sentry[0],NewBmp);
			else{
				fread(buf,sizeof(unsigned char),sentry[1],OriginalBmp);
				fwrite(buf,sizeof(unsigned char),sentry[1],NewBmp);
			}
		}
	}
/*---------------------------------------------------------------------------------------------------*/		
	getchar();
/*�ر��ļ�*/
	if(fclose(OriginalBmp)){
		printf("Cannot close original bmp image\n");
		exit(0);
	}
	if(fclose(NewBmp)){
		printf("Cannot close new bmp image\n");
		exit(0);
	}
	if(fclose(record)){
		printf("Cannot close record file\n");
		exit(0);
	}
	printf("Compressed Successfully\n");
	return 0;
}
