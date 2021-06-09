class button
{
  private int x, y, w, h;
  public String title;
  
  // MAKE PRIVATE AND GET isPressed FUNCTION HERE
  boolean pressed; 

  button(int px, int py, int pw, int ph, String txt)
  {
    x = px;
    y = py;
    w = pw;
    h = ph;
    title = txt;
    pressed = false;
  }

  public void show()
  {
    if (pressed) 
    {  
      strokeWeight(4);
      fill(90, 180);
    } else
    {  
      strokeWeight(2);
      fill(180, 180);
    }


    rect(x, y, w, h); 

    fill(255, 0, 0, 180);
    textAlign(CENTER, CENTER);
    if (h != 0)
    {
      textSize(0.4*h);
      text(title, x, y, w, h);
    }
  }
}
