Cd(__DIR__);

U0 Part1()
{
  I64 size;
  U8 *src=FileRead("Input.TXT",&size);

  U8 *endp,*p; 
  I64 i,a,b,res=0;
  for (i=0;i<size-3;i++) {
    if (StrNCmp(&src[i],"mul(",4)!=0)
      goto continue;

    a=Str2I64(&src[i+4],,&endp);
    if (endp==&src[i+4])
      goto continue;

    if (*endp!=',')
      goto continue;

    p=endp+1;
    b=Str2I64(p,,&endp);
    if (endp==p)
      goto continue;

    if (*endp!=')')
      goto continue;

    res+=a*b;

continue:
  }

  "RESULT: %d\n",res;

  Free(src);
}

U0 Part2()
{
  I64 size;
  U8 *src=FileRead("Input.TXT",&size);

  Bool inst_enabled=TRUE;
  U8 *endp,*p; 
  I64 i,a,b,res=0;
  for (i=0;i<size-6;i++) {
    if (StrNCmp(&src[i],"do()",4)==0) {
      inst_enabled=TRUE;
      goto continue;
    }

    if (StrNCmp(&src[i],"don't()",7)==0) {
      inst_enabled=FALSE;
      goto continue;
    }

    if (!inst_enabled)
      goto continue;    

    if (StrNCmp(&src[i],"mul(",4)!=0)
      goto continue;

    a=Str2I64(&src[i+4],,&endp);
    if (endp==&src[i+4])
      goto continue;

    if (*endp!=',')
      goto continue;

    p=endp+1;
    b=Str2I64(p,,&endp);
    if (endp==p)
      goto continue;

    if (*endp!=')')
      goto continue;

    res+=a*b;

continue:
  }

  "RESULT: %d\n",res;

  Free(src);
}

//Part1;
Part2;
