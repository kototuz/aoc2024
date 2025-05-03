Cd(__DIR__);

#if 1
  #define FILE   "Input.TXT"
  #define MAP_WH 141
#else
  #define FILE   "Sample.TXT"
  #define MAP_WH 15
#endif

#define REINDEERS_CAP    4096
#define MAX_CHECKP_COUNT 1024

class Vec2 {
  I64 x,y;
};

class Reindeer {
  Vec2 pos;
  Vec2 dir;
  I64  score;
};

Reindeer reindeers[REINDEERS_CAP];
I64      reindeer_count=0;
U8       map[MAP_WH][MAP_WH];

U0 LoadMap(Vec2 *pos)
{
  I64 x,y,i;
  U8 *src=FileRead(FILE);
  for (y=0;y<MAP_WH;y++) {
    for (x=0;x<MAP_WH;x++) {
      i=y*(MAP_WH+1) + x;
      map[x][y]=src[i];
      if (src[i]=='S') {
        pos->x=x;
        pos->y=y;
      }
    }
  }

  Free(src);
}

U0 PushReindeer(Reindeer *r)
{
  if (reindeer_count>=REINDEERS_CAP) throw;
  MemCpy(&reindeers[reindeer_count++],r,sizeof(Reindeer));
}

U0 RemoveReindeer(I64 i)
{
  if (i<0 || i>=reindeer_count) throw;
  if (i<reindeer_count-1) {
    MemCpy(&reindeers[i],&reindeers[i+1],sizeof(Reindeer)*reindeer_count-i);
  }
  reindeer_count-=1;
}

Bool CanMove(Reindeer *r)
{
  return (map[r->pos.x+r->dir.x][r->pos.y+r->dir.y] != '#') &&
         (map[r->pos.x+r->dir.x][r->pos.y+r->dir.y] != '*');
}

U0 TrySpawnReindeers(Reindeer *r)
{
  Reindeer new;
  MemCpy(&new,r,sizeof(Reindeer));
  new.score+=1000;

  if (r->dir.x==0) {
    new.dir.x=1;
    new.dir.y=0;
    if (CanMove(&new))
      PushReindeer(&new);

    new.dir.x=-1;
    if (CanMove(&new))
      PushReindeer(&new);
  } else {
    new.dir.x=0;
    new.dir.y=1;
    if (CanMove(&new))
      PushReindeer(&new);

    new.dir.y=-1;
    if (CanMove(&new))
      PushReindeer(&new);
  }
}

#define CELL_SIZE 3
CDC *dc=DCAlias;
U0 DrawMap()
{
  I64 x,y;
  for (y=0;y<MAP_WH;y++) {
    for (x=0;x<MAP_WH;x++) {
      if (map[x][y]=='#')
        dc->color=BLUE;
      else if (map[x][y]=='*')
        dc->color=GREEN;
      else if (map[x][y]=='E')
        dc->color=RED;
      else if (map[x][y]=='O')
        dc->color=PURPLE;
      else
        dc->color=BLACK;
      GrRect(dc,x*CELL_SIZE,y*CELL_SIZE,CELL_SIZE,CELL_SIZE);
    }
  }

  GrPrint(dc,0,y*CELL_SIZE,"Reindeer count: %d",reindeer_count);
}

U0 Main()
{
  Reindeer first;
  first.dir.x=1;
  first.dir.y=0;
  first.score=0;

  LoadMap(&first.pos);
  first.pos.x-=1;

  PushReindeer(&first);

  I64 count,i;
  Reindeer *it;
  while (reindeer_count>0) {
    //DocClear;
    //DrawMap;
    //GetChar;
    //DCFill;


    count=reindeer_count;
    for (i=0;i<count;) {
      it=&reindeers[i];
      while (CanMove(it)) {
        it->pos.x+=it->dir.x;
        it->pos.y+=it->dir.y;
        if (map[it->pos.x][it->pos.y]=='E') {
          "RESULT: %d\n",it->score;
          return;
        }
        it->score+=1;
        map[it->pos.x][it->pos.y]='*';
        TrySpawnReindeers(it);
      }

      count-=1;
      RemoveReindeer(i);
    }
  }
}

Main;
DCDel(dc);
