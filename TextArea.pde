/*class Button extends TextArea 
{
  String angle;
  
  TextArea(int px, int py, int pw, int ph, String txt, String txt2) {
    super(px, py, pw, ph, txt); 
    angle = txt2;
  }

 public void isPressed()
  {
    if (mousePressed && mouseX > x-w/2 && mouseX < x+ w/2 
      && mouseY > y - h/2 && mouseY < y + h/2)  
      pressed = !pressed;  
  }
 
  public void show()
  {
    if(pressed) 
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
      text(title, x, y, w, h);
    }
  }
} */
