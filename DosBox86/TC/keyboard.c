#include <graphics.h>

volatile int stop=0;
void interrupt int_9h(void);
void interrupt (*old_9h)(void);
void char2hex(unsigned char x, char hex[]);

void main()
{
    old_9h = getvect(9);
    setvect(9, int_9h); /* save interrupt vector of 9 */
    while(!stop);
    setvect(9, old_9h); /* recover interrupt vector of 9 */
}

void char2hex(unsigned char x, char hex[])
{
   static char t[]="0123456789ABCDEF";
   hex[0] = t[x >> 4];
   hex[1] = t[x & 0x0F];
   hex[2] = '\0';
}

void interrupt int_9h(void)
{
    unsigned char key;
    static char buf[100], hex[10];
    key = inportb(0x60);  /* read key code */
    if( key == 0xE0 || key == 0xE1)
    {
       strcpy(buf, "KeyExtend=");
       char2hex(key, hex);
       strcat(buf, hex);
       puts(buf);
    }
    else if( (key & 0x80) == 0x80 )
    {
       strcpy(buf, "KeyUp=");
       char2hex(key, hex);
       strcat(buf, hex);
       strcat(buf, "\n");
       puts(buf);
    }
    else
    {
       strcpy(buf, "KeyDown=");
       char2hex(key, hex);
       strcat(buf, hex);
       puts(buf);
    }
    if(key==0x81) /* Esc key is pressed and released */
       stop = 1;  /* Set the signal flag */
    outportb(0x20, 0x20); /* End Of Interrupt */
}
