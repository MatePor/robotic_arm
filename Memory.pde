class Memory
{
  private ArrayList <PVector> pos;
  private ArrayList <PVector> ang;
  private ArrayList <PVector> ori; 
  private IntList action; 
  private int MemoSize;
  
  Memory()
  {
    pos = new ArrayList<PVector>();
    ang = new ArrayList<PVector>();
    ori = new ArrayList<PVector>();
    action = new IntList();
    MemoSize = 0;
  }
  
  public void clearAll()
  {
    
    if(MemoSize != 0)
      pos.clear();
    if(MemoSize != 0)
      ang.clear();
    if(MemoSize != 0)
      ori.clear();
    if(MemoSize != 0)
      action.clear(); 
      
     MemoSize = 0;  
  }
  
  public void readMemo(float posX, float posY, float posZ, 
  float ang1, float ang2, float ang3, float ang4, float ang5, float ang6,
   int action_reader, int index)
  {
    if(index < MemoSize)
    {
      posX = pos.get(index).x; 
      posY = pos.get(index).y; 
      posZ = pos.get(index).z; 
      ang1 = ang.get(index).x;
      ang2 = ang.get(index).y;
      ang3 = ang.get(index).z;
      ang4 = ori.get(index).x;
      ang5 = ori.get(index).y;
      ang6 = ori.get(index).z;
      action_reader = action.get(index); 
    } 
  }

  public void writeMemo(PVector position, PVector angle, PVector orient,int c)
  {
    pos.add(position);
    ang.add(angle);
    ori.add(orient);
    action.append(c); 
    MemoSize++; 
  }
  
  public boolean checkSize(int index)
  {
    if(index < MemoSize)
      return true;
    
    return false;
  }
  
  public void saveToFile()
  {
    //create and write to file
  
  
  }
  
}