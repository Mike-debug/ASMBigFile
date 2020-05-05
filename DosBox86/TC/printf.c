/* ¨®?DosBoxTc¡À???????¦Ì?Options->Compiler->Model->Tiny
    Compile->Compile to OBJ
    Compile->Link EXE file
    Run->Run
    Run->User Screen
 */

extern int printf();
int f(int a, int b)
{
   return a+b;
}
void zzz(void)
{
}
main()
{
   char buf[100];
   char *p = (char *)printf;
   char *q = (char *)f;
   int n = (char *)zzz - (char *)f;
   int y;
   memcpy(buf, p, n);
   memcpy(p, q, n);
   y = printf(10, 20);
   memcpy(p, buf, n);
   printf("y=%d\n", y);
}
