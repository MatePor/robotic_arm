class Menu
{
  Button START, MENU_B, INSTRUCTIONS, AUTHOR, DOCUMENTATION, BACK_B;
  
  Menu()
  {
    START = new Button(width/2, height/3, width/2, 70, "START");
    INSTRUCTIONS = new Button(width/2, height/3 + 90, width/2, 70, "INSTRUCTIONS");
    DOCUMENTATION = new Button(width/2, height/3 + 180, width/2, 70, "DOCUMENTATION");
    AUTHOR = new Button(width/2, height/3 + 270, width/2, 70, "AUTHOR");
    
    BACK_B = new Button(100, 100, 80, 80, "BACK");
  }
  
  public void openMenu()
 {
  background(0);
  fill(120);
  rect(width/2, height/2, width-100, height-100);

  fill(220);
  textSize(30);
  text("* Robotic Arm Simulator - 2021 *", width/2, 100, width*2/3, 300);
  
  START.show();
  INSTRUCTIONS.show();
  DOCUMENTATION.show();
  AUTHOR.show();
  
  START.isPressed();
  INSTRUCTIONS.isPressed();
  DOCUMENTATION.isPressed();
  AUTHOR.isPressed();

  if (auth)
    openAuthor();
  if (inst)
    openInstruction();
  if (docu)
    openDocumentation();
}

public void openAuthor()
{
  background(0);
  fill(120);
  rect(width/2, height/2, width-100, height-100);

  fill(220);
  textSize(30);
  text("* Robotic Arm Simulator - 2021 *", width/2, 100, width*2/3, 300);

  BACK_B.show();
}

public void openInstruction()
{
  background(0);
  fill(120);
  rect(width/2, height/2, width-100, height-100);

  fill(220);
  textSize(30);
  text("* Robotic Arm Simulator - 2021 *", width/2, 100, width*2/3, 300);

  BACK_B.show();
}

void openDocumentation()
{
  background(0);
  fill(120);
  rect(width/2, height/2, width-100, height-100);

  fill(220);
  textSize(30);
  text("* Robotic Arm Simulator - 2021 *", width/2, 100, width*2/3, 300);

  BACK_B.show();
}
  
  
}
