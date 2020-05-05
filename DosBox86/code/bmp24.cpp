/*bmp24Î»Í¼Æ¬Ëõ·Å*/

#include <stdio.h>
#include <windows.h>

int main(void)
{

	int count=0,i=0,j=0,size=0,k=0;
	int i_tmp=0,j_tmp=0;
	double FZOOMRATIO = 0.3;
	const char* Bmp_data;
	unsigned char *pNewBmpBuf;
	unsigned long newBmpWidth=0,newBmpHeight=0;
	FILE *bmp24, *bmp16;

	BITMAPFILEHEADER bmp_24_header;
	BITMAPINFOHEADER bmp_24_info;

	if((bmp24 = fopen("k398a.bmp","rb"))==NULL)
	{
		printf("bmp24 open error\n");
		exit(1);
	}
	if((bmp16 = fopen("new.bmp","wb"))==NULL)
	{
		printf("bmp16 open error\n");
		exit(1);
	}
	memset(&bmp_24_header, 0, sizeof(BITMAPFILEHEADER));
	memset(&bmp_24_info, 0, sizeof(BITMAPINFOHEADER));
	fread(&bmp_24_header,sizeof(BITMAPFILEHEADER),1,bmp24);
	fread(&bmp_24_info,sizeof(BITMAPINFOHEADER),1,bmp24);

	size=bmp_24_info.biWidth*3*bmp_24_info.biHeight;
	newBmpWidth = (unsigned long) (bmp_24_info.biWidth * FZOOMRATIO +0.5);
	newBmpHeight = (unsigned long) (bmp_24_info.biHeight * FZOOMRATIO +0.5);

	int DataSizePerLine = newBmpWidth; 
	int newLineByte = DataSizePerLine % 4 ? (DataSizePerLine / 4 *4 + 4) : DataSizePerLine;

	DataSizePerLine = bmp_24_info.biWidth; 
	int lineByte = DataSizePerLine % 4 ? (DataSizePerLine / 4 *4 + 4) : DataSizePerLine;


    bmp_24_header.bfSize =  newBmpWidth*newBmpHeight*3 + 54;	 
	int tmpwidth=bmp_24_info.biWidth;
	int tmpheight=bmp_24_info.biHeight;
	bmp_24_info.biWidth = newBmpWidth;
	bmp_24_info.biHeight = newBmpHeight;
	bmp_24_info.biBitCount = 24;
	bmp_24_info.biCompression = 0;
	bmp_24_info.biPlanes = 1;

	bmp_24_info.biSizeImage =newBmpWidth*newBmpHeight*3;





	fwrite(&bmp_24_header,sizeof(bmp_24_header),1,bmp16);
	fwrite(&bmp_24_info,sizeof(bmp_24_info),1,bmp16);
	fseek(bmp16,54,0);

	fseek(bmp24,54,0);

	pNewBmpBuf = (unsigned char *)malloc(sizeof(char)*newBmpWidth* newBmpHeight*3*2);
	unsigned char *tempData = (unsigned char *)malloc(size*2);
	memset(pNewBmpBuf,0,sizeof(char)*newBmpWidth* newBmpHeight*3*2);
	memset(tempData,0,sizeof(char)*size*2);

	fread(tempData,1,size,bmp24);

	for(i = 0;i<newBmpHeight;i++)
	{
		for(j = 0; j<newBmpWidth;j++)
		{
		for(k=0;k<3;k++)
			{ 
				i_tmp = (long)(i/FZOOMRATIO+0.5);
				j_tmp = (long)(j/FZOOMRATIO+0.5);	
				if((j_tmp >=0) && (j_tmp < tmpwidth ) && (i_tmp >=0)&& (i_tmp <tmpheight))
				{

			
					pNewBmpBuf[i*newLineByte*3+j*3+k]= tempData[i_tmp*lineByte*3+j_tmp*3+k];
				}	
				else
				{
					pNewBmpBuf[i*newBmpWidth*3+j*3+k]=255;
				}

			}
		}
	}

	fwrite(pNewBmpBuf,1,newBmpWidth*newBmpHeight*3,bmp16);

	free(tempData);
	free(pNewBmpBuf);
	fclose(bmp24);
	fclose(bmp16);
 
	return 0;
}

