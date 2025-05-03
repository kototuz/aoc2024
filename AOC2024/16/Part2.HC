Cd(__DIR__);

#if 1
  #define FILE   "Input.TXT"
  #define MAP_WH 141
#else
  #define FILE   "Sample2.TXT"
  #define MAP_WH 17
#endif

#define REINDEERS_CAP       4096
#define MAX_CHECKP_COUNT    1024
#define MAX_PATH_LINE_COUNT 1024

class Vec2 {
  I64 x,y;
};

class Checkp {
  Vec2 pos;
  Vec2 in;
  Vec2 out;
  I64  score;
};

class PathLine {
  Vec2 a,b;
};

class Checkps {
  Checkp items[MAX_CHECKP_COUNT];
  I64    count;
};

class Reindeer {
  Vec2    pos;
  Vec2    dir;
  I64     score;
  Checkps checkps;
};

Reindeer reindeers[REINDEERS_CAP];
I64      reindeer_count=0;
U8       map[MAP_WH][MAP_WH];
U8       map_copy[MAP_WH][MAP_WH];
Checkps  g_checkps; MemSet(&g_checkps,0,sizeof(Checkps));
PathLine path_lines[MAX_PATH_LINE_COUNT];
I64      path_line_count=0;

U0 LoadMap(Vec2 *pos)
{
  I64 x,y,i;
  U8 *src=FileRead(FILE);
  for (y=0;y<MAP_WH;y++) {
    for (x=0;x<MAP_WH;x++) {
      i=y*(MAP_WH+1) + x;
      map[x][y]=src[i];
      if (src[i]=='S') {
        map[x][y]='.';
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
    MemCpy(&reindeers[i],&reindeers[i+1],sizeof(Reindeer)*reindeer_count-i);
  }
  reindeer_count-=1;
}

Bool CanMove(Reindeer *r)
{
  return map[r->pos.x+r->dir.x][r->pos.y+r->dir.y] != '#' &&
         map[r->pos.x+r->dir.x][r->pos.y+r->dir.y] != '*';
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

U0 PushCheckp(Checkps *xs,Checkp *x)
{
  if (xs->count>=MAX_CHECKP_COUNT) throw;
  MemCpy(&xs->items[xs->count++],x,sizeof(Checkp));
}

U0 PushCheckps(Checkps *dst,Checkps *src)
{
  if (dst->count+src->count > MAX_CHECKP_COUNT) throw;
  MemCpy(&dst->items[dst->count],&src->items[0],src->count*sizeof(Checkp));
  dst->count+=src->count;
}

U0 PushPathLine(Vec2 *a,Vec2 *b)
{
  if (path_line_count>=MAX_PATH_LINE_COUNT) throw;
  MemCpy(&path_lines[path_line_count].a,a,sizeof(Vec2));
  MemCpy(&path_lines[path_line_count].b,b,sizeof(Vec2));
  path_line_count+=1;
}

U0 ExtractPathLinesFromCheckps(Checkps *c)
{
  I64 i;
  for (i=0;i<c->count-1;i++) {
    PushPathLine(&c->items[i].pos,&c->items[i+1].pos);
  }
}

Bool Vec2Eq(Vec2 *a,Vec2 *b)
{
  return a->x==b->x && a->y==b->y;
}

U0 TrySpawnReindeers(Reindeer *r)
{
  Reindeer new;
  MemCpy(&new,r,sizeof(Reindeer));
  new.score+=1000;

  Checkp cp;
  cp.score=r->score;
  MemCpy(&cp.in,&new.dir,sizeof(Vec2));
  MemCpy(&cp.pos,&new.pos,sizeof(Vec2));

  PushCheckp(&new.checkps,&cp);
  if (r->dir.x==0) {
    new.dir.x=1;
    new.dir.y=0;
    if (CanMove(&new)) {
      MemCpy(&cp.out,&cp.in,sizeof(Vec2));
      PushCheckp(&r->checkps,&cp);
      MemCpy(&cp.out,&new.dir,sizeof(Vec2));
      cp.score+=1000;
      MemCpy(&new.checkps.items[new.checkps.count-1],&cp,sizeof(Checkp));
      cp.score-=1000;
      PushReindeer(&new);
    }

    new.dir.x=-1;
    if (CanMove(&new)) {
      MemCpy(&cp.out,&cp.in,sizeof(Vec2));
      PushCheckp(&r->checkps,&cp);
      MemCpy(&cp.out,&new.dir,sizeof(Vec2));
      cp.score+=1000;
      MemCpy(&new.checkps.items[new.checkps.count-1],&cp,sizeof(Checkp));
      cp.score-=1000;
      PushReindeer(&new);
    }
  } else {
    new.dir.x=0;
    new.dir.y=1;
    if (CanMove(&new)) {
      MemCpy(&cp.out,&cp.in,sizeof(Vec2));
      PushCheckp(&r->checkps,&cp);
      MemCpy(&cp.out,&new.dir,sizeof(Vec2));
      cp.score+=1000;
      MemCpy(&new.checkps.items[new.checkps.count-1],&cp,sizeof(Checkp));
      cp.score-=1000;
      PushReindeer(&new);
    }

    new.dir.y=-1;
    if (CanMove(&new)) {
      MemCpy(&cp.out,&cp.in,sizeof(Vec2));
      PushCheckp(&r->checkps,&cp);
      MemCpy(&cp.out,&new.dir,sizeof(Vec2));
      cp.score+=1000;
      MemCpy(&new.checkps.items[new.checkps.count-1],&cp,sizeof(Checkp));
      cp.score-=1000;
      PushReindeer(&new);
    }
  }
}

Checkp *FindCheckp(Vec2 *pos)
{
  I64 i;
  for (i=0;i<g_checkps.count;i++) {
    if (Vec2Eq(&g_checkps.items[i].pos,pos))
      return &g_checkps.items[i];
  }
  return NULL;
}

Bool FindPath(Vec2 *begin,Vec2 *dir,I64 score=0)
{
  reindeer_count=0;
  Reindeer first;
  MemSet(&first,0,sizeof(Reindeer));
  MemCpy(&first.pos,begin,sizeof(Vec2));
  MemCpy(&first.dir,dir,sizeof(Vec2));
  first.score=score;
  PushReindeer(&first);

  I64 i;
  Checkp cp;
  Checkp *c;
  Reindeer *it;
  while (reindeer_count > 0) {
    DrawMap;
    Sleep(3);
    DCFill;

    i=reindeer_count;
    while (i>0) {
      it=&reindeers[0];
      while (TRUE) {
        map[it->pos.x][it->pos.y]='*';
        TrySpawnReindeers(it);
        if (!CanMove(it)) break;
        it->pos.x+=it->dir.x;
        it->pos.y+=it->dir.y;
        it->score+=1;
        if (map[it->pos.x][it->pos.y]=='E') {
          MemCpy(&cp.pos,&it->pos,sizeof(Vec2));
          MemCpy(&cp.in,&it->dir,sizeof(Vec2));
          MemCpy(&cp.out,&it->dir,sizeof(Vec2));
          cp.score=it->score;
          PushCheckp(&it->checkps,&cp);
          PushCheckps(&g_checkps,&it->checkps);
          ExtractPathLinesFromCheckps(&it->checkps);
          return TRUE;
        }

        c=FindCheckp(&it->pos);
        if (c!=NULL) {
          if (!Vec2Eq(&it->dir,&c->out))
            it->score+=1000;
          if (it->score!=c->score) break;
          PushCheckps(&g_checkps,&it->checkps);
          ExtractPathLinesFromCheckps(&it->checkps);
          PushPathLine(begin,&it->checkps.items[0].pos);
          PushPathLine(&it->checkps.items[it->checkps.count-1].pos,&c->pos);
          return TRUE;
        }
      }
      i-=1;
      RemoveReindeer(0);
    }
  }

  return FALSE;
}

U0 DetermineDir(Vec2 *a,Vec2 *b,Vec2 *res)
{
  res->x=0;
  res->y=0;

  I64 x=a->x - b->x;
  I64 y=a->y - b->y;
  if (x==0 && y==0) return;

  if (x==0) {
    res->x=0;
    res->y=(y/AbsI64(y)) * -1;
  } else {
    res->y=0;
    res->x=(x/AbsI64(x)) * -1;
  }
}

Bool HasWalls(Vec2 *begin,Vec2 *fin,Vec2 *s)
{
  Vec2 pos;
  MemCpy(&pos,begin,sizeof(Vec2));
  while (!Vec2Eq(&pos,fin)) {
    if (map[pos.x][pos.y]=='#')
      return TRUE;
    pos.x+=s->x;
    pos.y+=s->y;
  }
  return FALSE;
}

U0 RebuildPath()
{
  MemCpy(map,map_copy,sizeof(map));

  I64 i;
  Vec2 pos,dir;
  for (i=0;i<path_line_count;i++) {
    MemCpy(&pos,&path_lines[i].a,sizeof(Vec2));
    DetermineDir(&path_lines[i].a,&path_lines[i].b,&dir);
    while (!Vec2Eq(&pos,&path_lines[i].b)) {
      map[pos.x][pos.y]='O';
      pos.x+=dir.x;
      pos.y+=dir.y;
    }
    map[pos.x][pos.y]='O';
  }
}

$UL,0$$UL,1$$UL,0$Vec2 directions[4]={{1,0},{-1,0},{0,1},{0,-1}};
Bool FindPathBeginFromCheckp(Checkp *c,Vec2 *pos,Vec2 *dir,I64 *score)
{
  I64 i,x,y;
  for (i=0;i<4;i++) {
    x=c->pos.x+directions[i].x;
    y=c->pos.y+directions[i].y;
    if (map[x][y]=='.') {
      pos->x=x;
      pos->y=y;
      dir->x=directions[i].x;
      dir->y=directions[i].y;
      *score=c->score+1;
      if (Vec2Eq(dir,&c->in))
       *score-=1000;
      else if (Vec2Eq(&c->in,&c->out))
       *score+=1000;
      return TRUE;
    }
  }

  return FALSE;
}

U0 Main()
{
  Vec2 pos;
  LoadMap(&pos);
  MemCpy(map_copy,map,sizeof(map));

  Vec2 dir;
  dir.x=1;
  dir.y=0;

  FindPath(&pos,&dir);
  RebuildPath;
  DrawMap;
  GetChar;
  DCFill;

  I64 i,s;
  Checkp *it;
  for (i=0;i<g_checkps.count;i++) {
    it=&g_checkps.items[i];
    "pos:   %d,%d\n",it->pos.x,it->pos.y;
    "in:    %d,%d\n",it->in.x,it->in.y;
    "out:   %d,%d\n",it->out.x,it->out.y;
    "score: %d\n",it->score;
    if (FindPathBeginFromCheckp(it,&pos,&dir,&s)) {
      "New path:\n";
      "  pos:   %d,%d\n",pos.x,pos.y;
      "  dir:   %d,%d\n",dir.x,dir.y;
      "  score: %d\n",s;
      FindPath(&pos,&dir,s);
      RebuildPath;
    }

    "============\n";
  }

  I64 x,y,res=0;
  for (y=0;y<MAP_WH;y++) {
    for (x=0;x<MAP_WH;x++) {
      if (map[x][y]=='O')
        res+=1;
    }
  }

  DrawMap;
  GetChar;
  DCFill;

  "RESULT: %d\n",res;
}


Main;
DCDel(dc);
