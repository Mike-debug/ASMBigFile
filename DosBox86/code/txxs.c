#include <stdio.h>
#include <graphics.h>

int main(void)
{
	char	s[10]="’„", u[32];
	unsigned int		q, w, i, j, m;
	long	ofs;
	FILE	*fp;

	clrscr();
	q=(s[0]-0xA1)&0xFF;
	w=(s[1]-0xA1)&0xFF;

	ofs=(q*94+w)*32L;
	printf("%d, %d, %ld", q, w, ofs);

	fp=fopen("hzk16", "rb");
	fseek(fp, ofs, SEEK_SET);
	fread(u, 1, 32, fp);

	i=0; j=0;
	initgraph(&i, &j, "");

	for(j=0; j<16; j++){
		m=0x80;
		for(i=0; i<8; i++){
			if(u[j*2]&m)putpixel(i,j,YELLOW);
			m>>=1;
		}
		m=0x80;
		for(i=0; i<8; i++){
			if(u[j*2+1]&m)putpixel(i+8,j,YELLOW);
			m>>=1;
		}
		printf("\n");
	}

	getch();

	return 0;
}
