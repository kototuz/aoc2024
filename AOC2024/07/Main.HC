Cd(__DIR__);

#define EQUATION_COUNT 850
#define FILE           "Input.TXT"
#define MAX_NUM_COUNT  64

class Equation {
  I64 test_val;
  I64 nums[MAX_NUM_COUNT];
  I64 len;
};

Equation equations[EQUATION_COUNT];

U0 LoadEquations()
{
  U8 *src=FileRead(FILE);

  U8 *p=src;
  I64 i,len;
  for (i=0;i<EQUATION_COUNT;i++) {
    equations[i].test_val=Str2I64(p,,&p);

    p+=1;
    len=0;
    while (*p!='\n') {
      p+=1;
      equations[i].nums[len++]=Str2I64(p,,&p);
    }

    equations[i].len=len;
    p+=1;
  }

  Free(src);
}

U0 Part1()
{
  LoadEquations;

  Equation *e;
  I64 i,j,sum,signs,res=0;
  for (i=0;i<EQUATION_COUNT;i++) {
    e=&equations[i];
    for (signs=0;signs<=U64_MAX>>(65-e->len);signs++) {
      sum=e->nums[0];
      for (j=1;j<e->len;j++) {
        if (signs&(1<<(j-1)) >0) {
          sum*=e->nums[j];
        } else {
          sum+=e->nums[j];
        }
      }
      if (sum==e->test_val) {
        res+=sum;
        break;
      }
    }
  }

  "RESULT:%d\n",res;
}

I64 MaxValue(I64 digit_count)
{
  I64 i,res=0;
  for (i=0;i<digit_count;i++) {
    res=res*3 +2;
  }
  return res;
}

#define OP_PLUS   0
#define OP_MUL    1
#define OP_CONCAT 2
U8 operands[MAX_NUM_COUNT-1];
U0 SetOperands(I64 num)
{
  I64 remainder,i=0;
  while (num != 0) {
    remainder=num%3;
    operands[i++]=remainder;
    num=(num-remainder)/3;
  }
}

#define MAX_DIGIT_COUNT 64
U8 concat_buf[MAX_DIGIT_COUNT];
I64 Concat(I64 l,I64 r)
{
  MemSet(concat_buf,0x0,sizeof(concat_buf));
  CatPrint(concat_buf, "%d%d",l,r);
  return Str2I64(concat_buf);
}

U0 Part2()
{
  LoadEquations;
  Equation *e;
  I64 i,j,sum,max,num,res=0;
  for (i=0;i<EQUATION_COUNT;i++) {
    e=&equations[i];
    max=MaxValue(e->len);
    for (num=0;num<max;num++) {
      sum=e->nums[0];
      SetOperands(num);
      for (j=1;j<e->len;j++) {
        if (operands[j-1]==OP_PLUS)
          sum+=e->nums[j];
        else if (operands[j-1]==OP_MUL)
          sum*=e->nums[j];
        else
          sum=Concat(sum,e->nums[j]);
      }
      if (sum==e->test_val) {
        res+=sum;
        break;
      }
    }
  }

  "RESULT:%d\n",res;
}


//Part1;
Part2;