Cd(__DIR__);

#if 1
  #define FILE        "Input.TXT"
  #define BLOCK_COUNT 94703
#else
  #define FILE        "Sample.TXT"
  #define BLOCK_COUNT 42
#endif

I16 disk[BLOCK_COUNT];
MemSetU16(disk,-1,BLOCK_COUNT);

U0 DumpDisk()
{
  I64 i;
  for (i=0;i<BLOCK_COUNT;i++) {
    if (disk[i]<0)
      "%2d: \n",i;
    else
      "%2d: %d\n",i,disk[i];
  }
}

U0 LoadDisk()
{
  I64 size;
  U8 *disk_map=FileRead(FILE,&size);

  Bool is_file=TRUE;
  I64 i,block_size,disk_pos=0,block_id=0;
  for (i=0;i<size;i++) {
    block_size=disk_map[i]-'0';
    if (is_file) {
      MemSetU16(&disk[disk_pos],block_id++,block_size);
      disk_pos+=block_size;
      is_file=FALSE;
    } else {
      disk_pos+=block_size;
      is_file=TRUE;
    }
  }

  Free(disk_map);
}

I64 empty_block_idx=0;
I64 FindLeftEmptyBlock()
{
  while (TRUE) {
    if (empty_block_idx>=BLOCK_COUNT)
      return -1;

    if (disk[empty_block_idx]==-1)
      return empty_block_idx++;

    empty_block_idx+=1;
  }
}

I64 file_block_idx=BLOCK_COUNT-1;
I64 FindRightFileBlock()
{
  while (TRUE) {
    if (file_block_idx<0)
      return -1;

    if (disk[file_block_idx]!=-1)
      return file_block_idx--;

    file_block_idx-=1;
  }
}

I64 CalcDiskChecksum()
{
  I64 i,res=0;
  for (i=0;i<BLOCK_COUNT;i++) {
    if (disk[i]>-1)
      res+=i*disk[i];
  }
  return res;
}

U0 Part1()
{
  LoadDisk;

  I64 eb,fb;
  while (TRUE) {
    fb=FindRightFileBlock;
    if (fb==-1) break;

    eb=FindLeftEmptyBlock;
    if (eb==-1) break;

    if (eb>=fb) break;

    disk[eb]=disk[fb];
    disk[fb]=-1;
  }


  "RESULT: %d\n",CalcDiskChecksum;
}

class BlockGroup {
  I64 begin;
  I64 len;
};

Bool FindEmptyBlockGroup(I64 rb,I64 len,BlockGroup *res)
{
  I64 i=0;
  while (TRUE) {
    if (i>=rb)
      return FALSE;

    if (disk[i]==-1) {
      res->begin=i;
      res->len=1;
      while (++i<BLOCK_COUNT && disk[i]==-1)
        res->len+=1;
      if (res->len<len) goto continue;
      return TRUE;
    }

    i+=1;
continue:
  }
}

I64 file_idx=BLOCK_COUNT-1;
Bool NextFileBlockGroup(BlockGroup *res)
{

  I64 id;
  while (TRUE) {
    if (file_idx<0) return FALSE;
    id=disk[file_idx];
    if (id>-1) {
      res->len=1;
      while (--file_idx>=0 && disk[file_idx]==id)
        res->len+=1;
      res->begin=file_idx+1;
      return TRUE;
    }
    file_idx-=1;
  }
}

U0 Part2()
{
  LoadDisk;

  BlockGroup file_bg,empty_bg;
  while (NextFileBlockGroup(&file_bg)) {
    if (FindEmptyBlockGroup(file_bg.begin,file_bg.len,&empty_bg)) {
      MemCpy(&disk[empty_bg.begin],&disk[file_bg.begin],file_bg.len*sizeof(U16));
      MemSetU16(&disk[file_bg.begin],-1,file_bg.len);
    }
  }

  "RESULT: %d\n",CalcDiskChecksum;
}





//Part1;
Part2;
