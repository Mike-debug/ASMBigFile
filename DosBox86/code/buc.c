/*--------------------------------------------------------------------------------------------*/
/*头文件*/
#include<stdio.h>
#include<math.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include<time.h>
#include "bitmap.h"

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
	/*unsigned char		End[2];					/*结束标志*/
	/*unsigned char		NewLine[2];				/*换行标志*/
	unsigned char		*buf, *sentry;			/*缓冲和哨兵*/

/*初始化缓冲和哨兵*/
	buf=(unsigned char*)malloc(sizeof(unsigned char)*0x100);
	sentry=(unsigned char*)malloc(sizeof(unsigned char)*0x02);
	
/*初始化结束、换行标志*/
	/*
	End[0]=0x00;End[1]=0x01;
	NewLine[0]=0x00; NewLine[1]=0x00;
	*/
/*打开bmp文件*/
	if((OriginalBmp=fopen("New.bmp","rb"))==NULL){
		printf("Cannot open bmp image\n");
		exit(0);
	}
	if((NewBmp=fopen("uncp.bmp","wb"))==NULL){
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
	
	if(bi.bmCompression==0){
		printf("picture no need for uncompressing\n");
		exit(0);
	}
	
/*将文件头、图头信息写入压缩文件*/
	fwrite(&bf,sizeof(bf),1,NewBmp);
	bi.bmCompression=0;/*表示图像已经压缩*/
	fwrite(&bi,sizeof(bi),1,NewBmp);

/*因为调色板颜色数又图头决定，调色板的读取一定要放到图头之后*/
/*读取bmp的调色板*/
	fread(rgb, sizeof(RGBQUAD), colors, OriginalBmp);/*读取调色板信息*/
/*将调色板信息写入压缩文件*/
	fwrite(rgb, sizeof(RGBQUAD), colors, NewBmp);
	fprintf(record,"data begin: %X", ftell(OriginalBmp));
/*---------------------------------------------------------------------------------------------------*/
/*解压区段*/
	j=0;
	while(1){
		fprintf(record,"%d\n",j++);
		fread(sentry,sizeof(unsigned char),0x02,OriginalBmp);
		if(sentry[0]==0x00&&sentry[1]==0x01)break;
		else if(sentry[0]==0x00&&sentry[1]==0x00)continue;
		else{
			if(sentry[0]==0x00){
				fread(buf,sizeof(unsigned char),1*sentry[1],OriginalBmp);
				fwrite(buf,sizeof(unsigned char),1*sentry[1],NewBmp);
			}
			else{
				for(i=0;i<1*sentry[0];++i)
					fwrite(sentry+1,sizeof(unsigned char),1,NewBmp);
			}
		}
		
	}
/*---------------------------------------------------------------------------------------------------*/		
	
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
	printf("Uncompressed Successfully\n");
	getchar();
	return 0;
}
