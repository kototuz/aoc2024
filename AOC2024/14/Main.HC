Cd(__DIR__);

#if 1
  #define FILE "Input.TXT"
  #define SPACE_WIDTH  101
  #define SPACE_HEIGHT 103
  #define ROBOT_COUNT  500
#else
  #define FILE "Sample.TXT"
  #define SPACE_WIDTH  11
  #define SPACE_HEIGHT 7
  #define ROBOT_COUNT  12
#endif

#define QUADRANT_WIDTH  ((SPACE_WIDTH-1)/2)
#define QUADRANT_HEIGHT ((SPACE_HEIGHT-1)/2)

#define CELL_SIZE   4
#define BORDER_SIZE 2

class Vec2 {
  I64 x,y;
};

class Robot {
  Vec2 pos;
  Vec2 vel;
};

Robot robots[ROBOT_COUNT];

U0 LoadRobots()
{
  U8 *src=FileRead(FILE);

  I64 i;
  U8 *p=src;
  for (i=0;i<ROBOT_COUNT;i++) {
    p+=2;
    robots[i].pos.x=Str2I64(p,,&p);
    p+=1;
    robots[i].pos.y=Str2I64(p,,&p);

    p+=3;
    robots[i].vel.x=Str2I64(p,,&p);
    p+=1;
    robots[i].vel.y=Str2I64(p,,&p);

    p+=1;
  }

  Free(src);
}

CDC *dc=DCAlias;
U0 DrawSpace()
{
  I64 x,y;

  for (y=0;y<SPACE_HEIGHT;y++) {
    for (x=0;x<SPACE_WIDTH;x++) {
      dc->color=LTGRAY;
      GrRect(dc,x*CELL_SIZE,y*CELL_SIZE,CELL_SIZE,CELL_SIZE);
      dc->color=BLACK;
      GrRect(dc,x*CELL_SIZE+BORDER_SIZE,y*CELL_SIZE+BORDER_SIZE,
             CELL_SIZE-BORDER_SIZE,CELL_SIZE-BORDER_SIZE);
    }
  }

  dc->color=RED;
  for (x=0;x<ROBOT_COUNT;x++) {
    GrRect(dc,robots[x].pos.x*CELL_SIZE+BORDER_SIZE,
           robots[x].pos.y*CELL_SIZE+BORDER_SIZE,
           CELL_SIZE-BORDER_SIZE,CELL_SIZE-BORDER_SIZE);
  }
}

Bool InsideQuadrant(I64 qx,I64 qy,Vec2 *pos)
{
  return qx<=pos->x && pos->x<(qx+QUADRANT_WIDTH) &&
         qy<=pos->y && pos->y<(qy+QUADRANT_HEIGHT);
}

I64 CalcSafetyFactor()
{
  I64 i,q1=0,q2=0,q3=0,q4=0;
  for (i=0;i<ROBOT_COUNT;i++) {
    if (InsideQuadrant(0,0,&robots[i].pos))
      q1+=1;
    if (InsideQuadrant(QUADRANT_WIDTH+1,0,&robots[i].pos))
      q2+=1;
    if (InsideQuadrant(0,QUADRANT_HEIGHT+1,&robots[i].pos))
      q3+=1;
    if (InsideQuadrant(QUADRANT_WIDTH+1,QUADRANT_HEIGHT+1,&robots[i].pos))
      q4+=1;
  }

  return q1*q2*q3*q4;
}

#define TICK_COUNT 100
U0 Part1()
{
  LoadRobots;

  I64 i,j,nx,ny;
  for (j=0;j<TICK_COUNT;j++) {
    for (i=0;i<ROBOT_COUNT;i++) {
      nx=robots[i].pos.x+robots[i].vel.x;
      ny=robots[i].pos.y+robots[i].vel.y;

      if (nx>=SPACE_WIDTH)  nx-=SPACE_WIDTH;
      if (ny>=SPACE_HEIGHT) ny-=SPACE_HEIGHT;
      if (nx<0)             nx=SPACE_WIDTH+nx;
      if (ny<0)             ny=SPACE_HEIGHT+ny;

      robots[i].pos.x=nx;
      robots[i].pos.y=ny;
    }
  }

  "RESULT: %d\n",CalcSafetyFactor;$WW,1$
}

#define AREA_SIZE 10
Bool InsideArea(I64 x,I64 y,Vec2 *pos)
{
  return x<=pos->x && pos->x<(x+AREA_SIZE*2) &&
         y<=pos->y && pos->y<(y+AREA_SIZE*2);
}

I64 MaxDensity()
{
  I64 i,j,ax,ay,cnt,max=0;
  for (i=0;i<ROBOT_COUNT;i++) {
    ax=robots[i].pos.x-AREA_SIZE;
    ay=robots[i].pos.y-AREA_SIZE;

    cnt=0;
    for (j=0;j<ROBOT_COUNT;j++) {
      if (InsideArea(ax,ay,&robots[j].pos))
        cnt+=1;
    }

    max=MaxI64(max,cnt);
  }
  return max;
}

U0 Part2()
{
  LoadRobots;

  I64 i,j=0,nx,ny,den;
  while (TRUE) {
    den=MaxDensity;
    if (den>100) {
      DCFill;
      DocClear;
      DrawSpace;
      GrPrint(dc,0,CELL_SIZE*SPACE_HEIGHT,"Tick: %d",j);
      GrPrint(dc,0,CELL_SIZE*SPACE_HEIGHT+8,"Max density: %d",den);
      GetChar;
    }

    for (i=0;i<ROBOT_COUNT;i++) {
      nx=robots[i].pos.x+robots[i].vel.x;
      ny=robots[i].pos.y+robots[i].vel.y;

      if (nx>=SPACE_WIDTH)  nx-=SPACE_WIDTH;
      if (ny>=SPACE_HEIGHT) ny-=SPACE_HEIGHT;
      if (nx<0)             nx=SPACE_WIDTH+nx;
      if (ny<0)             ny=SPACE_HEIGHT+ny;

      robots[i].pos.x=nx;
      robots[i].pos.y=ny;
    }
    j+=1;
  }
}








//Part1;
Part2;
DCDel(dc);
