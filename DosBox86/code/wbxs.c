#include<stdio.h>
#include<math.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include<time.h>

int main(void) {
	unsigned int q, w;/*区位 */
	FILE *fp;/*文件指针 */
	unsigned char Sinology[32];/*坐标 */
	int i,j;/*循环 */
	int m;
	unsigned char Hz[2]="浙";
	unsigned long int offset;
	
	if((fp=fopen("Hzk16","rb"))==NULL){
		printf("Cannot open file!\n");
		exit(0);
	}
	

	
	offset=((Hz[0]-0x0A1)*94+Hz[1]-0x0A1)*32L;
	fseek(fp,offset,SEEK_SET);
	fread(Sinology,sizeof(char),32,fp);
	printf("Hz[0]=%X, Hz[1]=%X, offset=%X\n",Hz[0],Hz[1],offset);
	for(i=0;i<32;++i){
		printf("%2X  ",Sinology[i]);
		if(i%8==7)printf("\n");
	}
		
	/*printf("offset=%d\n",offset);*/
	/*printf("%c%c\n",Hz[0],Hz[1]);*/
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


	if(fclose(fp)){
		printf("Cannot close the file!\n");
		exit(0);
	}
	getchar();
	return 0;
}

