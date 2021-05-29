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
      strokeWeight(8);
      fill(90, 180);
    } else
    {  
      strokeWeight(3);
      fill(180, 180);
    }


    rect(x, y, w, h); 

    fill(255, 0, 0, 180);
    textAlign(CENTER);
    if (h != 0)
    {
      textSize(0.8*h);
      text(title, x, y, 0.95*w, 0.8*h);
    }
  }
}
