#include<stdio.h>
#include<math.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include<time.h>
/*��ͼ������ѹ������*/
unsigned int Uncompress(unsigned int CompressSize, unsigned char *Compressed, unsigned char **Original);
int main(void) {
	unsigned int OriginalSize, CompressedSize;
	unsigned char *Original, *Compressed;
	int i;/*ѭ�����Ʊ���*/
	
	printf("Input the Compressed size:");
	scanf("%u",&CompressedSize);
	Compressed=(unsigned char *)malloc(CompressedSize*sizeof(unsigned char));
	
	for(i=0;i<CompressedSize;++i)
		Compressed[i]=rand()%0x100;
	
	for(i=0;i<CompressedSize;++i){
		printf("%2X ",Compressed[i]);
		if(i%16==15)printf("\n");
	}
	printf("\n");
	OriginalSize=Uncompress(CompressedSize,Compressed,&Original);
	printf("size of compressed=%d\n",CompressedSize);
	printf("size of original=%d\n",OriginalSize);
	
	printf("Compressed:\n");
	for(i=0;i<CompressedSize;++i){
		printf("%2X ",Compressed[i]);
		if(i%16==15)printf("\n");
	}
	printf("\n");
	printf("Original:\n");
	for(i=0;i<OriginalSize;++i){
		printf("%2X ",Original[i]);
		if(i%16==15)printf("\n");
	}
	return 0;
}
/*��ͼ�����ݽ�ѹ������*/
unsigned int Uncompress(unsigned int CompressSize, unsigned char *Compressed, unsigned char **Original){
	unsigned int OriginalSize;
	unsigned char temp;
	int i, j;
	OriginalSize=CompressSize;
	*Original=(unsigned char*) malloc(sizeof(unsigned char)*OriginalSize);
	
	strcpy(*Original,Compressed);
	return OriginalSize;
}
