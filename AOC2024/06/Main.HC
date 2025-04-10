Cd(__DIR__);

#define WIDTH  130
#define HEIGHT 130
#define FILE   "Input.TXT"
#define POSITIONS_CAP (WIDTH*HEIGHT*4)

class Vec2 {
  I64 x,y;
};

class Pos {
  Vec2 coord;
  Vec2 dir;
};

U8 map[WIDTH][HEIGHT];
U8 map2[WIDTH][HEIGHT];

I64 position_count=0;
Pos positions[POSITIONS_CAP];

U0 PushPos(Pos *p)
{
  #assert(position_count <POSITIONS_CAP)  
  positions[position_count].coord.x=p->coord.x;
  positions[position_count].coord.y=p->coord.y;
  positions[position_count].dir.x=p->dir.x;
  positions[position_count].dir.y=p->dir.y;
  position_count+=1;
}

Bool ContainsPos(Pos *p)
{
  I64 i;
  for (i=0;i<position_count;i++) {
    if (positions[i].coord.x==p->coord.x &&
        positions[i].coord.y==p->coord.y &&
        positions[i].dir.x==p->dir.x     &&
        positions[i].dir.y==p->dir.y)
      return TRUE;
  }

  return FALSE;
}

U0 LoadMap()
{
  I64 size;
  U8 *src=FileRead(FILE,&size);

  I64 x,y,i;
  for (y=0;y<HEIGHT;y++) {
    for (x=0;x<WIDTH;x++) {
      i=y*(WIDTH+1) + x;
      map[x][y]=src[i];
    }
  }

  Free(src);
}

U0 FindGuardPos(Vec2 *res)
{
  I64 x,y;
  for (y=0;y<HEIGHT;y++) {
    for (x=0;x<WIDTH;x++) {
      if (map[x][y]=='^') {
        res->x=x;
        res->y=y;
        return;
      }
    }
  }
}

Bool InsideMap(Vec2 *pos)
{
  return (0 <= pos->x && pos->x < WIDTH) &&
         (0 <= pos->y && pos->y < HEIGHT);
}

U0 Vec2Add(Vec2 *l,Vec2 *r,Vec2 *res)
{
  res->x=l->x + r->x;
  res->y=l->y + r->y;
}

U0 Vec2Rot90(Vec2 *v)
{
  if (v->x==0 && v->y==-1) {
    v->x=1;
    v->y=0;
  } else if (v->x==1 && v->y==0) {
    v->x=0;
    v->y=1;
  } else if (v->x==0 && v->y==1) {
    v->x=-1;
    v->y=0;
  } else if (v->x==-1 && v->y==0) {
    v->x=0;
    v->y=-1;
  }
}

I64 CountGuardPositions()
{
  I64 x,y,res=0;
  for (y=0;y<HEIGHT;y++) {
    for (x=0;x<WIDTH;x++) {
      if (map[x][y]=='X') {
        res+=1;
      }
    }
  }

  return res;
}

U0 DumpMap()
{
  I64 x,y;
  for (y=0;y<HEIGHT;y++) {
    for (x=0;x<WIDTH;x++) {
      "%c",map2[x][y];
    }
    "\n";
  }
}

U0 Part1()
{
  LoadMap;

  Vec2 pos;
  FindGuardPos(&pos);

  Vec2 dir;
  dir.x=0;
  dir.y=-1;

  Vec2 new_pos;
  while (InsideMap(&pos)) {
    map[pos.x][pos.y]='X';
    Vec2Add(&pos, &dir, &new_pos);
    if (map[new_pos.x][new_pos.y]=='#') {
      Vec2Rot90(&dir);
      Vec2Add(&pos, &dir, &pos);
    } else {
      pos.x=new_pos.x;
      pos.y=new_pos.y;
    }
  }

  "RESULT:%d\n",CountGuardPositions;
}

#define MAX_STEP_COUNT(WIDTH*HEIGHT*100)
Bool Simulate(I64 x,I64 y)
{
  Vec2 pos,dir,new_pos;
  dir.x=0;
  dir.y=-1;
  pos.x=x;
  pos.y=y;

  I64 i;
  for (i=0;i<MAX_STEP_COUNT;i++) {
    if (!InsideMap(&pos)) return FALSE;
    Vec2Add(&pos, &dir, &new_pos);
    if (map[new_pos.x][new_pos.y]=='#') {
      Vec2Rot90(&dir);
      Vec2Add(&pos, &dir, &new_pos);
    }
    pos.x=new_pos.x;
    pos.y=new_pos.y;   
  }

  return TRUE;
}

Bool Simulate2(I64 x,I64 y)
{
  Vec2 pos,dir,new_pos;
  dir.x=0;
  dir.y=-1;
  pos.x=x;
  pos.y=y;

  MemCpy(map2,map,sizeof(map));

  while (InsideMap(&pos)) {
    Vec2Add(&pos, &dir, &new_pos);
    if (!InsideMap(&new_pos)) break;
    if (map2[new_pos.x][new_pos.y]=='#') {
      if (map2[pos.x][pos.y]=='+')
        return TRUE;
      do {
        Vec2Rot90(&dir);
        Vec2Add(&pos, &dir, &new_pos);
        map2[pos.x][pos.y]='+';
      } while (map2[new_pos.x][new_pos.y]=='#');
    }

    pos.x=new_pos.x;
    pos.y=new_pos.y;   
  }

  return FALSE;
}

Bool Simulate3(I64 x,I64 y)
{
  Pos pos;
  pos.coord.x=x;
  pos.coord.y=y;
  pos.dir.x=0;
  pos.dir.y=-1;

  MemCpy(map2,map,sizeof(map));
  position_count=0;

  Vec2 new_pos;
  while (InsideMap(&pos.coord)) {
    if (ContainsPos(&pos))
      return TRUE;
    PushPos(&pos);

    Vec2Add(&pos.coord, &pos.dir, &new_pos);
    if (!InsideMap(&new_pos)) break;

    while (map2[new_pos.x][new_pos.y]=='#') {
      Vec2Rot90(&pos.dir);
      Vec2Add(&pos.coord, &pos.dir, &new_pos);
    }

    pos.coord.x=new_pos.x;
    pos.coord.y=new_pos.y;   
  }

  return FALSE;
}

U0 DrawMap(CDC*dc)
{
  I64 x,y;
  for (y=0;y<HEIGHT;y++) {
    for (x=0;x<WIDTH;x++) {
      if (map[x][y]=='#') {
        dc->color=RED;
      } else {
        dc->color=BLACK;
      }
      GrRect(dc,x*2,y*2,2,2);
    }
  }
}

U0 Part2()
{
  LoadMap;

  Vec2 guard_pos;
  FindGuardPos(&guard_pos);

  I64 res=0;
  Vec2 obs_pos;
  for (obs_pos.y=0;obs_pos.y<HEIGHT;obs_pos.y++) {
    for (obs_pos.x=0;obs_pos.x<WIDTH;obs_pos.x++) {
      DocClear;
      "%d.%d\n",obs_pos.y,obs_pos.x;
      if (map[obs_pos.x][obs_pos.y]=='.') {
        map[obs_pos.x][obs_pos.y]='#';
        res+=Simulate2(guard_pos.x,guard_pos.y);
        map[obs_pos.x][obs_pos.y]='.';
      }
    }
  }

  "RESULT:%d\n",res;
}




//Part1;
Part2;
