class button
{
  int x, y, w, h;
  String title;
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

  void show()
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
