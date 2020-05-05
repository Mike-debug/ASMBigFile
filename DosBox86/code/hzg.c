#include<stdio.h>
#include<math.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include<time.h>
#include<graphics.h>
int main(void) {
	unsigned int q, w;
	FILE *fp; 
	unsigned char Sinology[32];
	unsigned int i,j, m;
	unsigned int H1, H2;
	unsigned long int offset;
	if((fp=fopen("Hzk16","rb"))==NULL){
		printf("Cannot open file!\n");
		exit(0);
	};
	
	
	H1=0xB0;
	H2=0xA1;
	offset=((H1-0xA1)*94+H2-0xA1)*32;
	fseek(fp, offset, SEEK_SET);
	fread(Sinology,sizeof(char),32,fp);
	
	i=DETECT; j=0;
	initgraph(&i, &j, "");
	
	for(j=0; j<16; j++){
		m=0x80;
		for(i=0; i<8; i++){
			if(Sinology[2*j]&m)putpixel(i,j,YELLOW);
			else printf("  ");
			m>>=1;
		}
		m=0x80;
		for(i=0; i<8; i++){
			if(Sinology[2*j+1]&m)putpixel(i,j,YELLOW);
			else printf("  ");
			m>>=1;
		}
		printf("\n");
	}


	if(fclose(fp)){
		printf("Cannot close the file!\n");
		exit(0);
	}
	return 0;
}

