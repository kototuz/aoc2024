Cd(__DIR__);

#define WIDTH  140
#define HEIGHT 140

#define WORD_LEN 3
U8 *word="MAS";
U8 word_search[WIDTH][HEIGHT];

U0 LoadWordSearch()
{
  I64 size;
  U8 *src=FileRead("Input.TXT",&size);

  I64 i,x=0,y=0;
  for (i=0;i<size;i++) {
    if (src[i]=='\n') {
      y+=1;
      x=0;
      goto continue;
    }
    
    word_search[x][y]=src[i];

    x+=1;

continue:
  }

  Free(src);
}

Bool CheckWithDir(I64 x,I64 y,I64 dx,I64 dy)
{
  I64 i;
  for (i=0;i<WORD_LEN;i++) {
    if (word_search[x][y]!=word[i]) return FALSE;
    x+=dx;y+=dy;
  }

  return TRUE;
}

U0 Part1()
{
  LoadWordSearch();
  
  I64 x,y,res=0;
  for (y=0;y<HEIGHT;y++) {
    for (x=0;x<WIDTH;x++) {
      if (x<=WIDTH-WORD_LEN && CheckWithDir(x,y,1,0))
        res+=1;
      if (x>=WORD_LEN-1 && CheckWithDir(x,y,-1,0))
        res+=1;

      if (y<=HEIGHT-WORD_LEN && CheckWithDir(x,y,0,1))
        res+=1;
      if (y>=WORD_LEN-1 && CheckWithDir(x,y,0,-1))
        res+=1;
      
      if (x<=WIDTH-WORD_LEN && y<=WIDTH-WORD_LEN && CheckWithDir(x,y,1,1))
        res+=1;
      if (x<=WIDTH-WORD_LEN && y>=WORD_LEN-1 && CheckWithDir(x,y,1,-1))
        res+=1;
      
      if (x>=WORD_LEN-1 && y<=WIDTH-WORD_LEN && CheckWithDir(x,y,-1,1))
        res+=1;
      if (x>=WORD_LEN-1 && y>=WORD_LEN-1 && CheckWithDir(x,y,-1,-1))
        res+=1;
    }
  }

  "RESULT: %d\n",res;
}

U0 Part2()
{
  LoadWordSearch();

  I64 x,y,res=0;
  for (y=0;y<HEIGHT-2;y++)
    for (x=0;x<WIDTH-2;x++)
      if ((CheckWithDir(x,y,1,1) || CheckWithDir(x+2,y+2,-1,-1)) &&
          (CheckWithDir(x+2,y,-1,1) || CheckWithDir(x,y+2,1,-1)))
          res+=1;

  "RESULT: %d\n",res;
}

//Part1;
Part2;
