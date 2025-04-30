Cd(__DIR__);

#if 1
  #define FILE       "Input.TXT"
  #define MAP_WH     50
  #define MOVE_COUNT 20000
#else
  #define FILE       "Sample.TXT"
  #define MAP_WH     10
  #define MOVE_COUNT 700
#endif

class Vec2 {
  I64 x,y;
};

Vec2 moves[MOVE_COUNT];

U8 map[MAP_WH][MAP_WH];
U0 LoadMapAndRobotMoves()
{
  I64 x,y,i;
  U8 *src=FileRead(FILE);
  for (y=0;y<MAP_WH;y++) {
    for (x=0;x<MAP_WH;x++) {
      i=y*(MAP_WH+1) + x;
      map[x][y]=src[i];
    }
  }

  U8 *move=&src[i+3];
  for (i=0;i<MOVE_COUNT;i++) {
    if (*move=='\n') move++;

    if (*move=='<') moves[i].x=-1,moves[i].y=0;
    if (*move=='>') moves[i].x=1, moves[i].y=0;
    if (*move=='^') moves[i].x=0, moves[i].y=-1;
    if (*move=='v') moves[i].x=0, moves[i].y=1;

    move++;
  }

  Free(src);
}

U0 FindRobotPos(Vec2 *res)
{
  I64 x,y;
  for (y=0;y<MAP_WH;y++) {
    for (x=0;x<MAP_WH;x++) {
      if (map[x][y]=='@') {
        res->x=x;
        res->y=y;
        return;
      }
    }
  }
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

Bool TryMoveBoxes(Vec2 *p,Vec2 *dir)
{
  Vec2 v;
  v.x=p->x;
  v.y=p->y;

  do {
    v.x+=dir->x;
    v.y+=dir->y;
    if (map[v.x][v.y]=='#') return FALSE;
  } while (map[v.x][v.y]!='.');

  do {
    v.x-=dir->x;
    v.y-=dir->y;
    map[v.x+dir->x][v.y+dir->y]=map[v.x][v.y];
  } while (v.x!=p->x || v.y!=p->y);

  return TRUE;
}

I64 CalcGPSSum()
{
  I64 x,y,res=0;
  for (y=0;y<MAP_WH;y++) {
    for (x=0;x<MAP_WH;x++) {
      if (map[x][y]=='O') {
        res+=100*y + x;
      }
    }
  }
  return res;
}

U0 Part1()
{
  LoadMapAndRobotMoves;


  Vec2 r;
  FindRobotPos(&r);


  Vec2 n;
  I64 i;
  for (i=0;i<MOVE_COUNT;i++) {
    n.x=r.x+moves[i].x;
    n.y=r.y+moves[i].y;

    if (map[n.x][n.y]=='#') {}
    else if ((map[n.x][n.y]=='O' && TryMoveBoxes(&n,&moves[i])) ||
        (map[n.x][n.y]=='.')) {
      map[r.x][r.y]='.';
      r.x=n.x;
      r.y=n.y;
      map[r.x][r.y]='@';
    }
  }

  "RESULT: %d\n",CalcGPSSum;
}

#define MAP_WIDTH  (MAP_WH*2)
#define MAP_HEIGHT MAP_WH
U8 map2[MAP_WIDTH][MAP_HEIGHT];
U0 LoadMapAndRobotMoves2()
{
  I64 x,y,i;
  U8 *src=FileRead(FILE);
  for (y=0;y<MAP_HEIGHT;y++) {
    for (x=0;x<MAP_WIDTH;x+=2) {
      i=y*(MAP_HEIGHT+1) + x/2;
      if (src[i]=='#') {
        map2[x][y]='#';
        map2[x+1][y]='#';
      } else if (src[i]=='O') {
        map2[x][y]='[';
        map2[x+1][y]=']';
      } else if (src[i]=='.') {
        map2[x][y]='.';
        map2[x+1][y]='.';
      } else if (src[i]=='@') {
        map2[x][y]='@';
        map2[x+1][y]='.';
      }
    }
  }

  U8 *move=&src[i+3];
  for (i=0;i<MOVE_COUNT;i++) {
    if (*move=='\n') move++;

    if (*move=='<') moves[i].x=-1,moves[i].y=0;
    if (*move=='>') moves[i].x=1, moves[i].y=0;
    if (*move=='^') moves[i].x=0, moves[i].y=-1;
    if (*move=='v') moves[i].x=0, moves[i].y=1;

    move++;
  }

  Free(src);
}

Bool TryMoveBoxesHor(Vec2 *p,I64 dir)
{
  Vec2 v;
  v.x=p->x;
  v.y=p->y;

  do {
    v.x+=dir;
    if (map2[v.x][v.y]=='#') return FALSE;
  } while (map2[v.x][v.y]!='.');
$WW,1$
  do {
    v.x-=dir;
    map2[v.x+dir][v.y]=map2[v.x][v.y];
  } while (v.x!=p->x);

  return TRUE;
}

Bool MoveRobotHor(Vec2 *r,I64 dir)
{
  Vec2 n;
  n.x=r->x+dir;
  n.y=r->y;
  if (map2[n.x][n.y]=='#') return FALSE;
  if (map2[n.x][n.y]=='.') return TRUE;
  return TryMoveBoxesHor(&n,dir);
}

Bool TryMoveBoxesVer(Vec2 *p,I64 dir)
{
  Vec2 v;
  v.x=p->x;
  v.y=p->y+dir;

  if (map2[v.x][v.y]=='#')   return FALSE;
  if (map2[v.x+1][v.y]=='#') return FALSE;

  if (map2[v.x][v.y]=='[') {
    if (!TryMoveBoxesVer(&v,dir))
      return FALSE;
  } else {
    if (map2[v.x][v.y]==']') {
      v.x-=1;
      if (!TryMoveBoxesVer(&v,dir))
        return FALSE;
      v.x+=1;
    }
    if (map2[v.x+1][v.y]=='[') {
      v.x+=1;
      if (!TryMoveBoxesVer(&v,dir))
        return FALSE;
    }$WW,1$
  }

  map2[p->x][p->y+dir]=map2[p->x][p->y];
  map2[p->x][p->y]='.';
  map2[p->x+1][p->y+dir]=map2[p->x+1][p->y];
  map2[p->x+1][p->y]='.';

  return TRUE;
}

U8 map_copy[MAP_WIDTH][MAP_HEIGHT];
Bool MoveRobotVer(Vec2 *r,I64 dir)
{
  Vec2 n;
  n.x=r->x;
  n.y=r->y+dir;

  if (map2[n.x][n.y]=='#') return FALSE;
  if (map2[n.x][n.y]=='.') return TRUE;
  
  if (map2[n.x][n.y]==']') n.x-=1;

  MemCpy(map_copy,map2,sizeof(map2));
  if (!TryMoveBoxesVer(&n,dir)) {
    MemCpy(map2,map_copy,sizeof(map_copy));
    return FALSE;
  }

  return TRUE;
}

#define CELL_SIZE 5
CDC *dc=DCAlias;
U0 DrawMap()
{
  I64 x,y;
  for (y=0;y<MAP_HEIGHT;y++) {
    for (x=0;x<MAP_WIDTH;) {
      if (map2[x][y]=='[') {
        dc->color=GREEN;
        GrRect(dc,x*CELL_SIZE,y*CELL_SIZE,CELL_SIZE*2,CELL_SIZE);
        dc->color=LTGREEN;
        GrRect(dc,x*CELL_SIZE+1,y*CELL_SIZE+1,CELL_SIZE*2-2,CELL_SIZE-2);
        x+=2;
        goto continue;
      }

      if (map2[x][y]=='.') {
        dc->color=BLACK;
      } else if (map2[x][y]=='#') {
        dc->color=BLUE;
      } else if (map2[x][y]=='@') {
        dc->color=RED;
      }

      GrRect(dc,x*CELL_SIZE,y*CELL_SIZE,CELL_SIZE,CELL_SIZE);
      x+=1;

continue:
    }
  }
}

U0 DumpMap2()
{
  I64 x,y;
  for (y=0;y<MAP_HEIGHT;y++) {
    for (x=0;x<MAP_WIDTH;x++) {
      "%c",map2[x][y];
    }
    "\n";
  }
}

U0 FindRobotPos2(Vec2 *res)
{
  I64 x,y;
  for (y=0;y<MAP_HEIGHT;y++) {
    for (x=0;x<MAP_WIDTH;x++) {
      if (map2[x][y]=='@') {
        res->x=x;
        res->y=y;
        return;
      }
    }
  }
}

I64 CalcGPSSum2()
{
  I64 x,y,res=0;
  for (y=0;y<MAP_HEIGHT;y++) {
    for (x=0;x<MAP_WIDTH;x++) {
      if (map2[x][y]=='[') {
        res+=100*y + x;
      }
    }
  }
  return res;
}

U0 Part2()
{
  LoadMapAndRobotMoves2;

  Vec2 r;
  FindRobotPos2(&r);

  I64 i;
  for (i=0;i<MOVE_COUNT;i++) {
/*
    DCFill;
    DrawMap;
    GetChar;
*/

    if (moves[i].x!=0) {
      if (!MoveRobotHor(&r,moves[i].x))
        goto continue;
    } else {
      if (!MoveRobotVer(&r,moves[i].y))
        goto continue;
    }

    map2[r.x][r.y]='.';
    r.x+=moves[i].x;
    r.y+=moves[i].y;
    map2[r.x][r.y]='@';

continue:
  }

  "RESULT: %d\n",CalcGPSSum2;
}










//Part1;
Part2;
DCDel(dc);
