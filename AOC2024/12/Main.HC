Cd(__DIR__);

#if 1
  #define MAP_WH 140
  #define FILE   "Input.TXT"
#else
  #define MAP_WH 10
  #define FILE   "Sample.TXT"
#endif

U8 map[MAP_WH][MAP_WH];
I64 directions[4][2]={
  {1,  0},
  {-1, 0},
  {0,  1},
  {0, -1},
};

U0 LoadMap()
{
  I64 x,y,i;
  U8 *src=FileRead(FILE);
  for (y=0;y<MAP_WH;y++) {
    for (x=0;x<MAP_WH;x++) {
      i=y*(MAP_WH+1) + x;
      map[x][y]=src[i];
    }
  }

  Free(src);
}

Bool InsideMap(I64 x,I64 y)
{
  return 0 <= x < MAP_WH &&
         0 <= y < MAP_WH;
}

U0 DumpMap()
{
  I64 x,y;
  for (y=0;y<MAP_WH;y++) {
    for (x=0;x<MAP_WH;x++) {
      "%c",map[x][y];
    }
    "\n";
  }
}

U0 RecognizeRegion(I64 x,I64 y)
{
  I64 i,nx,ny,plant=map[x][y];
  map[x][y]='#';
  for (i=0;i<4;i++) {
    nx=x+directions[i][0];
    ny=y+directions[i][1];
    if (InsideMap(nx,ny) && map[nx][ny]==plant) {
      RecognizeRegion(nx,ny);
    }
  }  
}

I64 CountOpenSides(I64 x,I64 y)
{
  I64 i,nx,ny,res=0;
  for (i=0;i<4;i++) {
    nx=x+directions[i][0];
    ny=y+directions[i][1];
    if (!InsideMap(nx,ny) || map[nx][ny]!='#') {
      res+=1;
    }
  }
  return res;
}

U0 ClearRegion()
{
  I64 x,y;
  for (y=0;y<MAP_WH;y++)
    for (x=0;x<MAP_WH;x++)
      if (map[x][y]=='#')
        map[x][y]='.';
}

I64 CalcPrice()
{
  I64 x,y,area=0,perimeter=0;
  for (y=0;y<MAP_WH;y++) {
    for (x=0;x<MAP_WH;x++) {
      if (map[x][y]=='#') {
        perimeter+=CountOpenSides(x,y);
        area+=1;
      }
    }
  }
  return area*perimeter;
}

U0 Part1()
{
  LoadMap;

  I64 x,y,res=0;
  for (y=0;y<MAP_WH;y++) {
    for (x=0;x<MAP_WH;x++) {
      if (map[x][y]!='.') {
        RecognizeRegion(x,y);
        res+=CalcPrice;
        ClearRegion;
      }
    }
  }

  "RESULT: %d\n",res;
}

class Vec2 {
  I64 x,y;
};

class Side {
  Vec2 pos;
  Vec2 dir;
};

#define SIDES_CAP 1024
Side sides[SIDES_CAP];
I64 side_count=0;

U0 PushSide(Side *s)
{
  if (side_count >= SIDES_CAP) throw;
  MemCpy(&sides[side_count],s,sizeof(Side));
  side_count+=1;
}

I64 SideIndex(Side *s)
{
  I64 i;
  for (i=0;i<side_count;i++)
    if (MemCmp(&sides[i],s,sizeof(Side))==0)
      return i;
  return -1;
}

U0 LoadPlantSides(I64 x,I64 y)
{
  Side s;
  I64 i,nx,ny,si;
  for (i=0;i<4;i++) {
    nx=x+directions[i][0];
    ny=y+directions[i][1];
    if (!InsideMap(nx,ny) || map[nx][ny]!='#') {
      s.pos.x=x;
      s.pos.y=y;
      s.dir.x=directions[i][0];
      s.dir.y=directions[i][1];
      if (s.dir.x==1 || s.dir.x==-1) {
        s.pos.y-=1;
        si=SideIndex(&s);
        if (si==-1) {
          s.pos.y+=1;
          PushSide(&s);
        } else {
          sides[si].pos.y+=1;
        }
      } else {
        s.pos.x-=1;
        si=SideIndex(&s);
        if (si==-1) {
          s.pos.x+=1;
          PushSide(&s);
        } else {
          sides[si].pos.x+=1;
        }
      }
    }
  }
}

I64 CalcPrice2()
{
  side_count=0;
  I64 x,y,area=0;
  for (y=0;y<MAP_WH;y++) {
    for (x=0;x<MAP_WH;x++) {
      if (map[x][y]=='#') {
        area+=1;
        LoadPlantSides(x,y);
      }
    }
  }
  return side_count*area;
}

U0 DumpSides()
{
  I64 i;
  for (i=0;i<side_count;i++) {
    "(%d,%d),(%d,%d)\n",sides[i].pos.x,sides[i].pos.y,
                        sides[i].dir.x,sides[i].dir.y;
  }
}

U0 Part2()
{
  LoadMap;

  I64 x,y,res=0;
  for (y=0;y<MAP_WH;y++) {
    for (x=0;x<MAP_WH;x++) {
      if (map[x][y]!='.') {
        RecognizeRegion(x,y);
        res+=CalcPrice2;
        ClearRegion;
      }
    }
  }

  "RESULT: %d\n",res;
}

//Part1;
Part2;
