/*--------------------------------------------------------------------------------------------*/
/*ͷ�ļ�*/
#include<stdio.h>
#include<math.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include<time.h>
#include "bitmap.h"

unsigned long Compress(unsigned long OriginalSize, unsigned char *Original, unsigned char **Compressed);
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
/*��ʼ��������־*/
	End[0]=0x00;End[1]=0x01;
/*��bmp�ļ�*/
	if((OriginalBmp=fopen("original.bmp","rb"))==NULL){
		printf("Cannot open bmp image\n");
		exit(0);
	}
	if((NewBmp=fopen("New.bmp","wb"))==NULL){
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
	
	if(bi.bmCompression==1){
		printf("picture already compressed\n");
		exit(0);
	}
	
/*���ļ�ͷ��ͼͷ��Ϣд��ѹ���ļ�*/
	fwrite(&bf,sizeof(bf),1,NewBmp);
	bi.bmCompression=1;/*��ʾͼ���Ѿ�ѹ��*/
	fwrite(&bi,sizeof(bi),1,NewBmp);

/*��Ϊ��ɫ����ɫ����ͼͷ��������ɫ��Ķ�ȡһ��Ҫ�ŵ�ͼͷ֮��*/
/*��ȡbmp�ĵ�ɫ��*/
	fread(rgb, sizeof(RGBQUAD), colors, OriginalBmp);/*��ȡ��ɫ����Ϣ*/
/*����ɫ����Ϣд��ѹ���ļ�*/
	fwrite(rgb, sizeof(RGBQUAD), colors, NewBmp);
	fprintf(record,"data begin: %X", ftell(OriginalBmp));
/*��ʼ��һ�е���Ϣ*/
	u=(unsigned char*)malloc(sizeof(unsigned char*)*bi.biHeight);
	for(j=0; j<bi.biHeight;j++){
		fread(u,1,bi.biWidth,OriginalBmp);
		CompressedSize=Compress(bi.biWidth,u,&Compressed);
		fwrite(Compressed,1,CompressedSize,NewBmp);
	}
	fwrite(End,1,2,NewBmp);
		
	
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
	getchar();
	return 0;
}
/*��ͼ������ѹ������*/
unsigned long Compress(unsigned long OriginalSize, unsigned char *Original, unsigned char **Compressed){
	unsigned long CompressedSize;
	unsigned char temp;
	unsigned long i, j;
	unsigned long SameCount, DifferentCount;
	unsigned long CompressedCursor;
	/*ѹ��������ݲ��ᳬ��ԭ���ݵ�����*/
	CompressedSize=(OriginalSize<<1)+4;
	free(*Compressed);
	*Compressed=(unsigned char*)malloc(CompressedSize*sizeof(unsigned char));
	temp=Original[0];
	SameCount=DifferentCount=1;
	CompressedCursor=0;
	for(i=1;i<OriginalSize;++i){
		/*���ǰ�ߺͺ�����ͬ������ͬ������һ����ͬ�����ض�ά��Ϊ1*/
		if(Original[i]==temp){
			++SameCount;
			if(SameCount>=0xFF){
				Compressed[0][CompressedCursor++]=0xFF;
				Compressed[0][CompressedCursor++]=temp;
			}
			else if(DifferentCount==2){
				Compressed[0][CompressedCursor++]=0x01;
				Compressed[0][CompressedCursor++]=Original[i-2];
			}
			else if(DifferentCount==3){
				Compressed[0][CompressedCursor++]=0x01;
				Compressed[0][CompressedCursor++]=Original[i-3];
				Compressed[0][CompressedCursor++]=0x01;
				Compressed[0][CompressedCursor++]=Original[i-2];
			}
			else if(DifferentCount>3&&DifferentCount<0xFF){
				Compressed[0][CompressedCursor++]=0x00;
				Compressed[0][CompressedCursor++]=DifferentCount-1;
				for(j=0;j<DifferentCount-1;++j){
					Compressed[0][CompressedCursor++]=Original[i-(DifferentCount-j)];
				}
			}
			if(i>=OriginalSize-1){
				Compressed[0][CompressedCursor++]=SameCount;
				Compressed[0][CompressedCursor++]=temp;
				DifferentCount=1;
				break;
			}
			DifferentCount=1;
		}
		/*���ǰ�ߺͺ��߲�ͬ����ͬ������һ����ͬ�����ض�ά��Ϊ1*/
		else{
			++DifferentCount;
			if(SameCount>=DifferentCount){
				Compressed[0][CompressedCursor++]=SameCount;
				Compressed[0][CompressedCursor++]=temp;
				DifferentCount=1;
			}
			else if(DifferentCount>=0x0FF||i>=OriginalSize-1){
				if(DifferentCount==2){
					Compressed[0][CompressedCursor++]=0x01;
					Compressed[0][CompressedCursor++]=Original[i-1];
					Compressed[0][CompressedCursor++]=0x01;
					Compressed[0][CompressedCursor++]=Original[i];
				}
				else{
					Compressed[0][CompressedCursor++]=0x00;
					Compressed[0][CompressedCursor++]=DifferentCount;
					for(j=0;j<DifferentCount;++j){
						Compressed[0][CompressedCursor++]=Original[i-(DifferentCount-j-1)];
					}
				}
				if(i>=OriginalSize-1)break;
				DifferentCount=1;
			}
			SameCount=1;
		}
		temp=Original[i];
	}
	/*�漰��������ĩβ�������������*/
	if(i>=OriginalSize-1&&DifferentCount==1&&SameCount==1){
		Compressed[0][CompressedCursor++]=SameCount;
		Compressed[0][CompressedCursor++]=temp;
	}
	else if(SameCount>DifferentCount);
	else if(temp==Original[i-1]){
		Compressed[0][CompressedCursor++]=SameCount;
		Compressed[0][CompressedCursor++]=temp;
	}
	else{
		Compressed[0][CompressedCursor++]=SameCount;
		Compressed[0][CompressedCursor++]=Original[i-1];
	}
	Compressed[0][CompressedCursor++]=0x0;
	Compressed[0][CompressedCursor++]=0x0;
	CompressedSize=CompressedCursor;
	
	return CompressedSize;
}
