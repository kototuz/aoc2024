#if 1
  #define REG_A      41644071
  #define PROGRAM    "2,4,1,2,7,5,1,7,4,4,0,3,5,5,3,0"
  #define INST_COUNT 8
#else
  #define REG_A      729
  #define PROGRAM    "0,1,5,4,3,0"
  #define INST_COUNT 3
#endif

#define INST_ADV 0
#define INST_BXL 1
#define INST_BST 2
#define INST_JNZ 3
#define INST_BXC 4
#define INST_OUT 5
#define INST_BDV 6
#define INST_CDV 7

class Inst {
  I64  opcode;
  I64  operand;
};

class Computer {
  Inst insts[INST_COUNT];
  I64  reg_a;
  I64  reg_b;
  I64  reg_c;
  I64  ip;
};

U0 InitComputer(Computer *c)
{
  MemSet(c,0,sizeof(Computer));
  c->reg_a=REG_A;

  I64 i;
 U8 *p=PROGRAM;
  for (i=0;i<INST_COUNT;i++) {
    c->insts[i].opcode=*p-'0';
    p+=2;
    c->insts[i].operand=*p-'0';
    p+=2;
  }
}

I64 GetComboOperandValue(Computer *c,I64 operand)
{
  if (0<=operand && operand<=3) return operand;
  if (operand==4) return c->reg_a;
  if (operand==5) return c->reg_b;
  if (operand==6) return c->reg_c;
  throw;
}

U0 ExecCurrInst(Computer *c)
{
  Inst inst;
  MemCpy(&inst,&c->insts[c->ip],sizeof(inst));

  I64 a,b;
  switch (inst.opcode) {
  case INST_ADV:
    a=c->reg_a;
    b=Pow(2,GetComboOperandValue(c,inst.operand));
    c->reg_a=Trunc(a/b);
    c->ip+=1;
    break;

  case INST_BXL:
    c->reg_b^=inst.operand;
    c->ip+=1;
    break;

  case INST_BST:
    c->reg_b=GetComboOperandValue(c,inst.operand) % 8;
    c->ip+=1;
    break;

  case INST_JNZ:
    if (c->reg_a==0)
      c->ip+=1;
    else
      c->ip=inst.operand;
    break;

  case INST_BXC:
    c->reg_b^=c->reg_c;
    c->ip+=1;
    break;

  case INST_OUT:
    a=GetComboOperandValue(c,inst.operand) % 8;
    "%d,",a;
    c->ip+=1;
    break;

  case INST_BDV:
    a=c->reg_a;
    b=Pow(2,GetComboOperandValue(c,inst.operand));
    c->reg_b=Trunc(a/b);
    c->ip+=1;
    break;

  case INST_CDV:
    a=c->reg_a;
    b=Pow(2,GetComboOperandValue(c,inst.operand));
    c->reg_c=Trunc(a/b);
    c->ip+=1;
    break;
  }
}

U0 Main()
{
  Computer c;
  InitComputer(&c);
  while (c.ip!=INST_COUNT) {
    ExecCurrInst(&c);
  }
  "\n";
}

Main;
