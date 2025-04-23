Cd(__DIR__);

#if 1
  #define FILE          "Input.TXT"
  #define MACHINE_COUNT 320
#else
  #define FILE          "Sample.TXT"
  #define MACHINE_COUNT 4
#endif

#define MAX_PRESS_COUNT 100

class Vec2 {
  I64 x,y;
};

class Machine {
  Vec2 a_btn;
  Vec2 b_btn;
  Vec2 prize;
};

Machine machines[MACHINE_COUNT];

U0 LoadMachines()
{
  U8 *src=FileRead(FILE);

  U8 *p=src;
  I64 i;
  for (i=0;i<MACHINE_COUNT;i++) {
    p+=12;
    machines[i].a_btn.x=Str2I64(p,,&p);
    p+=4;
    machines[i].a_btn.y=Str2I64(p,,&p);
    p+=1;
   
    p+=12;
    machines[i].b_btn.x=Str2I64(p,,&p);
    p+=4;
    machines[i].b_btn.y=Str2I64(p,,&p);
    p+=1;

    p+=9;
    machines[i].prize.x=Str2I64(p,,&p);
    p+=4;
    machines[i].prize.y=Str2I64(p,,&p);
    p+=2;
  }

  Free(src);
}

Bool SimulatePresses(Machine *m,I64 a,I64 b)
{
  return m->a_btn.x*a+m->b_btn.x*b == m->prize.x &&
         m->a_btn.y*a+m->b_btn.y*b == m->prize.y;
}

U0 Part1()
{
  LoadMachines;

  I64 i,a,b,res=0;
  for (i=0;i<MACHINE_COUNT;i++) {
    for (a=0;a<=MAX_PRESS_COUNT;a++) {
      for (b=0;b<=MAX_PRESS_COUNT;b++) {
        if (SimulatePresses(&machines[i],a,b)) {
          res+=a*3 + b;
        }
      }
    }
  }

  "RESULT: %d\n",res;
}

U0 Part2()
{
  LoadMachines;

  Machine *m;
  I64 i,d,dx,dy,res=0;
  for (i=0;i<MACHINE_COUNT;i++) {
    m=&machines[i];
    m->prize.x+=10000000000000;
    m->prize.y+=10000000000000;

    d=m->a_btn.x*m->b_btn.y - m->a_btn.y*m->b_btn.x;
    dx=m->prize.x*m->b_btn.y - m->prize.y*m->b_btn.x;
    dy=m->prize.y*m->a_btn.x - m->prize.x*m->a_btn.y;
    if (dx%d==0 && dy%d==0) {
      res+=(dx/d)*3 + dy/d;
    }
  }

  "RESULT: %d\n",res;
}

//Part1;
Part2;
