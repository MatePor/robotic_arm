class TextArea extends Button
{
  public String txt2;
  boolean ente;
  
  TextArea(int x, int y, int w, int h, String title, String txt) 
  {
    super(x, y, w, h, title); 
    txt2 = txt;   
    ente = false;
  }

  public void show()
  {
    if(ente) 
    {  
      strokeWeight(4);
      fill(255, 180);
    } 
    else
    {  
      strokeWeight(2);
      fill(220, 180);
    }
    
    rect(x, y, w, h); 

    if (h != 0)
    {
      fill(0, 150);
      textSize(0.4*h);
      textAlign(CENTER, CENTER);
      text(title, x-w/4, y, w/2, h/2);
      text(txt2, x+w/4,y, w/2, h/2);
    }
  }
} 
