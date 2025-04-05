Cd(__DIR__);

#define LIST_CAP 1000

I64 list1[LIST_CAP];
I64 list2[LIST_CAP];

U0 LoadLists()
{
  I64 size;
  U8 *src=FileRead("Input.TXT",&size);
  
  U8 *currp=src;
  U8 *endp;
  I64 i;
  for (i=0;i<LIST_CAP;i++) {
    list1[i]=Str2I64(currp,,&endp);
    currp=endp+1;
    list2[i]=Str2I64(currp,,&endp);
    currp=endp+1;
  }
  
  Free(src);
}

U0 Part1()
{
  LoadLists;

  I64 i,j;
  I64 result=0;
  I64 list1_min;
  I64 list2_min;
  I64 list1_min_i,list2_min_i;
  for (j=0;j<LIST_CAP;j++) {
    list1_min=I64_MAX;
    list2_min=I64_MAX;
    list1_min_i=0;
    list2_min_i=0;
    for (i=0;i<LIST_CAP;i++) {
      if (list1[i]<list1_min) {
        list1_min=list1[i];
        list1_min_i=i;
      }

      if (list2[i]<list2_min) {
        list2_min=list2[i];
        list2_min_i=i;
      }
    }
    
    result+=AbsI64(list1_min-list2_min);

    list1[list1_min_i]=I64_MAX;
    list2[list2_min_i]=I64_MAX;
  }

  "RESULT: %d\n",result;
}

U0 Part2()
{
  LoadLists;

  I64 i,j,appear_count,result=0;
  for (i=0;i<LIST_CAP;i++) {
    appear_count=0;
    for (j=0;j<LIST_CAP;j++)
      if (list2[j]==list1[i])
        appear_count+=1;
    result+=list1[i]*appear_count;
  }

  "RESULT: %d\n",result;
}

//Part1;
Part2;
