class Memory
{
  // record storage
  private ArrayList <PVector> pos;
  private ArrayList <PVector> ang;
  private ArrayList <PVector> ori; 
  private IntList action; 
  private int MemoSize;
  float []dataArray;
  
  Memory()
  {
    pos = new ArrayList<PVector>();
    ang = new ArrayList<PVector>();
    ori = new ArrayList<PVector>();
    action = new IntList();
    MemoSize = 0;
    dataArray = new float[10];
    for(int i = 0; i < 10; i++)
       dataArray[i] = 0;
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
  
  public float[] readMemo(int index)
  {   
    if(index < MemoSize)
    {    
      dataArray[0] = pos.get(index).x; 
      dataArray[1] = pos.get(index).y; 
      dataArray[2] = pos.get(index).z; 
      dataArray[3] = ang.get(index).x;
      dataArray[4] = ang.get(index).y;
      dataArray[5] = ang.get(index).z;
      dataArray[6] = ori.get(index).x;
      dataArray[7] = ori.get(index).y;
      dataArray[8] = ori.get(index).z;
      dataArray[9] = float(action.get(index)); 
    }  
      return dataArray; 
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
  
  public int getSize()
  {
    return MemoSize;
  }
  
  public void saveToFile()
  {
    //create and write to file
  
  
  }
  
} 
