class Menu
{
  Button START, RESET_B, MENU_B, INSTRUCTIONS, AUTHOR, DOCUMENTATION, BACK_B;
  public boolean auth, inst, docu;
  
  Menu()
  {
    START = new Button(width/2, height/4, 400, 66, "START");
    RESET_B = new Button(width/2, height/4 + 80, 400, 66, "RESET");
    INSTRUCTIONS = new Button(width/2, height/4 + 160, 400, 66, "INSTRUCTIONS");
    DOCUMENTATION = new Button(width/2, height/4 + 240, 400, 66, "DOCUMENTATION");
    AUTHOR = new Button(width/2, height/4 + 320, 400, 66, "AUTHOR");
    BACK_B = new Button(100, 100, 120, 80, "BACK");
    auth = false;
    inst = false;
    docu = false;
  }
  
  public void openMenu()
 {
  background(0);
  fill(120);
  rect(width/2, height/2, width-100, height-100);

  fill(220);
  textSize(30);
  text("* Robotic Arm Simulator - 2021 *", width/2, 100, width*2/3, 300);
  
  // update position for full screen
  START.x = width/2;
  RESET_B.x = width/2;
  INSTRUCTIONS.x = width/2;
  DOCUMENTATION.x = width/2;
  AUTHOR.x = width/2;
  
  //check whether something is pressed
  START.isPressed();
  RESET_B.isPressed();
  INSTRUCTIONS.isPressed();
  DOCUMENTATION.isPressed();
  AUTHOR.isPressed();
  BACK_B.isPressed();
  
  // display 
  START.show();
  RESET_B.show();
  INSTRUCTIONS.show();
  DOCUMENTATION.show();
  AUTHOR.show();
 
  //
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
