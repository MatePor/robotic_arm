PVector []angles;
float []ph, DEST_ph;
float da;
String [] angle_names = {"ph1:", "ph2:", "ph3:", "ph4:", "ph5:", "ph6:"};

int mode_num;
String []mode_names = {"MANUAL_B", "INPUT_A", "INVERSE_K", "RECORDED_P", "AUTOMATIC"};

boolean grip_on, blocked;

boolean roll_up, button_is_pressed, keyboard, automatic, continuous,
  recording, change, only_ch, inverse, menu_o, playing, mouse_follow, looking, moving, config;

int num_of_things, num_of_c_buttons;
int range, floor_level, dome_radius, hall_center;   
int MemoIndex;

float camX, camY, camD;
PVector camCenter;
PImage roof;

Menu my_menu;
Memory memory_A;
Thing []things;
Arm robot;
Button []C_BUTTONS, TXT_A; 
Button MOVE_B, MGNT_ON, MENU_B, FLY, CONTROLS, ZOOM_IN, ZOOM_OUT, MAN_AUT,
 R_MODE, RECORD_B, MODE_B, CH_EFF, KEY_BUT, PLAY_R, CONT_B, APPLY, CLR_M;

void setup()
{
  size(800, 600, P3D);
  //surface.setTitle("Robotic Arm 2021");
  //surface.setLocation(30, 30);
  rectMode(CENTER);
  //roof = loadImage("roof.jpg");
  
  textFont(createFont("Arial", 100));
  
  // create menu object
  my_menu = new Menu();
  memory_A = new Memory();
  MemoIndex = 0;
  
  // --------- INITIALIZE VARIABLES -----------------
  // camera position angles and distance
  camX = 0;
  camY = 0;
  camD = 1.5;
  camCenter = new PVector(width/2, height/2 - 100, 0);

  // gripper parameters
  //grip_size = 10;
  //max_grip = 24;
  //grip_on = true;
  blocked = false;

  // angles(position)
  ph = new float[6];
  DEST_ph = new float[6];
  
  ph[0] = 0;
  ph[1] = PI/4;
  ph[2] = -5*PI/4;
  ph[3] = 0;
  ph[4] = 0;
  ph[5] = 0;
 
  DEST_ph[0] = 0;
  DEST_ph[1] = PI/4;
  DEST_ph[2] = -5*PI/4;
  DEST_ph[3] = 0;
  DEST_ph[4] = 0;
  DEST_ph[5] = 0;
  
  mode_num = 0;
  angles = new PVector[6];
  for (int i = 0; i < 6; i++)
    angles[i] = new PVector(0, 0, 0);

  // angle step
  da = PI/128; 

  // create an arm
  robot = new Arm(angles, new PVector(0, 0, 0), "NUm 1", 26);

  // environment
  hall_center = width/2;
  floor_level = 0;
  range = 100;
  dome_radius = 1500;
  
  // things (little boxes falling from the sky)
  num_of_things = 6;
  things = new Thing[num_of_things];
  for (int i = 0; i < num_of_things; i++)
  {
    int ran = int(random(10, 24));
    boolean ok;
    Thing test_thing;

    do
    {
      ok = true;  
      color rand_color = color(random(255), random(255), random(255));
      test_thing = new Thing(ran, int(random(-range,range)), int(random(-10000,-100)), int(random(-range, range)),
      0, random(PI), 0, rand_color);
      
      for (int j = 0; j < i; j++)
        if (isColliding(test_thing, things[j]))
          ok = false;
          
        if(isColliding(test_thing, robot.base))
          ok = false;
    }
    while (!ok);

    things[i] = test_thing;
  }

  // -------------------- BUTTONS ------------------
  MENU_B = new Button(80, 20, 160, 40, "MENU");               // back to menu
  ZOOM_IN = new Button(width - 47, 54, 56, 70, ""); 
  ZOOM_OUT = new Button(width - 47, 143, 56, 70, "");

  //FLY = new button(240, 20, 160, 40, "FLY MODE");
  
  CONTROLS = new Button(80, 60, 160, 40, "CONTROLS");          // control panel ON/OFF
  RECORD_B = new Button(240, 20, 160, 40, "RECORD");             // record START/STOP
  MODE_B = new Button(240, 60, 160, 40, "MANUAL_B");           // change robot working mode
  CH_EFF = new Button(240, 100, 160, 40, "CHANGE EFFECTOR");   // self-explanatory
  KEY_BUT = new Button(240, 140, 160, 40, "KEYBOARD");         // change input between keyboard and button
  MOVE_B = new Button(240, 180, 160, 40, "MOVE");              // emable robot to move
  
  MGNT_ON = new Button(80, 340, 160, 40, "MAGN -OFF"); // magnet ON/OFF
  
  PLAY_R = new Button(80, 300, 160, 40, "PLAY_R");
  CLR_M = new Button(80, 340, 160, 40, "CLR DATA"); 
  CONT_B = new Button(80, 140, 160, 40, "CONTINUOUS-M");
  R_MODE = new Button(80, 180, 160, 40, "CHANGE ONLY-M");
  //GO_B = new Button(76, 150, 160, 40, "MOVE");
  
  // text areas
  TXT_A = new Button[6];
  for(int i = 0; i < 6; i++)
    TXT_A[i] = new Button(80, 100+40*i, 160, 40, angle_names[i]);
  
  // control buttons (changing variables values)
  num_of_c_buttons = 14;
  button_is_pressed = false;              
  C_BUTTONS = new Button[num_of_c_buttons];
  
  int k = 0;
  for (int i = 0; i < num_of_c_buttons; i++)
  {
    C_BUTTONS[i] = new Button(100 +(i%2)*40, 100+40*k, 40, 40, (i%2==0)?"+":"-");

    if (i%2 == 1)
      k++;
  }

  // control booleans
  roll_up = false;
  menu_o = true;
  keyboard = false;
  automatic = false;
  recording = false;
  inverse = false;
  playing = false;
  mouse_follow = false;
  looking = false;
  moving = false;
  continuous = false;
  config = false;
  change = false;
  only_ch = false;
}

void draw()
{
  background(255);
  lights();

  anythingPressed();
  if (menu_o)
  {
    //my_menu.BACK_B.isPressed();
    my_menu.openMenu();
  }
  else
  { 
    //check_cursor();
    controls();
    
    pushMatrix();
    cam();
    
    pushMatrix();
    // keep the same reference frame for everything
    translate(camCenter.x - hall_center, camCenter.y - floor_level, - camCenter.z);
    
    drawLab();
    animation();
    popMatrix();
    popMatrix();
 
    // debugging
    /*
    textSize(30);
    text(str(things[0].pos.y), 400, 50);
    text(str(things[0].vel.y), 400, 100); 
    text(str(robot.magn_ON), 400, 150);
    */
    //interface
    panel();
  }
}

void mouseDragged() 
{
  //cursor(MOVE);

  if (!button_is_pressed && !config)
  {
    float sens = 0.01;
    camX += (pmouseY-mouseY) * sens;
    camY += (mouseX-pmouseX) * sens;

    if (camX > 0)
      camX = 0;
    if (camX < -PI)
      camX = -PI;
  }
}

/*
void mouseWheel(MouseEvent event)
 {
 float sens = 0.1;
 camD -= event.getCount()*sens;
 
 if(camD < 0.5 )
 camD = 0.5;
 
 if(camD > 4.1 )
 camD = 4.1;
 }
 */

void cam()
{
  // camera position and movement
  if (keyPressed)
  {
    if (key == 'W' || key == 'w')
      camCenter.z += 20;
    if (key == 'S' || key == 's')
      camCenter.z -= 20;

    if (key == 'A' || key == 'a')
      camY += da;
    if (key == 'D' || key == 'd')
      camY -= da;
  }

  camCenter.x = width/2;
  camCenter.y = height/2 - 150;

  translate(camCenter.x, camCenter.y, camCenter.z);  
  rotateX(camX);
  rotateY(camY);
  scale(camD);
}

void keyPressed()
{
  
  if(keyboard)
  {
    String new_str = "";
    
    switch(key)
    {
      case '0': new_str += "0"; break;
      case '1': new_str += "1"; break;
      case '2': new_str += "2"; break;
      case '3': new_str += "3"; break;
      case '4': new_str += "4"; break;
      case '5': new_str += "5"; break;
      case '6': new_str += "6"; break;
      case '7': new_str += "7"; break;
      case '8': new_str += "8"; break;
      case '9': new_str += "9"; break;
      case BACKSPACE: new_str = new_str.substring(0,new_str.length() - 2); break;
      default: break;
    }
  }
  
}

void panel()
{
  // -------- INTERFACE -----------
  // drawing interface, buttons and messages depending on robot's mode
  
  pushStyle();
  fill(240, 180);
  rect(80, 40, 160, 80);
  popStyle();
  MagnGlass(width - 50, 44, "+");
  MagnGlass(width - 50, 133, "-");
  ZOOM_IN.x = width - 47;
  ZOOM_OUT.x = width - 47;
  ZOOM_IN.show();
  ZOOM_OUT.show();
  MENU_B.show();
  CONTROLS.show();
  
  if (roll_up)
  {  
    pushStyle();
    fill(240, 180);
    rect(80, 220, 160, 280);
    rect(240, 40, 160, 80);
    popStyle();
    
    MODE_B.show();
    RECORD_B.show();
    
    pushStyle();
    noStroke();
    if(!recording)
    {
      fill(0,255,100);
      triangle(292,27,292,13,307,20);
    }
    else
    {
      fill(255,0,0);
      noStroke();
      rect(300,20,16,16); 
      fill(255);
      textSize(30);
      text(" recording... ", width/2, 20);
    }
    popStyle();
      
    if(mode_num < 3)
    {  
      MGNT_ON.show();
      CH_EFF.show();
    }
      
    switch(mode_num)
    {
     case 0:
      for(int i = 0; i < 6; i++)
      {
        textSize(13);
        fill(0);
        textAlign(LEFT, CENTER);
        text(angle_names[i], 20, 100+i*40, 34, 38);
        textAlign(RIGHT, CENTER);
        text(toDegr(ph[i]), 52, 100+i*40, 44, 38);
      }
      
      if(!robot.magnetic)
      {
        textAlign(LEFT, CENTER);
        text("grip size --: "+ str(robot.grip_size), 40, 340, 76, 38);;
      }  
      
      for (int i = 0; i < (num_of_c_buttons - int(robot.magnetic)*2); i++)
        C_BUTTONS[i].show();
       break;
       
     case 1: 
      MOVE_B.show();
      KEY_BUT.show();

      if(!keyboard)
      {  for(int i = 0; i < 6; i++)
        {
          textSize(13);
          fill(0);
          textAlign(LEFT, CENTER);
          text(angle_names[i], 20, 100+i*40, 34, 38);
          textAlign(RIGHT, CENTER);
          text(toDegr(DEST_ph[i]), 52, 100+i*40, 44, 38);
        }
      
      if(!robot.magnetic)
      {
        textAlign(LEFT, CENTER);
        text("grip size --: "+ str(robot.grip_size), 40, 340, 76, 38);;
      }
      
      for (int i = 0; i < (num_of_c_buttons - int(robot.magnetic)*2); i++)
        C_BUTTONS[i].show();
      }
      else
      {
        for(int i = 0; i < 6; i++)
            TXT_A[i].show();           
      }
      
       if(!robot.magnetic)
       {
         C_BUTTONS[12].show();
         C_BUTTONS[13].show();
       }
       break;
       
     case 2: 
       MOVE_B.show();
       KEY_BUT.show();
        for(int i = 0; i < 6; i++)
      {
        textAlign(LEFT, CENTER);
        text(angle_names[i], 20, 100+i*40, 34, 38);
        textAlign(RIGHT, CENTER);
        text(toDegr(ph[i]), 52, 100+i*40, 44, 38);
      }
      
      if(!robot.magnetic)
        text("grip size: "+ str(robot.grip_size), 40, 340, 76, 38);
      
      for (int i = 0; i < (num_of_c_buttons - int(robot.magnetic)*2); i++)
        C_BUTTONS[i].show();
       break;
       
     case 3:
       PLAY_R.show();
       CONT_B.show();
       CLR_M.show();
       R_MODE.show();
      if(!playing)
     {
       fill(0,255,100);
       triangle(132,347,132,333,147,340);
     }
    else
    {
      fill(255,0,0);
      noStroke();
      rect(140,300,16,16); 
      fill(255);
      textSize(30);
      text(" playing ", width/2, 20);
    }
       
       fill(130);
       if(continuous)
          fill(0,255,0);     
       ellipse(140, 140, 15,15);
       
       if(only_ch) 
         fill(0,255,0);
           ellipse(140, 180, 15, 15);
       break;
       
     case 4: 
      
       break;
       
     default: 
       break;
    }
  }
}

void animation()
{
  // physics and interaction
  gravity();
    
  if(robot.magn_ON)
    move_object();
   
  update_angles();
  robot.updateArm(angles);
  robot.showArm();
  
  for (int i = 0; i < num_of_things; i++)
  { 
      things[i].pos.add(things[i].vel);
      things[i].show();
  }

  pushMatrix();
  translate(robot.position.x, robot.position.y, robot.position.z);
  translate(robot.effector_pos.x, robot.effector_pos.y, robot.effector_pos.z);
  rotateX(robot.effector_orient.x);
  rotateY(robot.effector_orient.y);
  rotateZ(robot.effector_orient.z);
  noFill();
  strokeWeight(0.1);
  sphere(30);
  popMatrix();

} 

boolean isColliding(Thing A, Thing B)
{
  /*if((A.x + A.obj_size/2 > B.x - B.obj_size/2 && 
   A.x + A.obj_size/2 < B.x + B.obj_size/2)||
   (A.x - A.obj_size/2 > B.x - B.obj_size/2 && 
   A.x - A.obj_size/2 < B.x + B.obj_size/2)
   A.y + A.obj_size/2 > B.y + B.obj_size/2
   )
   
   
   function intersect(a, b) {
   return (a.minX <= b.maxX && a.maxX >= b.minX) &&
   (a.minY <= b.maxY && a.maxY >= b.minY) &&
   (a.minZ <= b.maxZ && a.maxZ >= b.minZ);
   }
   
   return true; */

  float rA = sqrt(3*(A.dep/2)*(A.dep/2));
  float rB = sqrt(3*(B.dep/2)*(B.dep/2));

  float distance = sqrt(pow(A.pos.x-B.pos.x, 2)+pow(A.pos.y-B.pos.y, 2)+pow(A.pos.z-B.pos.z, 2));

  if (distance < rA+rB)
    return true;

  return false;
}

void MagnGlass(int x, int y, String sign)
{
  noFill();
  stroke(0);
  strokeWeight(3);
  ellipse(x, y, 30, 30);
  strokeWeight(7);
  line(x+15*cos(-PI/3), y+15*sin(PI/3), x+35*cos(-PI/3), y+35*sin(PI/3));
  strokeWeight(1);
  textSize(22);
  rectMode(CENTER);
  fill(0);
  text(sign, x, y, 30, 30);
}

/*
void check_cursor()
 {
 if(button_is_pressed)
 cursor(HAND);
 else 
 cursor(ARROW);
 
 if(mouse_follow)
 cursor(CROSS);
 else
 cursor(ARROW);
 
 }
 */

void update_angles()
{
  angles[0].y = ph[0];
  angles[1].z = ph[1];
  angles[2].z = ph[2];
  angles[3].y = ph[3];
  angles[4].z = ph[4];
  angles[5].x = ph[5];
}

void move_angles()
{
  ph[0] += signum(DEST_ph[0]-ph[0])*da/2;
  ph[1] += signum(DEST_ph[1]-ph[1])*da/2;
  ph[2] += signum(DEST_ph[2]-ph[2])*da/2;
  ph[3] += signum(DEST_ph[3]-ph[3])*da/2;
  ph[4] += signum(DEST_ph[4]-ph[4])*da/2;
  ph[5] += signum(DEST_ph[5]-ph[5])*da/2;
}

int signum(float x)
{
  if(x > 0)
    return 1;
  if(x < 0)
    return -1;
 
  return 0; 
}

void mouseReleased()
{
  if (MENU_B.pressed)
    menu_o = true;
  
  if(roll_up)
  {   
  if (RECORD_B.pressed)
  {
     recording = !recording;
     if(recording) 
       RECORD_B.title = "STOP";
     else 
       RECORD_B.title = "RECORD";
  }
  
  if (MODE_B.pressed)
    {
      mode_num++;
      if(mode_num > 4)
        mode_num = 0;
      MODE_B.title = mode_names[mode_num];
    }
    
  if(mode_num == 1 && MOVE_B.pressed)
  {
      moving = !moving;
      if(moving)
        MOVE_B.title = "STOP";
      else
        MOVE_B.title = "MOVE";
  }
  
  if(mode_num < 3)
  { 
  
  if(CH_EFF.pressed)
    robot.magnetic = !robot.magnetic;
   if(robot.magnetic && MGNT_ON.pressed)
   {
        robot.magn_ON = !robot.magn_ON;
        
        if(!robot.magn_ON)
        {   
          for(int i = 0; i < num_of_things; i++)
              things[i].caught = false;
              
          MGNT_ON.title = "MGN -OFF";
         }
         else 
         MGNT_ON.title = "MGN -ON";
         
         MGNT_ON.pressed = false;
   }   
      
  }
    
   if((mode_num == 1 || mode_num == 2) && KEY_BUT.pressed)
   {
     keyboard = !keyboard;
     if(keyboard)
       KEY_BUT.title = "KEYBOARD";
     else
       KEY_BUT.title = "BUTTONS";
   }
  
   if(mode_num == 3)
   {
     if(CLR_M.pressed)
       memory_A.clearAll();
     
     if(CONT_B.pressed)
       continuous = !continuous;
     
     if(R_MODE.pressed)
       only_ch = !only_ch;
       
     if(PLAY_R.pressed)
     {
       playing = !playing;
       
       if(playing)
         PLAY_R.title = "STOP_R";
       else
         PLAY_R.title = "PLAY_R";    
     }
   }
   
   
   
  }
  
  
  if (CONTROLS.pressed)
    roll_up = !roll_up;

  if(menu_o)
  {
    if (my_menu.START.pressed)
    {
      menu_o = false; 
      my_menu.START.pressed = false;
    }
  
    if (my_menu.INSTRUCTIONS.pressed)
      my_menu.inst = true;
  
    if (my_menu.DOCUMENTATION.pressed)
      my_menu.docu = true;
  
    if (my_menu.AUTHOR.pressed)
      my_menu.auth = true;
  
    if (my_menu.BACK_B.pressed)
    {
      my_menu.inst = false;
      my_menu.auth = false;
      my_menu.docu = false;
    }
    
    if(my_menu.RESET_B.pressed)
       resetAll(); 
   
  }
}

void anythingPressed()
{
  // check whether any acitve button is pressed right now
  button_is_pressed = false;
  ArrayList <Boolean> presses = new ArrayList<Boolean>();
  boolean C_prsd = false;
  for (int i = 0; i < num_of_c_buttons; i++)
  {
    C_BUTTONS[i].isPressed();
    presses.add(C_BUTTONS[i].pressed);
    
    
    if(C_BUTTONS[i].pressed)
      C_prsd = true;  
  }
  
  if(C_prsd)
    change = true;
  else 
    change = false;


  ZOOM_IN.isPressed();
  presses.add(ZOOM_IN.pressed);
  ZOOM_OUT.isPressed();
  presses.add(ZOOM_OUT.pressed);
  MENU_B.isPressed();
  presses.add(MENU_B.pressed);
  CONTROLS.isPressed();
  presses.add(CONTROLS.pressed);
  RECORD_B.isPressed();
  presses.add(RECORD_B.pressed);
  MOVE_B.isPressed();
  presses.add(MOVE_B.pressed);
  MODE_B.isPressed();
  presses.add(MODE_B.pressed);
  
  if(mode_num == 3)
  {
    PLAY_R.isPressed();
    presses.add(PLAY_R.pressed);
    CONT_B.isPressed();
    presses.add(CONT_B.pressed);
    CLR_M.isPressed();
    presses.add(CLR_M.pressed);
    R_MODE.isPressed();
    presses.add(R_MODE.pressed);
  }
  
  if(robot.magnetic)
  {    
    MGNT_ON.isPressed();
       presses.add(MGNT_ON.pressed);
  }
  
  if(mode_num == 1 || mode_num == 2)
  {
    KEY_BUT.isPressed();
    presses.add(KEY_BUT.pressed);
  }
  
  CH_EFF.isPressed();
  presses.add(CH_EFF.pressed);
  
  for (int i = 0; i < presses.size(); i++)
    if (presses.get(i))
      button_is_pressed = true;
}

String toDegr(float x)
{
  float degr_x = 180/PI * x;
  float decimals = degr_x - int(degr_x);
  int d1 = int(decimals*10);
  int d2 = int(decimals*100) - d1;

  if (d2 >= 5)
    d1++;

  float degr = int(degr_x) + d1/10;

  return str(degr) + '\u00b0';
}

void controls()
{
  // camera motion and screen display
  // zoom in/zoom out
  if (ZOOM_IN.pressed) 
    camD += da;
  else if (ZOOM_OUT.pressed)
    camD -= da;

  if (camD < 0.5)
    camD = 0.5;

  if (camD > 4.1 )
    camD = 4.1;
  
  // menu/instructions
  if (roll_up)
  {
    switch(mode_num)
    {
    
    // arm motion 
    case 0: 
      manual_control();  
     break;
    case 1:
    if(moving)
      move_angles();     
      input_angles();    
      break;
     case 2:
      inverse_kinematics();
       break;
     case 3:
      recorded_play();
       break;
     case 4:
      automatic_mode();
       break;
     default:
       break;
    }
  }
  
}

void manual_control()
{
    // PHI
      if (C_BUTTONS[0].pressed) 
        ph[0] += da;
      if (C_BUTTONS[1].pressed)
        ph[0] -= da;

      if (ph[0] >= 2*PI)
        ph[0] = 0;
      if (ph[0] <= -2*PI)
        ph[0] = 0;  

      // THETA
      if (C_BUTTONS[2].pressed)
        ph[1] += da;
      if (C_BUTTONS[3].pressed) 
        ph[1] -= da;

      if (ph[1] >= 7*PI/12)
        ph[1] = 7*PI/12;
      if (ph[1] <= -7*PI/12)
        ph[1] = -7*PI/12;

      // PSI
      if (C_BUTTONS[4].pressed)
        ph[2] -= da;
      if (C_BUTTONS[5].pressed) 
        ph[2] += da;     

      if (ph[2] >= 2*PI)
        ph[2] = 0;
      if (ph[2] <= -2*PI)
        ph[2] = 0;

      // ROLL
      if (C_BUTTONS[6].pressed) 
        ph[3] += da;
      if (C_BUTTONS[7].pressed)
        ph[3] -= da;

      if (ph[3] >= 2*PI)
        ph[3] = 0;
      if (ph[3] <= -2*PI)
        ph[3] = 0;  

      // PITCH
      if (C_BUTTONS[8].pressed)
        ph[4] -= da;
      if (C_BUTTONS[9].pressed) 
        ph[4] += da;

      if (ph[4] >= PI/2)
        ph[4] = PI/2;
      if (ph[4] <= -PI/2)
        ph[4] = -PI/2;

      // YAW
      if (C_BUTTONS[10].pressed)
        ph[5] += da;
      if (C_BUTTONS[11].pressed) 
        ph[5] -= da;  

      if (ph[5] >= PI/6)
        ph[5] = PI/6;
      if (ph[5] <= -PI/6)
        ph[5] = -PI/6;

      if (C_BUTTONS[12].pressed)
        robot.grip_size += 1;
      if (C_BUTTONS[13].pressed) 
        robot.grip_size -= 1;  

      if (robot.grip_size >= robot.max_grip)
        robot.grip_size = robot.max_grip;
      if (robot.grip_size <= 0)
        robot.grip_size = 0;
}

void input_angles()
{
   
     // PHI
      if (C_BUTTONS[0].pressed) 
        DEST_ph[0] += da;
      if (C_BUTTONS[1].pressed)
        DEST_ph[0] -= da;

      if (DEST_ph[0] >= 2*PI)
        DEST_ph[0] = 0;
      if (DEST_ph[0] <= -2*PI)
        DEST_ph[0] = 0;  

      // THETA
      if (C_BUTTONS[2].pressed)
        DEST_ph[1] -= da;
      if (C_BUTTONS[3].pressed) 
        DEST_ph[1] += da;

      if (DEST_ph[1] >= 7*PI/12)
        DEST_ph[1] = 7*PI/12;
      if (DEST_ph[1] <= -7*PI/12)
        DEST_ph[1] = -7*PI/12;

      // PSI
      if (C_BUTTONS[4].pressed)
        DEST_ph[2] -= da;
      if (C_BUTTONS[5].pressed) 
        DEST_ph[2] += da;     

      if (DEST_ph[2] >= 2*PI)
        DEST_ph[2] = 0;
      if (DEST_ph[2] <= -2*PI)
        DEST_ph[2] = 0;

      // ROLL
      if (C_BUTTONS[6].pressed) 
        DEST_ph[3] += da;
      if (C_BUTTONS[7].pressed)
        DEST_ph[3] -= da;

      if (DEST_ph[3] >= 2*PI)
        DEST_ph[3] = 0;
      if (DEST_ph[3] <= -2*PI)
        DEST_ph[3] = 0;  

      // PITCH
      if (C_BUTTONS[8].pressed)
        DEST_ph[4] -= da;
      if (C_BUTTONS[9].pressed) 
        DEST_ph[4] += da;

      if (DEST_ph[4] >= PI/2)
        DEST_ph[4] = PI/2;
      if (DEST_ph[4] <= -PI/2)
       DEST_ph[4] = -PI/2;

      // YAW
      if (C_BUTTONS[10].pressed)
        DEST_ph[5] += da;
      if (C_BUTTONS[11].pressed) 
        DEST_ph[5] -= da;  

      if (DEST_ph[5] >= PI/6)
        DEST_ph[5] = PI/6;
      if (DEST_ph[5] <= -PI/6)
        DEST_ph[5] = -PI/6;
  
     if (C_BUTTONS[12].pressed)
        robot.grip_size += 1;
     if (C_BUTTONS[13].pressed) 
        robot.grip_size -= 1;  

      if (robot.grip_size >= robot.max_grip)
        robot.grip_size = robot.max_grip;
      if (robot.grip_size <= 0)
        robot.grip_size = 0;
 
}

void inverse_kinematics()
{
  // mouse mode (w/d)
  // x,y,z
  // 
  //
}

void recorded_play()
{  
  // read the memory and act appropriately 
  if(playing) 
      translateMemory();   
    
   if(!memory_A.checkSize(MemoIndex) && continuous)
       MemoIndex = 0;
}

void automatic_mode()
{
  
  
  
  
}

void move_object()
{ 
  for(int i = 0; i < num_of_things; i++)
  {
    Thing A = things[i];
    float r = sqrt(3*(A.dep/2)*(A.dep/2));
    float distance = sqrt(pow(A.pos.x-robot.effector_pos.x, 2)+pow(A.pos.y-robot.effector_pos.y, 2)+pow(A.pos.z-robot.effector_pos.z, 2));

    if (distance < r + 20)
    {
        //PVector new_pos = robot.effector_pos;
        //new_pos.y ;
        //new_pos.z calculate some angle and 
        // move the object towards its original position
        // so that it can levitate in a magnetic field     
        
        things[i].update(robot.effector_pos,robot.effector_orient); 
        things[i].caught = true;
    } 
   }   
}
  
void gravity()
{
  float g = 0.25;
 
  for(int i = 0; i < num_of_things; i++)
  {
    if(things[i].pos.y < -things[i].hei/2 && !things[i].caught)
    {   
        //check for collisions
        // for(int j = 0; j < num_of_things; j++)
        //
        
        things[i].vel.y += g;
    }
    else
    {
       things[i].pos.y = -things[i].hei/2;
       things[i].vel = new PVector(0,0,0);
    } 
  }   
  
}

void drawLab()
{
   // FLOOR AND DOME --------------- 
   // roof dome
   pushMatrix();
   translate(0, camCenter.y - floor_level,0);
    
   noStroke();
   fill(25);
   PShape dome = createShape(SPHERE, dome_radius);
   dome.disableStyle();
   //dome.setTexture(roof);
   shape(dome);
    
   pushMatrix();
   rotateX(-PI/2);
   fill(200, 150);
   ellipse(0, 0, 2*dome_radius, 2*dome_radius);
   popMatrix();
   popMatrix();
}

void resetAll()
{
  ph[0] = 0;
  ph[1] = PI/4;
  ph[2] = -5*PI/4;
  ph[3] = 0;
  ph[4] = 0;
  ph[5] = 0;
 
  DEST_ph[0] = 0;
  DEST_ph[1] = PI/4;
  DEST_ph[2] = -5*PI/4;
  DEST_ph[3] = 0;
  DEST_ph[4] = 0;
  DEST_ph[5] = 0;
  
  camX = 0;
  camY = 0;
  camD = 1.5;
  camCenter = new PVector(width/2, height/2 - 100, 0);
  
  mode_num = 0;
  memory_A.clearAll();
  
  for (int i = 0; i < 6; i++)
    angles[i] = new PVector(0, 0, 0);
  
  for (int i = 0; i < num_of_things; i++)
  {
    int ran = int(random(10, 24));
    boolean ok;

    do
    {
      ok = true;  
      color rand_color = color(random(255), random(255), random(255));
      
      things[i].changeValues(ran, int(random(-range,range)), int(random(-10000,-100)), int(random(-range, range)),
      0, random(PI), 0, rand_color);
      
      for (int j = 0; j < i; j++)
        if (isColliding(things[i], things[j]))
          ok = false;
          
        if(isColliding(things[i], robot.base))
          ok = false;
    }
    while (!ok);
  }
}

void translateMemory()
{
  int action_reader = 0;
  
  memory_A.readMemo(robot.effector_pos.x, robot.effector_pos.y, robot.effector_pos.z, 
  ph[0],ph[1],ph[2],ph[3],ph[4],ph[5],action_reader,MemoIndex);
  
  MemoIndex++;
  
  if(action_reader < 3)
    robot.magnetic = true;
  else 
    robot.magnetic = false;
    
  if(action_reader == 2)
    robot.magn_ON = true;
  else
    robot.magn_ON = false;
   
  if(action_reader == 4)
    robot.grip_size += 1;
  if(action_reader == 5)
    robot.grip_size -= 1;
}


void writeRecord()
{
  PVector ar_ang = new PVector(ph[0], ph[1], ph[2]);
  PVector or_ang = new PVector(ph[3], ph[4], ph[5]);
      
  int action_num = 0;
  if(robot.magnetic)
  {
    action_num = 1;
    if(robot.magn_ON)
      action_num = 2; 
  }
  else 
  {
    action_num = 3;
    if(C_BUTTONS[12].pressed)
      action_num = 4;
    if(C_BUTTONS[13].pressed)
      action_num = 5;  
  }
   
  memory_A.writeMemo(robot.effector_pos, ar_ang, or_ang, action_num);  
      
}