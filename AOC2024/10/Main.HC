Cd(__DIR__);

#if 1
  #define FILE   "Input.TXT"
  #define MAP_WH 52
#else
  #define FILE   "Sample.TXT"
  #define MAP_WH 8
#endif

U8 map[MAP_WH][MAP_WH];
U8 map2[MAP_WH][MAP_WH];
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

Bool InsideMap(I64 x,I64 y)
{
  return 0 <= x < MAP_WH &&
         0 <= y < MAP_WH;
}

U0 FindTrailheadEnds(I64 x,I64 y)
{
  I64 i,nx,ny,s=map2[x][y];

  if (s=='9') {
    map2[x][y]='X';
    return;
  }

  for (i=0;i<4;i++) {
    nx=x+directions[i][0];
    ny=y+directions[i][1];
    if (InsideMap(nx,ny) && map2[nx][ny]==s+1) {
      FindTrailheadEnds(nx,ny);
    }
  }
}

I64 CountTrailheadEnds()
{
  I64 x,y,res=0;
  for (y=0;y<MAP_WH;y++) {
    for (x=0;x<MAP_WH;x++) {
      if (map2[x][y]=='X')
        res+=1;
    }
  }
  return res;
}

U0 Part1()
{
  LoadMap;

  I64 x,y,res=0;
  for (y=0;y<MAP_WH;y++) {
    for (x=0;x<MAP_WH;x++) {
      if (map[x][y]=='0') {
        MemCpy(map2,map,sizeof(map));
        FindTrailheadEnds(x,y);
        res+=CountTrailheadEnds;
      }
    }
  }

  "RESULT: %d\n",res;
}

I64 CalcTrailheadRating(I64 x,I64 y)
{
  I64 i,nx,ny,rating=0,s=map[x][y];

  if (s=='9') return 1;

  for (i=0;i<4;i++) {
    nx=x+directions[i][0];
    ny=y+directions[i][1];
    if (InsideMap(nx,ny) && map[nx][ny]==s+1) {
      rating+=CalcTrailheadRating(nx,ny);
    }
  }

  return rating;
}

U0 Part2()
{
  LoadMap;

  I64 x,y,res=0;
  for (y=0;y<MAP_WH;y++) {
    for (x=0;x<MAP_WH;x++) {
      if (map[x][y]=='0') {
        res+=CalcTrailheadRating(x,y);
      }
    }
  }

  "RESULT: %d\n",res;
}

//Part1;
Part2;
