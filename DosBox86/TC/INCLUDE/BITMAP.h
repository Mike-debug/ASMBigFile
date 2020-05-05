typedef unsigned char	BYTE;	/*1 byte*/
typedef unsigned int	WORD;	/*2 bytes*/
typedef unsigned long	DWRD;	/*4 bytes*/

typedef struct tagBITMAPFILEHEADER
{
	WORD	bfType;		/*�ļ���ʶ BM*/
	DWRD	bfSize;		/*�ļ��ܳ���*/
	WORD	bfReserved1;/*��������Ϊ0*/
	WORD	bfReserved2;/*��������Ϊ0*/
	DWRD	bfOffBits;	/*ƫ����*/
}
BITMAPFILEHEADER;
/*
typedef struct tagBITMAPINFO
{
	BITMAPINFOHEADER	bmiHeader;
	RGBQUAD				bmiColors[1];
}BITMAPINFO;
*/
typedef struct tagBITMAPINFOHEADER
{
	DWRD biSize;	/*BITMAPINFOHEADER�Ĵ�С*/
	DWRD biWidth;	/*λͼ���*/
	DWRD biHeight;	/*λͼ�߶�*/
	WORD biPlanes;	/*��ɫλ��������Ϊ1*/
	WORD biBitCount;	/*ÿ������ɫλ��1��2��4��8��24��*/
	DWRD bmCompression;/*ѹ��ģʽ��0=�ޣ�*/
	DWRD biSizelmage;	/*λͼ��С*/
	DWRD biXPelsPerMeter;	/*ˮƽ�ֱ���*/
	DWRD biYPelsPerMeter;	/*��ֱ�ֱ���*/
	DWRD biClrUsed;		/*��ʹ�õ���ɫ��*/
	DWRD beClrlmportant;	/*��Ҫ��ɫ��*/
}
BITMAPINFOHEADER;

typedef struct tagRGBQUAD
{
	BYTE	rgbBlue;
	BYTE	rgbGreen;
	BYTE	rgbRed;
	BYTE	rgbReserved;
}
RGBQUAD;
