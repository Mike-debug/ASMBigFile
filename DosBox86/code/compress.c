#include<stdio.h>
#include<math.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include<time.h>
/*行图像数据压缩函数*/
unsigned int Compress(unsigned int OriginalSize, unsigned char *Original, unsigned char **Compressed);
int main(void) {
	unsigned int OriginalSize, CompressedSize;
	unsigned char *Original, *Compressed;
	int i;/*循环控制变量*/
	
	printf("Input the originial size:");
	scanf("%u",&OriginalSize);
	Original=(unsigned char *)malloc(OriginalSize*sizeof(unsigned char));
	/*
	for(i=0;i<OriginalSize;++i)
		Original[i]=rand()%5;
	*/
	
	Original[0]='a';
	Original[1]='a';
	Original[2]='a';
	Original[3]='a';
	Original[4]='a';
	Original[5]='a';
	Original[6]='a';
	Original[7]='a';
	Original[8]='b';
	/*
	Original[9]='b';
	Original[10]='b';
	Original[11]='b';
	Original[12]='b';
	Original[13]='c';
	Original[14]='d';
	Original[15]='a';
	Original[16]='a';
	Original[17]='f';
	Original[18]='g';
	Original[19]='h';
	Original[20]='i';
	*/
	for(i=0;i<OriginalSize;++i){
		printf("%2X ",Original[i]);
		if(i%16==15)printf("\n");
	}
	printf("\n");
	CompressedSize=Compress(OriginalSize,Original,&Compressed);
	printf("size of original=%d\n",OriginalSize);
	printf("size of compressed=%d\n",CompressedSize);
	printf("Original:\n");
	for(i=0;i<OriginalSize;++i){
		printf("%2X ",Original[i]);
		if(i%16==15)printf("\n");
	}
	printf("\n");
	printf("Compressed:\n");
	for(i=0;i<CompressedSize;++i){
		printf("%2X ",Compressed[i]);
		if(i%16==15)printf("\n");
	}
	
	return 0;
}
/*行图像数据压缩函数*/
unsigned int Compress(unsigned int OriginalSize, unsigned char *Original, unsigned char **Compressed){
	unsigned int CompressedSize;
	unsigned char temp;
	int i, j;
	int SameCount, DifferentCount;
	int CompressedCursor;
	/*压缩后的数据不会超过原数据的两倍*/
	CompressedSize=(OriginalSize<<1)+4;
	*Compressed=(unsigned char*)malloc(CompressedSize*sizeof(unsigned char));
	temp=Original[0];
	SameCount=DifferentCount=1;
	CompressedCursor=0;
	for(i=1;i<OriginalSize;++i){
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
