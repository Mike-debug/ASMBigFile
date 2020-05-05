#include<stdio.h>
#include<math.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include<time.h>

int main(void) {
	unsigned char Hanzi[2];
	Hanzi[0]=0xD5;
	Hanzi[1]=0xE3;
	printf("%c%c\n",Hanzi[0],Hanzi[1]);
	return 0;
}

