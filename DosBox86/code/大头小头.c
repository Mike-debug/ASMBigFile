#include<stdio.h>
#include<math.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include<time.h>

int main(void) {
	unsigned char find[4];
	FILE *fp;
	int i;
	unsigned long int k=0x89ABCDEF;
	if((fp=fopen("file.txt","wb+"))==NULL){
		printf("Cannot open file\n");
		exit(0);
	}
	fwrite(&k,sizeof(unsigned long int),1,fp);
	rewind(fp);
	fread(find,1,4,fp);
	for(i=0;i<4;++i)
		printf("%X ",find[i]);
	printf("\n");
	if(fclose(fp)){
		printf("Cannot close file\n");
		exit(0);
	}
	return 0;
}

