typedef unsigned char	BYTE;	/*1 byte*/
typedef unsigned int	WORD;	/*2 bytes*/
typedef unsigned long	DWRD;	/*4 bytes*/

typedef struct tagBITMAPFILEHEADER
{
	WORD	bfType;		/*文件标识 BM*/
	DWRD	bfSize;		/*文件总长度*/
	WORD	bfReserved1;/*保留，总为0*/
	WORD	bfReserved2;/*保留，总为0*/
	DWRD	bfOffBits;	/*偏移量*/
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
	DWRD biSize;	/*BITMAPINFOHEADER的大小*/
	DWRD biWidth;	/*位图宽度*/
	DWRD biHeight;	/*位图高度*/
	WORD biPlanes;	/*颜色位面数，总为1*/
	WORD biBitCount;	/*每象数颜色位（1，2，4，8，24）*/
	DWRD bmCompression;/*压缩模式（0=无）*/
	DWRD biSizelmage;	/*位图大小*/
	DWRD biXPelsPerMeter;	/*水平分辨率*/
	DWRD biYPelsPerMeter;	/*垂直分辨率*/
	DWRD biClrUsed;		/*所使用的颜色数*/
	DWRD beClrlmportant;	/*重要颜色数*/
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
