class Menu
{
  Button START, RESET_B, MENU_B, INSTRUCTIONS, AUTHOR, BACK_B;
  public boolean auth, inst;
  
  Menu()
  {
    START = new Button(width/2, height/3, 400, 66, "START");
    RESET_B = new Button(width/2, height/3 + 80, 400, 66, "RESET");
    INSTRUCTIONS = new Button(width/2, height/3 + 160, 400, 66, "INSTRUCTIONS");
    AUTHOR = new Button(width/2, height/3 + 240, 400, 66, "AUTHOR");
    BACK_B = new Button(100, 80, 120, 80, "BACK");
    auth = false;
    inst = false;
  }
  
  public void openMenu()
 {
  background(0);
  fill(120);
  rect(width/2, height/2, width-50, height-50);

  fill(220);
  textSize(30);
  text("* Robotic Arm Simulator - 2021 *", width/2, 100, width*2/3, 300);
  
  // update position for full screen
  START.x = width/2;
  RESET_B.x = width/2;
  INSTRUCTIONS.x = width/2;
  AUTHOR.x = width/2;
  
  //check whether something is pressed
  START.isPressed();
  RESET_B.isPressed();
  INSTRUCTIONS.isPressed();
  AUTHOR.isPressed();
  BACK_B.isPressed();
  
  // display 
  START.show();
  RESET_B.show();
  INSTRUCTIONS.show();
  AUTHOR.show();
 
  //
  if (auth)
    openAuthor();
  if (inst)
    openInstruction();
}

public void openAuthor()
{
  background(0);
  fill(120);
  rect(width/2, height/2, width-50, height-50);

  fill(220);
  textSize(30);
  text("* Robotic Arm Simulator - 2021 *", width/2, 100, width*2/3, 300);
  text(" Mateusz Porębiak ", width/2, 300, width*2/3, 300);

  BACK_B.show();
}

public void openInstruction()
{
  background(0);
  fill(120);
  rect(width/2, height/2, width-50, height-50);

  fill(220);
  textSize(12);
  textAlign(LEFT, UP);
  text(" MENU: \n1. START - otwiera okno symulacji \n2. RESET - resetuje do początkowego ustawienia robota i kamerę, nowy obiekt pojawia się w losowym miejscu \n3 ",
  width/2, height/2 - 100, 400, 200);
  text(" SYMULACJA: \n1. MENU - pozwala na powrót do ekranu startowego   PPM - przeciąganie myszą pozwala na obracanie kamery \n2. CONTROLS - otwiera panel sterowania robotem   RECORD - pozwala na zapamiętywanie położenia robota do jego wewnętrznej pamięci \n 3. MANUAL_B - przycisk ten zmienia tryb pracy robota, należy klikać go wielokrotnie, aby ustawić tryb w jakim chcemy pracować ",
  width/2, height/2, 400, 200);
  text(" EFFECTOR_CHANGE - pozwala na zmianę efektora na magnetyczny, tylko w przypadku efektora magnetycznego jesteśmy w stanie podnosić obiekty, mechaniczny jest jedynie ozdobą \n MANUAL_B - sterowanie ręczne za pomocą przycisków \n INPUT_A - wprowadzanie kątów, następnie za pomocą MOVE możemy kazać mu tam się udać \n INVERSE_K - kinematyka odwrotna, ustawienie współrzędnych punktów, w które może udać się robot !!! UWAGA !!! TRYB NIE ZOSTAŁ UKOŃCZONY \n RECORDED_P - po ukończeniu nagrywania możemy kazać robotowi powtórzyć wykonane ruchy, CONTINUOUS - sprawia, że robot po zakończeniu powtarzania, robi to od nowa, (CHANGE_ONLY NIC NIE ZMIENIA NIE UKOŃCZONE) \n AUTOMATIC - TRYB NIE ZOSTAŁ UKOŃCZONY, docelowo miała być budowana wieża z obiektów.",
  width/2, height/2 + 150, 400, 200);
  

  
  BACK_B.show();
}
}
