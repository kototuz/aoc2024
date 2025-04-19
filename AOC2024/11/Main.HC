Cd(__DIR__);

#if 1
  #define FILE "Input.TXT"
#else
  #define FILE "Sample.TXT"
#endif

#define BLINK_COUNT 75
#define LIST_CAP    1024*300

I64 list[LIST_CAP];
I64 list_len=0;

U0 LoadList()
{
  I64 size;
  U8 *src=FileRead(FILE,&size);

  U8 *p=src;
  U8 *ep=&src[size-1];
  while (TRUE) {
    list[list_len++]=Str2I64(p,,&p);
    if (p>=ep) break;
    p+=1;
  }

  Free(src);
}

U0 DumpList()
{
  I64 i;
  for (i=0;i<list_len;i++) {
    "%d ",list[i];
  }
  "\n";
}

U0 ListInsert(I64 i,I64 n)
{
  if (list_len >= LIST_CAP) throw;

  I64 j;
  for (j=list_len-1;j>=i;j--) {
    list[j+1]=list[j];
  }

  list[i]=n;

  list_len+=1;
}

I64 Str2I64WithLen(U8 *s,I64 len)
{
  I64 i,res=0;
  for (i=0;i<len;i++) {
    res=res*10 + (s[i]-'0');
  }
  return res;
}

Bool TrySplit(I64 n_idx)
{
  U8 split_buf[20];
  MemSet(split_buf,0,sizeof(split_buf));

  I64 n=list[n_idx];
  StrPrint(split_buf,"%d",n);
  I64 digit_count=StrLen(split_buf);

  I64 len;
  if (digit_count%2 == 0) {
    len=digit_count/2;
    list[n_idx]=Str2I64WithLen(&split_buf[len],len);
    ListInsert(n_idx,Str2I64WithLen(split_buf,len));
    return TRUE;
  }

  return FALSE;
}

U0 Part1()
{
  LoadList;

  I64 i,j;
  for (i=0;i<BLINK_COUNT;i++) {
    for (j=0;j<list_len;) {
      if (list[j]==0) {
        list[j]=1;
        j+=1;
      } else if (TrySplit(j)) {
        j+=2;
      } else {
        list[j]*=2024;
        j+=1;
      }
    }
  }

  "RESULT: %d\n",list_len;
}

// PART2 /////////////////

class Entry {
  I64 stone;
  I64 blink_cnt;
  I64 val;
};

#define ENTRIES_CAP (1024*300)
Entry entries[ENTRIES_CAP];
I64 entry_count=0;

U0 PushEntry(I64 stone,I64 blink_cnt,I64 val)
{
  if (entry_count >= ENTRIES_CAP) throw;
  entries[entry_count].stone=stone;
  entries[entry_count].blink_cnt=blink_cnt;
  entries[entry_count].val=val;
  entry_count+=1;
}

I64 GetValue(I64 stone,I64 blink_cnt)
{
  I64 i;
  for (i=0;i<entry_count;i++) {
    if (entries[i].stone==stone && entries[i].blink_cnt==blink_cnt)
      return entries[i].val;
  }
  return -1;
}

Bool TrySplit2(I64 stone,I64 *res_l,I64 *res_r)
{
  U8 split_buf[20];
  MemSet(split_buf,0,sizeof(split_buf));

  StrPrint(split_buf,"%d",stone);
  I64 digit_count=StrLen(split_buf);

  I64 len;
  if (digit_count%2 == 0) {
    len=digit_count/2;
    *res_l=Str2I64WithLen(split_buf,len);
    *res_r=Str2I64WithLen(&split_buf[len],len);
    return TRUE;
  }

  return FALSE;
}

I64 Compute(I64 stone,I64 blink_cnt)
{
  if (blink_cnt == 0) return 1;

  I64 cnt=GetValue(stone,blink_cnt);
  if (cnt>-1) return cnt;

  I64 l,r;
  if (stone == 0) {
    cnt=Compute(1,blink_cnt-1);
  } else if (TrySplit2(stone,&l,&r)) {
    cnt=Compute(l,blink_cnt-1) + Compute(r,blink_cnt-1);
  } else {
    cnt=Compute(stone*2024,blink_cnt-1);
  }

  PushEntry(stone,blink_cnt,cnt);
  return cnt;
}

U0 Part2()
{
  LoadList;

  I64 i,res=0;
  for (i=0;i<list_len;i++) {
    res+=Compute(list[i],BLINK_COUNT);
  }

  "RESULT: %d\n",res;
}

//Part1;
Part2;
