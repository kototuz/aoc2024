Cd(__DIR__);

#define MAP_WIDTH  50
#define MAP_HEIGHT 50
#define FILE       "Input.TXT"

U8 map[MAP_WIDTH][MAP_HEIGHT];
U8 map2[MAP_WIDTH][MAP_HEIGHT];
MemSet(map2,0x0,sizeof(map2));

U0 LoadMap()
{
  I64 x,y,i;
  U8 *src=FileRead(FILE);
  for (y=0;y<MAP_HEIGHT;y++) {
    for (x=0;x<MAP_WIDTH;x++) {
      i=y*(MAP_WIDTH+1) + x;
      map[x][y]=src[i];
    }
  }

  Free(src);
}

Bool InsideMap(I64 x,I64 y)
{
  return 0 <= x && x < MAP_WIDTH &&
         0 <= y && y < MAP_HEIGHT;
}

U0 SetAntinodes(I64 ax,I64 ay,I64 freq)
{
  I64 x,y,anode_x,anode_y;
  for(y=0;y<MAP_HEIGHT;y++) {
    for (x=0;x<MAP_WIDTH;x++) {
      if (x!=ax && y!=ay && map[x][y]==freq) {
        anode_x=2*x - ax;
        anode_y=2*y - ay;
        if (InsideMap(anode_x, anode_y))
          map2[anode_x][anode_y]='#';
      }
    }
  }
}

U0 Part1()
{
  LoadMap;

  I64 x,y;
  for (y=0;y<MAP_HEIGHT;y++) {
    for (x=0;x<MAP_WIDTH;x++) {
      if (map[x][y]!='.') {
        SetAntinodes(x,y,map[x][y]);
      }
    }
  }

  I64 res=0;
  for (y=0;y<MAP_HEIGHT;y++) {
    for (x=0;x<MAP_WIDTH;x++) {
      if (map2[x][y]=='#')
        res+=1;
    }
  }

  "RESULT:%d\n",res;
}

U0 SetAntinodes2(I64 ax,I64 ay,I64 freq)
{
  I64 x,y,anode_x,anode_y,factor;
  for(y=0;y<MAP_HEIGHT;y++) {
    for (x=0;x<MAP_WIDTH;x++) {
      if (x!=ax && y!=ay && map[x][y]==freq) {
        anode_x=ax;
        anode_y=ay;
        factor=0;
        while (InsideMap(anode_x, anode_y)) {
          map2[anode_x][anode_y]='#';
          factor+=1;
          anode_x=ax+factor*(x-ax);
          anode_y=ay + factor*(y-ay);
        }
      }
    }
  }
}

U0 Part2()
{
  LoadMap;

  I64 x,y;
  for (y=0;y<MAP_HEIGHT;y++) {
    for (x=0;x<MAP_WIDTH;x++) {
      if (map[x][y]!='.') {
        SetAntinodes2(x,y,map[x][y]);
      }
    }
  }

  I64 res=0;
  for (y=0;y<MAP_HEIGHT;y++) {
    for (x=0;x<MAP_WIDTH;x++) {
      if (map2[x][y]=='#')
        res+=1;
    }
  }

  "RESULT:%d\n",res;
}

//Part1;
Part2;