/*--------------------------------------------------------------------------------------------*/
/*头文件*/
#include<stdio.h>
#include<math.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include<time.h>
#include "bitmap.h"

unsigned long Compress(unsigned long OriginalSize, unsigned char *Original, unsigned char **Compressed);
/*--------------------------------------------------------------------------------------------*/
/*主函数定义*/
int main(void)
{
/*主程序参数定义*/
	int					i, j, k;   				/*循环控制变量*/
	int 				colors;					/*调色板颜色数*/
	unsigned char		*u,*Compressed;						/*读取像素信息的寄存器*/
	FILE				*OriginalBmp, *NewBmp;	/*bmp文件指针*/
	BITMAPFILEHEADER	bf;						/*bmp文件文件头*/
	BITMAPINFOHEADER	bi;						/*bmp文件图头*/
	RGBQUAD				rgb[256];				/*调色板*/
	FILE				*record;				/*记录测试数据*/
	unsigned long		CompressedSize;			/*压缩行大小*/
	unsigned char		End[2];					/*结束标志*/
/*初始化结束标志*/
	End[0]=0x00;End[1]=0x01;
/*打开bmp文件*/
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
	
/*读取bmp图形文件头*/
	fread(&bf, sizeof(bf), 1, OriginalBmp);
/*读取图头*/
	fread(&bi, sizeof(bi), 1, OriginalBmp);

	
	/*记录文件内容指针位置，待删除*/
	/*
	fprintf(record,"filehead=%X\n",ftell(OriginalBmp));
	fprintf(record,"figurehead=%X\n",ftell(OriginalBmp));
	*/
	fprintf(record,"bfSize：	%lx\n", bf.bfSize);/*文件大小*/
	fprintf(record,"Compressed：%ld\n", bi.bmCompression);/*是否已经压缩*/
	fprintf(record,"biWidth: 	%ld\n", bi.biWidth);/*图像宽度*/
	fprintf(record,"biHeight:	%ld\n", bi.biHeight);/*图像高度*/
	fprintf(record,"biBitCount:	%d\n", bi.biBitCount);/*颜色位数*/
/*计算调色板颜色数*/
	colors=1<<bi.biBitCount;
	fprintf(record,"colors=		%X\n",colors);
	
	if(bi.bmCompression==1){
		printf("picture already compressed\n");
		exit(0);
	}
	
/*将文件头、图头信息写入压缩文件*/
	fwrite(&bf,sizeof(bf),1,NewBmp);
	bi.bmCompression=1;/*表示图像已经压缩*/
	fwrite(&bi,sizeof(bi),1,NewBmp);

/*因为调色板颜色数又图头决定，调色板的读取一定要放到图头之后*/
/*读取bmp的调色板*/
	fread(rgb, sizeof(RGBQUAD), colors, OriginalBmp);/*读取调色板信息*/
/*将调色板信息写入压缩文件*/
	fwrite(rgb, sizeof(RGBQUAD), colors, NewBmp);
	fprintf(record,"data begin: %X", ftell(OriginalBmp));
/*初始化一行的信息*/
	u=(unsigned char*)malloc(sizeof(unsigned char*)*bi.biHeight);
	for(j=0; j<bi.biHeight;j++){
		fread(u,1,bi.biWidth,OriginalBmp);
		CompressedSize=Compress(bi.biWidth,u,&Compressed);
		fwrite(Compressed,1,CompressedSize,NewBmp);
	}
	fwrite(End,1,2,NewBmp);
		
	
/*关闭文件*/
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
/*行图像数据压缩函数*/
unsigned long Compress(unsigned long OriginalSize, unsigned char *Original, unsigned char **Compressed){
	unsigned long CompressedSize;
	unsigned char temp;
	unsigned long i, j;
	unsigned long SameCount, DifferentCount;
	unsigned long CompressedCursor;
	/*压缩后的数据不会超过原数据的两倍*/
	CompressedSize=(OriginalSize<<1)+4;
	free(*Compressed);
	*Compressed=(unsigned char*)malloc(CompressedSize*sizeof(unsigned char));
	temp=Original[0];
	SameCount=DifferentCount=1;
	CompressedCursor=0;
	for(i=1;i<OriginalSize;++i){
		/*如果前者和后者相同，则相同数量加一，不同数量必定维持为1*/
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
		/*如果前者和后者不同，则不同数量加一，相同数量必定维持为1*/
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
	/*涉及到遍历到末尾结束的特殊情况*/
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
