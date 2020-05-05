#include<stdio.h>
#include<math.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include<time.h>
unsigned long int GetFileSize(FILE* fp);
int main(void) {
	FILE *fp;
	
	if((fp=fopen("text.dat","rb"))==NULL){
		printf("Cannot open file\n");
		exit(0);
	}
	
	//printf("%c%c",0xD5,0xE3);
	printf("Size=%d\n",GetFileSize(fp));
	if(fclose(fp)){
		printf("Cannot close file\n");
		exit(0);
	}
	return 0;
}
unsigned long int GetFileSize(FILE* fp){
	unsigned long int head, tail;
	head=ftell(fp);
	fseek(fp,0,SEEK_END);
	tail=ftell(fp);
	rewind(fp);
	return tail-head;
}
