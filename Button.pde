class Button
{
  int x, y, w, h;
  
  public String title;  
  public boolean pressed; 

  Button(int px, int py, int pw, int ph, String txt)
  {
    x = px;
    y = py;
    w = pw;
    h = ph;
    title = txt;
    pressed = false;
  }
  
  public void isPressed()
  {
    if (mousePressed && mouseX > x-w/2 && mouseX < x+ w/2 
      && mouseY > y - h/2 && mouseY < y + h/2)  
      pressed = true;  
    else 
      pressed = false;
  }

  public void show()
  {
    if (pressed) 
    {  
      strokeWeight(4);
      fill(90, 180);
    } 
    else
    {  
      strokeWeight(2);
      fill(180, 180);
    }
    
    rect(x, y, w, h); 

    if (h != 0)
    {
      fill(0, 150);
      textSize(0.4*h);
      textAlign(CENTER, CENTER);
      text(title, x, y, w, h);
    }
  }
}
