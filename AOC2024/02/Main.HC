Cd(__DIR__);

#define REPORT_COUNT  1000
#define MAX_LVL_COUNT 8

class Report {
  I64 lvls[MAX_LVL_COUNT];
  I64 len;
};

Report reports[REPORT_COUNT];

U0 LoadReports()
{
  I64 size;
  U8 *src=FileRead("Input.TXT",&size);

  U8 *endp, *currp=src;
  I64 i, len;
  for (i=0;i<REPORT_COUNT;i++) {
    len=0;
    do {
      reports[i].lvls[len++]=Str2I64(currp,,&endp);
      currp=endp+1;
    } while (*endp!='\n');
    reports[i].len=len;
  }

  Free(src);
}

U0 Part1()
{
  LoadReports();
  
  I64 i,j,*lvls,len,result=0;
  for (i=0;i<REPORT_COUNT;i++) {
    lvls=reports[i].lvls;
    len=reports[i].len;

    if (lvls[0]>lvls[1]) {
      for (j=0;j<len-1;j++) {
        if (lvls[j]<=lvls[j+1]) goto continue;
        if (lvls[j]-lvls[j+1]>3) goto continue;
      }
      result+=1;        
    } else {
      for (j=0;j<len-1;j++) {
        if (lvls[j]>=lvls[j+1]) goto continue;
        if (lvls[j+1]-lvls[j]>3) goto continue;
      }
      result+=1;        
    }

continue:
  }

  "RESULT: %d\n",result;
}

// PART 2

U0 RemoveLvl(Report *r,I64 i)
{
  if (i<r->len-1)
    MemCpy(&r->lvls[i],&r->lvls[i+1],(r->len-i-1)*sizeof(I64));
  r->len-=1;
}

Bool CheckLvlsInc(I64 l,I64 r)
{
  return l<r && r-l<=3;
}

Bool CheckLvlsDec(I64 l,I64 r)
{
  return l>r && l-r<=3;
}

Bool IsSafe(Report *r)
{
  Bool (*check_lvls)(I64,I64);
  if (r->lvls[0]>r->lvls[1])
    check_lvls=&CheckLvlsDec;
  else
    check_lvls=&CheckLvlsInc;
  
  I64 i;
  for (i=0;i<r->len-1;i++) {
    if (!check_lvls(r->lvls[i],r->lvls[i+1]))
      return FALSE;
  }

  return TRUE;
}

U0 Part2()
{
  LoadReports();
  
  Report copy;
  I64 i,j,result=0;
  for (i=0;i<REPORT_COUNT;i++) {
    if (IsSafe(&reports[i])) {
      result+=1;
      goto continue;
    }
    
    for (j=0;j<reports[i].len;j++) {
      MemCpy(&copy,&reports[i],sizeof(Report));
      RemoveLvl(&copy,j);
      if (IsSafe(&copy)) {
        result+=1;
        goto continue;
      }
    }

    continue:
  }

  "RESULT: %d\n",result;
}

//Part1
Part2;
