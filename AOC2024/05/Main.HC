Cd(__DIR__);

#define SAMPLE_RULE_COUNT     21
#define SAMPLE_UPDATE_COUNT   6
#define SAMPLE_MAX_UPDATE_LEN 5

#define INPUT_RULE_COUNT     1176
#define INPUT_UPDATE_COUNT   199
#define INPUT_MAX_UPDATE_LEN 23

#define RULE_COUNT     INPUT_RULE_COUNT
#define UPDATE_COUNT   INPUT_UPDATE_COUNT
#define MAX_UPDATE_LEN INPUT_MAX_UPDATE_LEN
#define FILE           "Input.TXT"

class Rule {
  I64 l,r;
};

class Update {
 I64 items[MAX_UPDATE_LEN];
 I64 len;
};

Rule rules[RULE_COUNT];
Update updates[UPDATE_COUNT];

U0 LoadRulesAndUpdates()
{
  I64 size;
  U8 *src=FileRead(FILE,&size);

  U8 *p=src;
  I64 i;
  for (i=0;i<RULE_COUNT;i++) {
    rules[i].l=Str2I64(p,,&p);
    rules[i].r=Str2I64(p+1,,&p);
    p+=1;
  }
  
  I64 len;
  for (i=0;i<UPDATE_COUNT;i++) {
    len=0;
    do {
      p+=1;
      updates[i].items[len++]=Str2I64(p,,&p);
    } while (*p!='\n');
    updates[i].len=len;
  }

  Free(src);
}

Bool CheckOrder(Update *u)
{
  I64 i,j,ri;
  for (i=0;i<u->len;i++) {
    for (ri=0;ri<RULE_COUNT;ri++) {
      if (rules[ri].l==u->items[i]) {
        for (j=i-1;j>=0;j--) {
          if (u->items[j]==rules[ri].r)
            return FALSE;
        }
      }
    }
  }

  return TRUE;
}

U0 Part1()
{
  LoadRulesAndUpdates;

  I64 i,res=0;
  for (i=0;i<UPDATE_COUNT;i++) {
    Update *u=&updates[i];
    if (CheckOrder(u)) {
      res+=u->items[(u->len-1)/2];
    }
  }

  "RESULT: %d\n",res;
}

Bool OrderUpdate(Update *u)
{
  Bool ordered=FALSE;
  I64 i,j,ri;

again:
  for (i=0;i<u->len;i++) {
    for (ri=0;ri<RULE_COUNT;ri++) {
      if (rules[ri].l==u->items[i]) {
        for (j=i-1;j>=0;j--) {
          if (u->items[j]==rules[ri].r) {
            SwapI64(&u->items[j],&u->items[i]);
            ordered=TRUE;
            goto again;
          }
        }
      }
    }
  }

  return ordered;
}

U0 DumpUpdate(Update *u)
{
  I64 i;
  for (i=0;i<u->len;i++) {
    "%d ",u->items[i];
  }
  "\n";
}

U0 Part2()
{
  LoadRulesAndUpdates;

  I64 i,res=0;
  for (i=0;i<UPDATE_COUNT;i++) {
    Update *u=&updates[i];
    if (OrderUpdate(u)) {
      res+=u->items[(u->len)/2];
    }
  }

  "RESULT: %d\n",res;
}






//Part1;
Part2;




