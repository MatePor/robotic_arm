import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class ROBOTIC_ARM_PROJECT extends PApplet {

PVector []angles;
float []ph, max_ph, DEST_ph;
float da;
String [] angle_names = {"ph1:", "ph2:", "ph3:", "ph4:", "ph5:", "ph6:"};

int mode_num;
String []mode_names = {"MANUAL_B", "INPUT_A", "INVERSE_K", "RECORDED_P", "AUTOMATIC"};

boolean grip_on, blocked;

boolean roll_up, button_is_pressed, keyboard, automatic, continuous, flying,
  recording, change, only_ch, init_play, putting, grabbing, menu_o, playing, mouse_follow, full_memo, moving, config;

int num_of_things, num_of_c_buttons;
int range, floor_level, dome_radius, hall_center;   
int MemoIndex, InputIndex, auto_index, tower_size;

float camX, camY, camD;
PVector camCenter, grab_coord, put_coord, tower_coord;
PImage roof;

Menu my_menu;
Memory memory_A;
Thing []things;
Arm robot;
Button []C_BUTTONS;
TextArea[] TXT_A; 
Button MOVE_B, MGNT_ON, MENU_B, FLY, CONTROLS, ZOOM_IN, ZOOM_OUT, MAN_AUT,
 R_MODE, RECORD_B,GO_B, MODE_B, CH_EFF, KEY_BUT, PLAY_R, CONT_B, APPLY, CLR_M;

// ---------------------------------------------- SETUP ----------------------------------------------
public void setup()
{
  
  surface.setTitle("Robotic Arm 2021");
  surface.setLocation(30, 30);
  rectMode(CENTER);
  //roof = loadImage("images/wall.jpg");
  //textureWrap(REPEAT);
  
  textFont(createFont("Arial", 100));
  
  // create menu object
  my_menu = new Menu();
  memory_A = new Memory();
  MemoIndex = 0;
  auto_index = 0;
  tower_size = 0;
  
  // --------- INITIALIZE VARIABLES -------------------
  // camera position angles and distance
  camX = 0;
  camY = 0;
  camD = 1.5f;
  camCenter = new PVector(width/2, height/2 - 100, 0);

  blocked = false;
  
  // inverse kinematics coordinates
  grab_coord = new PVector(0,0,0);
  put_coord = new PVector(0,0,0);
  tower_coord = new PVector(0,0,0); // radius and angle
  
  // angles(position)
  ph = new float[6];
  DEST_ph = new float[6];
  
  ph[0] = 0;
  ph[1] = 0; //PI/4;
  ph[2] = 0; //*PI/4;
  ph[3] = 0;
  ph[4] = 0;
  ph[5] = 0;
 
  DEST_ph[0] = 0;
  DEST_ph[1] = PI/4;
  DEST_ph[2] = -5*PI/4;
  DEST_ph[3] = 0;
  DEST_ph[4] = 0;
  DEST_ph[5] = 0;
  
  max_ph = new float[6];
  
  max_ph[0] = 2*PI;
  max_ph[1] = 7*PI/12; 
  max_ph[2] = 5*PI/6; 
  max_ph[3] = 2*PI;
  max_ph[4] = PI/2;
  max_ph[5] = PI/6;
  
  mode_num = 0;
  angles = new PVector[6];
  for (int i = 0; i < 6; i++)
    angles[i] = new PVector(0, 0, 0);

  // angle step
  da = PI/180; 

  // create an arm
  robot = new Arm(angles, new PVector(0, 0, 0), "NUm 1", 26);

  // environment
  hall_center = width/2;
  floor_level = 0;
  range = 100;
  dome_radius = 1500;
  
  // things (little boxes falling from the sky)
  num_of_things = 3;
  things = new Thing[num_of_things];
  for (int i = 0; i < num_of_things; i++)
  {
    int ran = 0;
    do
    {
      ran = PApplet.parseInt(random(10, 24));
    } while(ran % 2 != 0);
    
    boolean ok;
    Thing test_thing;

    do
    {
      ok = true;  
      int rand_color = color(random(255), random(255), random(255));
      test_thing = new Thing(ran, PApplet.parseInt(random(-range,range)), -500, PApplet.parseInt(random(-range, range)),
      0, random(PI), 0, rand_color);
      
      for (int j = 0; j < i; j++)
        if (isColliding(test_thing, things[j]))
          ok = false;
          
        if(isColliding(test_thing, robot.base))
          ok = false;
          
        if(isCollidingCartesian(test_thing, robot.base))
          ok = false;
    }
    while (!ok);

    things[i] = test_thing;
  }
  sortThings();
  
  // -------------------- BUTTONS ----------------------------
  MENU_B = new Button(80, 20, 160, 40, "MENU");               // back to menu
  ZOOM_IN = new Button(width - 47, 54, 56, 70, ""); 
  ZOOM_OUT = new Button(width - 47, 143, 56, 70, "");
  
  CONTROLS = new Button(80, 60, 160, 40, "CONTROLS");          // control panel ON/OFF
  RECORD_B = new Button(240, 20, 160, 40, "RECORD");             // record START/STOP
  MODE_B = new Button(240, 60, 160, 40, "MANUAL_B");           // change robot working mode
  CH_EFF = new Button(240, 100, 160, 40, "CHANGE EFFECTOR");   // self-explanatory
  KEY_BUT = new Button(240, 140, 160, 40, "KEYBOARD");         // change input between keyboard and button
  MOVE_B = new Button(240, 180, 160, 40, "MOVE");              // emable robot to move
  
  MGNT_ON = new Button(80, 340, 160, 40, "MAGN -ON"); // magnet ON/OFF
  
  PLAY_R = new Button(80, 300, 160, 40, "PLAY_R");
  CLR_M = new Button(80, 340, 160, 40, "CLR DATA"); 
  CONT_B = new Button(80, 140, 160, 40, "CONTINUOUS --");
  R_MODE = new Button(80, 180, 160, 40, "CHANGE ONLY --");
  
  GO_B = new Button(80, 340, 160, 40, "BUILD");
  
  
  // text areas
  TXT_A = new TextArea[6];
  for(int i = 0; i < 6; i++)
    TXT_A[i] = new TextArea(80, 100+40*i, 160, 40, angle_names[i], "");
  InputIndex = -1;
    
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

  // initialize control booleans
  roll_up = false;
  menu_o = true;
  keyboard = false;
  automatic = false;
  recording = false;
  init_play = true;
  playing = false;
  mouse_follow = false;
  full_memo = false;
  flying = false;
  moving = false;
  continuous = false;
  putting = false;
  grabbing = true;
  config = false;
  change = false;
  only_ch = false;
}


// ----------------------------------------------- RESET ----------------------------------------------
public void resetAll()
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
  
  grab_coord = new PVector(0,0,0);
  put_coord = new PVector(0,0,0);
 
  camX = 0;
  camY = 0;
  camD = 1.5f;
  camCenter = new PVector(width/2, height/2 - 100, 0);
  
  mode_num = 0;
  memory_A.clearAll();
  full_memo = false;
  
  for (int i = 0; i < 6; i++)
    angles[i] = new PVector(0, 0, 0);
  
  for (int i = 0; i < num_of_things; i++)
  {
    int ran = PApplet.parseInt(random(10, 24));
    boolean ok;

    do
    {
      ok = true;  
      int rand_color = color(random(255), random(255), random(255));
      
      things[i].changeValues(ran, PApplet.parseInt(random(-range,range)), -600, PApplet.parseInt(random(-range, range)),
      0, random(PI), 0, rand_color);
      
      for (int j = 0; j < i; j++)
        if (isColliding(things[i], things[j]))
          ok = false;
          
        if(isColliding(things[i], robot.base))
          ok = false;
    }
    while (!ok);
  }
   sortThings();
}

// ---------------------------------- CAMERA FUNCTION ----------------------------------------------
public void cam()
{
  // camera position and movement
  if (keyPressed && flying)
  {
    if (key == 'W' || key == 'w')
      camCenter.z += 20;
    if (key == 'S' || key == 's')
      camCenter.z -= 20;
  }

  camCenter.x = width/2;
  camCenter.y = height/2 - 100;

  translate(camCenter.x, camCenter.y, camCenter.z);  
  rotateX(camX);
  rotateY(camY);
  scale(camD);
}

// ------------------------------------------ DRAW FUNCTION  ----------------------------------------
// --------------------------------------------- MAIN LOOP -----------------------------------------
public void draw()
{
  background(255);
  lights();
  
  
  // update hall_center for full screen
  if( width != 400)
    hall_center = width/2;

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
    if(mode_num == 2)
    {
      indSphere(grab_coord, color(0,255,0));
      indSphere(put_coord, color(255,0,0));  
    }
    
    animation();
    popMatrix();
    popMatrix();
 
    // debugging
    /*
    textSize(30);
    text(str(grabbing), 600, 150);
    text(str(putting), 600, 200);
    
    text(str(int(things[0].pos.x)), 400, 50);
    text(str(int(things[0].pos.y)), 500, 50);
    text(str(int(things[0].pos.z)), 600, 50);
    text(str(int(robot.effector_pos.x)), 400, 100); 
    text(str(int(robot.effector_pos.y)), 500, 100);
    text(str(int(robot.effector_pos.z)), 600, 100);
     */
     
    //interface
    panel();
  }
}

// -------------------------- MOUSE AND KEYBOARD FUNCTIONS --------------------------
public void mouseDragged() 
{
  //cursor(MOVE);

  if (!button_is_pressed && !config)
  {
    float sens = 0.01f;
    camX += (pmouseY-mouseY) * sens;
    camY += (mouseX-pmouseX) * sens;

    if (camX > 0)
      camX = 0;
    if (camX < -PI)
      camX = -PI;
  }
}

public void keyReleased()
{
  
  if(key == 'F' || key == 'f')
    flying = !flying;
  
  if(keyboard && InputIndex != -1)
  {
    
    String new_str = "";
    int max_num = 0;
    int InputCounter = TXT_A[InputIndex].txt2.length();
    
    if(TXT_A[InputIndex].txt2.charAt(0) == '-')
      max_num = 4;
    else 
      max_num = 3;
      
    if(InputCounter < max_num)
      switch(key)
      {
        case '-': 
        if(InputCounter == 0)
            TXT_A[InputIndex].txt2 += "-"; break;
        case '0': TXT_A[InputIndex].txt2 += "0"; break;
        case '1': TXT_A[InputIndex].txt2 += "1"; break;
        case '2': TXT_A[InputIndex].txt2 += "2"; break;
        case '3': TXT_A[InputIndex].txt2 += "3"; break;
        case '4': TXT_A[InputIndex].txt2 += "4"; break;
        case '5': TXT_A[InputIndex].txt2 += "5"; break;
        case '6': TXT_A[InputIndex].txt2 += "6"; break;
        case '7': TXT_A[InputIndex].txt2 += "7"; break;
        case '8': TXT_A[InputIndex].txt2 += "8"; break;
        case '9': TXT_A[InputIndex].txt2 += "9"; break;
        case BACKSPACE: new_str = new_str.substring(0,new_str.length() - 2); break;
        case ENTER: 
          if(mode_num == 2)
            ph[InputIndex] = PApplet.parseFloat(new_str);
        default: break;
      }
  }
  
}

public void mouseReleased()
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
  
  if (MODE_B.pressed && !playing && !moving)
    {
      mode_num++;
      if(mode_num > 4)
        mode_num = 0;
      MODE_B.title = mode_names[mode_num];
    }
    
  if((mode_num == 1 || mode_num == 2)&& MOVE_B.pressed)
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
              
         blocked = false;
              
          MGNT_ON.title = "MGN -ON";
         }
         else 
         MGNT_ON.title = "MGN -OFF";
         
         MGNT_ON.pressed = false;
   }        
  }
   if((mode_num == 1 || mode_num == 2) && KEY_BUT.pressed)
   {
     keyboard = !keyboard;
     if(keyboard)
       KEY_BUT.title = "BUTTONS";
     else
       KEY_BUT.title = "KEYBOARD";
   }
   
   if(mode_num == 4 && GO_B.pressed)
    {
      moving = !moving;
        
      if(moving) 
        GO_B.title = "STOP";
      else
        GO_B.title = "BUILD";
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
       if(memory_A.getSize() != 0)
       {
         playing = !playing;
         
         if(playing)
           PLAY_R.title = "STOP_R";
         else
           PLAY_R.title = "PLAY_R";    
       }
     }
   }
  }
  
  if(keyboard && mode_num != 1 && mode_num != 3)
  {
    InputIndex = -1;
    for(int i = 0; i < 6 - PApplet.parseInt(mode_num == 5)*3; i++)
      if(TXT_A[i].pressed)
      {
        TXT_A[i].ente = true;
        InputIndex = i;
        for(int j = 0; j < 6 - PApplet.parseInt(mode_num == 5)*3; j++)
          if(j != i)
            TXT_A[i].ente = false;
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
  
    if (my_menu.AUTHOR.pressed)
      my_menu.auth = true;
  
    if (my_menu.BACK_B.pressed)
    {
      my_menu.inst = false;
      my_menu.auth = false;
    }
    
    if(my_menu.RESET_B.pressed)
       resetAll(); 
   
  }
}


public void mouseWheel(MouseEvent event)
 {
 float sens = 0.1f;
 camD -= event.getCount()*sens;
 
 if(camD < 0.5f )
 camD = 0.5f;
 
 if(camD > 4.1f )
 camD = 4.1f;
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

// ------------------------------- DRAWING INTERFACE ---------------------------------------------
public void panel()
{
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
    if(!recording)
    {
      fill(0,255,100);
      triangle(292,27,292,13,307,20);
    }
    else
    {
      fill(255,0,0);
      rect(300,20,16,16); 
      fill(255);
      textSize(30);
      text(" recording... ", width/2, 20);
    }
    popStyle();
      
    if(mode_num < 2)
    { 
      if(robot.magnetic) 
        MGNT_ON.show();
      CH_EFF.show();
    }
      
    switch(mode_num)
    {
     case 0:
     
      pushStyle();
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
        text("grip size :"+ str(robot.grip_size), 40, 340, 76, 38);;
      }  
      
      for (int i = 0; i < (num_of_c_buttons - PApplet.parseInt(robot.magnetic)*2); i++)
        C_BUTTONS[i].show();
        
       popStyle();
       break;
       
     case 1: 
      MOVE_B.show();
      //KEY_BUT.show();
      
      pushStyle();
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
        text("grip size :"+ str(robot.grip_size), 40, 340, 76, 38);
      }
      
        for (int i = 0; i < (num_of_c_buttons - PApplet.parseInt(robot.magnetic)*2); i++)
          C_BUTTONS[i].show();
      }
      else
      {
        for(int i = 0; i < 6; i++)
            TXT_A[i].show();    
       if(!robot.magnetic)
       {
          textAlign(LEFT, CENTER);
          text("grip size :"+ str(robot.grip_size), 40, 340, 76, 38);
          C_BUTTONS[12].show();
          C_BUTTONS[13].show();
       }       
      }   
      
      popStyle();
      break;
       
     case 2: 
       MOVE_B.show();
       //KEY_BUT.show();
       
       pushStyle();
      if(!keyboard)
      { 
        textSize(13);
        fill(0);
        textAlign(LEFT, CENTER);
        text("grab X:", 30, 100, 58, 38);
        text("grab Y:", 30, 140, 58, 38);
        text("grab Z:", 30, 180, 58, 38);
        text("put X:", 30, 220, 58, 38);
        text("put Y:", 30, 260, 58, 38);
        text("put Z:", 30, 300, 58, 38);
        textAlign(RIGHT, CENTER);
        text(str(grab_coord.x), 52, 100, 44, 38);
        text(str(grab_coord.y), 52, 140, 44, 38);
        text(str(grab_coord.z), 52, 180, 44, 38);
        text(str(put_coord.x), 52, 220, 44, 38);
        text(str(put_coord.y), 52, 260, 44, 38);
        text(str(put_coord.z), 52, 300, 44, 38);
        
        for (int i = 0; i < num_of_c_buttons - 2; i++)
          C_BUTTONS[i].show();
      }
      else
      {
        for(int i = 0; i < 6; i++)
            TXT_A[i].show();           
      }
      
     popStyle();
     break;
       
     case 3:
       PLAY_R.show();
       CONT_B.show();
       CLR_M.show();
       R_MODE.show();
      
       textSize(15);
       text("RECORDING MODE", 80, 100, 160, 40);
     
       if(memory_A.getSize() != 0)
       {
         fill(0,255,0);
         textSize(15);
         text("RECORDED", 70, 240, 160, 40);
         
       }
       else
       {
         fill(130);
         textSize(15);
         text("NO RECORDS", 70, 240, 160, 40);
       }
       
       ellipse(140, 240, 15,15);
       
      
      pushStyle();
      if(!playing)
       {
         fill(0,255,100);
         triangle(132,307,132,293,147,300);
       }
      else
      {
        fill(255,0,0);
        rect(140,300,16,16); 
        fill(255);
        textSize(30);
        text(" playing ", width/2, 20);
      }
       
       fill(130);
       if(continuous)
          fill(0,255,0);     
       ellipse(140, 140, 15,15);
       
       fill(130);
       if(only_ch) 
         fill(0,255,0);
           ellipse(140, 180, 15, 15);
       
       popStyle();
       break;
       
     case 4: 
      GO_B.show();
      
      for(int i = 0; i < 4; i++)
        C_BUTTONS[i].show();
        
        pushStyle();
       
        textSize(11);
        fill(0);
        textAlign(LEFT, CENTER);
        text("towerX:", 30, 100, 52, 38);
        textAlign(RIGHT, CENTER);
        text(str(tower_coord.x), 50, 100, 58, 38);
        textAlign(LEFT, CENTER);
        text("towerZ:", 30, 140, 52, 38);
        textAlign(RIGHT, CENTER);
        text(str(tower_coord.z), 50, 140, 58, 38);
        
       popStyle();
       
       break;
       
     default: 
       break;
    }
  }
}

public String toDegr(float x)
{
  float degr_x = 180/PI * x;
  float decimals = degr_x - PApplet.parseInt(degr_x);
  int d1 = PApplet.parseInt(decimals*10);
  int d2 = PApplet.parseInt(decimals*100) - d1;

  if (d2 >= 5)
    d1++;

  float degr = PApplet.parseInt(degr_x) + PApplet.parseFloat(d1)/10;

  return str(degr) + '\u00b0';
}

// ------------------------------------------------ DRAWING ENVIRONMENT -----------------------------------------
public void MagnGlass(int x, int y, String sign)
{
  pushStyle();
  noFill();
  stroke(0);
  strokeWeight(3);
  ellipse(x, y, 30, 30);
  strokeWeight(7);
  line(x+15*cos(-PI/3), y+15*sin(PI/3), x+35*cos(-PI/3), y+35*sin(PI/3));
  strokeWeight(1);
  textSize(32);
  fill(255);
  textAlign(CENTER, CENTER);
  text(sign, x, y-3, 40, 40);
  popStyle();
}

public void drawLab()
{
   // FLOOR AND DOME --------------- 
   // roof dome
   stroke(0);
   strokeWeight(0.5f);
   fill(0,140,255);
   PShape dome = createShape(SPHERE, dome_radius);
   dome.disableStyle();
   //dome.setTexture(roof);
   shape(dome);
    
   pushMatrix();
   rotateX(-PI/2);
   fill(150);
   ellipse(0, 0, 2*dome_radius, 2*dome_radius);
   popMatrix();
}

public void indSphere(PVector vec, int c)
{
  pushMatrix();
  pushStyle();
  translate(vec.x,vec.y,vec.z);
  noFill();
  stroke(c);
  strokeWeight(0.1f);
  sphere(20);
  popStyle();
  popMatrix();
}

// --------------------------------------- ANIMATIONS ---------------------------------------
public void animation()
{
  // physics and interaction
 
  update_angles();
  robot.updateArm(angles);
  robot.showArm();
  
  gravity();
    
  if(robot.magnetic && robot.magn_ON)
    move_object();
       
  for (int i = 0; i < num_of_things; i++)
  { 
    if(things[i].caught && blocked)
    {
      things[i].pos.x = robot.effector_pos.x;
      things[i].pos.y = robot.effector_pos.y;
      things[i].pos.z = robot.effector_pos.z;
      things[i].orient = robot.effector_orient;
    }
   else
   {
     if(!isCollidingCartesian(things[i], robot.base) || things[i].pos.y < -80-things[i].hei/2)
       {
         things[i].vel.x = 0;
         things[i].vel.z = 0;
         things[i].pos.add(things[i].vel);   
       }
      else if(things[i].pos.y >= -80-3*things[i].hei/4)
       {
         things[i].vel.y = 0;
         if(robot.base.pos.x - things[i].pos.x < robot.base.pos.z - things[i].pos.z)
           things[i].vel.x = 4;
         else 
           things[i].vel.z = 4;
       }
       
       things[i].pos.add(things[i].vel);   
   }
     
    things[i].show();
  }

  //indSphere(robot.effector_pos, color(255,255,0));
  
  if(mode_num == 4)
  {   
    tower_coord.y = 0;
    indSphere(tower_coord, color(0,0,255));
    tower_coord.y = tower_size - 30;
  }
} 

// ----------------------------------- CHECKING FOR PRESSED BUTTONS ------------------------------
public void anythingPressed()
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
  
  if(keyboard && mode_num != 1 && mode_num != 3)
    for(int i = 0; i < 6 - PApplet.parseInt(mode_num == 5)*3; i++)
      {
        TXT_A[i].isPressed();
        
        if(TXT_A[i].pressed)
          InputIndex = i;
      }
  
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
  
  /*
  if(mode_num == 1 || mode_num == 2)
  {
    KEY_BUT.isPressed();
    presses.add(KEY_BUT.pressed);
  }
  */
  
  if(mode_num == 4)
  {
    for(int i = 0; i < 4; i++)
    {
       C_BUTTONS[i].isPressed();
      presses.add(C_BUTTONS[i].pressed); 
    }
    
     GO_B.isPressed();
     presses.add(GO_B.pressed);
  }
  
  
  CH_EFF.isPressed();
  presses.add(CH_EFF.pressed);
  
  for (int i = 0; i < presses.size(); i++)
    if (presses.get(i))
      button_is_pressed = true;
}

// ------------------------------------- OTHER CONTROL AND UPDATING FUNCTIONS -------------------------------------
public void update_angles()
{
  angles[0].y = ph[0];
  angles[1].z = ph[1];
  angles[2].z = ph[2];
  angles[3].y = ph[3];
  angles[4].z = ph[4];
  angles[5].z = ph[5];
}

public void move_angles()
{
  ph[0] += signum(DEST_ph[0]-ph[0])*da/2;
  ph[1] += signum(DEST_ph[1]-ph[1])*da/2;
  ph[2] += signum(DEST_ph[2]-ph[2])*da/2;
  ph[3] += signum(DEST_ph[3]-ph[3])*da/2;
  ph[4] += signum(DEST_ph[4]-ph[4])*da/2;
  ph[5] += signum(DEST_ph[5]-ph[5])*da/2;
  
  boolean finished_init = true;
    
  for(int i = 0; i < 6; i++)
  {
    if(signum(DEST_ph[i]-ph[i]) != 0)
      finished_init = false;
  }
    
  if(playing && init_play)
    if(finished_init)
        init_play = false;
      
  if(mode_num == 2 || mode_num == 4)
  {
   if(grabbing && finished_init)
   {
     grabbing = false;
     robot.magn_ON = true;
     putting = true;
     
   }
   else if(putting && finished_init)
   {
     putting = false;
     grabbing = true;
     robot.magn_ON = false;
     
     if(mode_num == 4)
       if(auto_index < num_of_things - 1)
       {
         tower_size += things[auto_index].hei;
         auto_index++;
       }
       else
       {
         auto_index = 0;
         moving = false;
         tower_size = 0;
         GO_B.title = "BUILD";
       }
   }
 }
}

public int signum(float x)
{
  if(x > da/4)
    return 1;
  if(x < -da/4)
    return -1;
 
  return 0; 
}

  
public void sortThings()
{
  Thing temp;

  for(int i = 0; i < num_of_things - 1; i++)
  {
    int j = i+1;
    temp = things[i];
   
    while(things[i].dep > things[j].dep && j < num_of_things - 2)
    {
       things[i] = things[j]; 
       j++;
    }
    
    things[j] = temp;    
   }
}

 public void invKin(PVector coord)
 {
   DEST_ph[0] = atan2(-coord.z, coord.x);  
   DEST_ph[2] = -acos((coord.x*coord.x + coord.y*coord.y -17425)/16800);
   DEST_ph[1] = atan2(coord.y,coord.x)-asin((105*sin(DEST_ph[2]))/sqrt(coord.x*coord.x + coord.y*coord.y)) - PI;     
 } 

// -------------------------------------------------- MAIN CONTROLS ------------------------------------------------
public void controls()
{
  // camera motion and screen display
  // zoom in/zoom out
  if (ZOOM_IN.pressed) 
    camD += da;
  else if (ZOOM_OUT.pressed)
    camD -= da;

  if (camD < 0.5f)
    camD = 0.5f;

  if (camD > 4.1f )
    camD = 4.1f;
  
  if(recording)
    if(memory_A.getSize() != 2147483645)
      writeRecord();
    else 
    {
      recording = false;
      RECORD_B.title = "RECORD";
      full_memo = true;
    }
      
  // menu/instructions
  if (roll_up)
  { 
    switch(mode_num)
    {
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
        if(moving)
          move_angles();  
        break;
     case 3:
       if(playing && init_play)
          move_angles();
        recorded_play();
        break;
     case 4:
        if(moving)
          move_angles();
        automatic_mode();
     
        break;
     default:
        break;
    }
  }
  
}


// ------------------------------------------- MANUAL CONTROL ----------------------------------
public void manual_control()
{
  for(int i = 0; i < 8; i += 2)
  {
    if(C_BUTTONS[i].pressed)
      if(!effCollides(ph[0] + PApplet.parseInt(i == 0)*5*da,ph[1] - PApplet.parseInt(i == 2)*5*da,ph[2] + PApplet.parseInt(i == 4)*5*da))
        ph[i/2] += da;
    if(C_BUTTONS[i+1].pressed) 
      if(!effCollides(ph[0] - PApplet.parseInt(i == 1)*5*da,ph[1] - PApplet.parseInt(i == 3)*5*da,ph[2] - PApplet.parseInt(i == 5)*5*da))
        ph[i/2] -= da;  

    if (ph[i/2] > max_ph[i/2])
      ph[i/2] = max_ph[i/2];
    if (ph[i/2] < -max_ph[i/2])
      ph[i/2] = -max_ph[i/2];
  }
  
  if (C_BUTTONS[12].pressed)
    robot.grip_size += 1;
  if (C_BUTTONS[13].pressed) 
    robot.grip_size -= 1;  

  if (robot.grip_size >= robot.max_grip)
    robot.grip_size = robot.max_grip;
  if (robot.grip_size <= 0)
    robot.grip_size = 0;
}

// --------------------------------- INPUT ANGLES -------------------------------------------
public void input_angles()
{
   if(!keyboard)
   {
     for(int i = 0; i < 8; i += 2)
    {
    if(C_BUTTONS[i].pressed)
        DEST_ph[i/2] += da;
    if(C_BUTTONS[i+1].pressed) 
        DEST_ph[i/2] -= da;  

    if (DEST_ph[i/2] > max_ph[i/2])
      DEST_ph[i/2] = max_ph[i/2];
    if (DEST_ph[i/2] < -max_ph[i/2])
      DEST_ph[i/2] = -max_ph[i/2];
    }
   }
   
   if (C_BUTTONS[12].pressed)
    robot.grip_size += 1;
  if (C_BUTTONS[13].pressed) 
    robot.grip_size -= 1;  

  if (robot.grip_size >= robot.max_grip)
    robot.grip_size = robot.max_grip;
  if (robot.grip_size <= 0)
    robot.grip_size = 0;
 
}

// ------------------------------------------- INVERSE KINEMATICS ---------------------------------------------------
public void inverse_kinematics()
{
  if(!keyboard)
  {
      if (C_BUTTONS[0].pressed) 
        grab_coord.x ++;
      if (C_BUTTONS[1].pressed)
        grab_coord.x --; 

      if (C_BUTTONS[2].pressed)
        grab_coord.y ++;
      if (C_BUTTONS[3].pressed) 
        grab_coord.y --;

      if (C_BUTTONS[4].pressed)
        grab_coord.z ++;
      if (C_BUTTONS[5].pressed) 
        grab_coord.z --;

      if (C_BUTTONS[6].pressed) 
        put_coord.x ++;
      if (C_BUTTONS[7].pressed)
        put_coord.x --;

      if (C_BUTTONS[8].pressed)
        put_coord.y ++;
      if (C_BUTTONS[9].pressed) 
        put_coord.y --;

      if (C_BUTTONS[10].pressed)
        put_coord.z ++;
      if (C_BUTTONS[11].pressed) 
        put_coord.z --;
    }    
    
   if(grabbing)
      invKin(grab_coord);
   if(putting)
      invKin(put_coord);
}

// -------------------------------------------- RECORDED PLAY ------------------------------------------
public void recorded_play()
{  
  // read the memory and act appropriately 
   if(memory_A.checkSize(MemoIndex)) 
   { 
     if(playing)   
       translateMemory();      
   }
   else
   {
     if(continuous)
     { 
        MemoIndex = 0;
        init_play = true;
     }
     else 
     {  
       MemoIndex = 0;
       playing = false;
     }
   }
}

// --------------------------------------- AUTOMATIC MODE ----------------------------------------------------
public void automatic_mode()
{
  if(!keyboard)
  {
     // check whether the point is within arm's range
    
    if(C_BUTTONS[0].pressed)   
      if(tower_coord.x + 1  < 120)
        tower_coord.x ++;
    if(C_BUTTONS[1].pressed)
     if(tower_coord.x - 1  > -120)
      tower_coord.x --; 

    if(C_BUTTONS[2].pressed)
      if(tower_coord.z + 1  < 120)
        tower_coord.z ++;
    if(C_BUTTONS[3].pressed) 
     if(tower_coord.z - 1  > -120)
        tower_coord.z --;
   }
   
    tower_coord.y = tower_size - 30;
    
    if(grabbing)
      invKin(things[auto_index].pos);
    if(putting)
      invKin(tower_coord);
  
}

// ----------------------------------------------- PHYSICS AND INTERACTIONS -------------------------------------------------------------------
public void move_object()
{ 
  for(int i = 0; i < num_of_things; i++)
  {
    float r = sqrt(3*(things[i].dep/2)*(things[i].dep/2));
    float distance = sqrt(pow(things[i].pos.x-robot.effector_pos.x, 2)+pow(things[i].pos.y-robot.effector_pos.y, 2)+pow(things[i].pos.z-robot.effector_pos.z, 2));

    if (distance < r + 20)
    {
        things[i].caught = true;
        things[i].vel = new PVector(0,0,0);
        blocked = true;
    } 
   }   
}
  
public void gravity()
{
  float g = 0.25f;
 
  for(int i = 0; i < num_of_things; i++)
  {
    if(!things[i].caught)
    {
       if(things[i].pos.y < -things[i].hei/2)
         things[i].vel.y += g;
        else
        {
           things[i].pos.y = -things[i].hei/2;
           things[i].vel = new PVector(0,0,0);
        }
    }
  }   
  
}

// -------------------------------------------------- MEMORY FUNCTIONS ---------------------------------------------------
public void translateMemory()
{
  float []readData = memory_A.readMemo(MemoIndex);
  int action_reader = -1;
  
  if(MemoIndex == 0 && init_play)
  {
    DEST_ph[0] = readData[3];
    DEST_ph[1] = readData[4];
    DEST_ph[2] = readData[5];
    DEST_ph[3] = readData[6];
    DEST_ph[4] = readData[7];
    DEST_ph[5] = readData[8];
    action_reader = PApplet.parseInt(readData[9]);
  }
  else
  {
    robot.effector_pos.x = readData[0];
    robot.effector_pos.y = readData[1];
    robot.effector_pos.z = readData[2];
    ph[0] = readData[3];
    ph[1] = readData[4];
    ph[2] = readData[5];
    ph[3] = readData[6];
    ph[4] = readData[7];
    ph[5] = readData[8];
    action_reader = PApplet.parseInt(readData[9]);
  }
  
  if(!init_play) 
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

public void writeRecord()
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

// ------------------------------- COLLISION DETECTION -----------------------

public boolean isColliding(Thing A, Thing B)
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


public boolean isCollidingCartesian(Thing A, Thing B)
{
  float rA = sqrt(2)*A.dep/2;
  float rB = sqrt(2)*B.dep/2;

  float distance = sqrt(pow(A.pos.x-B.pos.x, 2)+pow(A.pos.z-B.pos.z, 2));

  if (distance < rA+rB)
    return true;

  return false;
   
}

public boolean isColliding(PVector pos1, float r1, PVector pos2, float r2)
{
 if(pos1.dist(pos2) < r1 + r2)
    return true;
 else 
   return false;
}

public boolean effCollides(float phi, float theta, float psi)
{
    PVector new_eff_pos = new PVector(0,0,0);
    new_eff_pos.x = 80*cos(phi)*sin(theta)
    +112*cos(phi)*sin(theta + psi);
    new_eff_pos.y = -80-80*cos(theta)-112*cos(theta + psi);
    new_eff_pos.z = -80*sin(phi)*sin(theta)
    -112*sin(phi)*sin(theta + psi);
    
    if(!robot.magnetic)
      for(int i = 0; i < num_of_things; i++)
        if(isColliding(new_eff_pos, 2, things[i].pos, sqrt(3*pow(things[i].dep/2,2))))
          return true;
        
    for(int i = 1; i < 3; i++)
      if(isColliding(new_eff_pos, 4, robot.base.pos, sqrt(3*pow(robot.base.dep/2,2))))
          return true;
          
    if(new_eff_pos.y > -5)
          return true;
          
    return false;
}
class Arm
{
  String ID;
  int grip_size,  max_grip;
  private float virt_size, dsize;
  private Thing base, gripper, magnet;
  private Joint []joints = new Joint[6];
  private Thing []segments = new Thing[6];
  PVector []r = new PVector[6];
  PVector effector_pos, effector_orient;
  PVector position;
  PVector []effector_pos_history;
  PVector []move_history;
  public boolean magnetic, magn_ON;

  Arm(PVector []angles, PVector pos, String ID_, int max_grip_)
  {
    position = pos;
    
    ID = ID_;
    max_grip = max_grip_;
    grip_size = 0;
    virt_size = 0;
    dsize = 0.5f;
    magnetic = false;
    magn_ON = false;
    
    int grey = color(55);
    int red = color(210, 0, 0);
    
    effector_pos = new PVector(0, 0, 0); 
    effector_orient = new PVector(0, 0, 0);

    r[0]= new PVector(0, -56, 0); 
    r[1] = new PVector(0, -24, 0); 
    r[2] = new PVector(0, -80, 0); 
    r[3] = new PVector(0, -36, 0); 
    r[4] = new PVector(0, -39, 0); 
    r[5] = new PVector(0, -4, 0); 
    
    base = new Thing(50, 0, -25, 0, 0, 0, 0, red);
    segments[0] = new Thing(26, 40, 26, 0, -16, 0, 0, 0, 0, red);
    segments[1] = new Thing(18, 100, 8, 0, -38, 17, 0, 0, 0, grey);
    segments[2] = new Thing(26, 46, 26, 0, -12, 0, 0, 0, 0, red);
    segments[3] = new Thing(16, 28, 16, 0, -14, 0, 0, 0, 0, grey);
    segments[4] = new Thing(8, 8, 8, 0, 0, 0, 0, 0, 0, red);
    segments[5] = new Thing(4, 10, 4, 0, -8, 0, 0, 0, 0, red);

    gripper = new Thing(8, 2, max_grip+2, 0, -14, 0, 0, 0, 0, grey);
    magnet = new Thing(10, 4, 10, 0, -15, 0, 0, 0, 0, grey);
    
    // ---------------------------------------- DECORATIONS ---------------------------------------
    PShape sp_1 = createShape(SPHERE, 10);
    sp_1.translate(0, 20, 0);
    segments[0].obj.addChild(sp_1);
    
    PShape elem_1 = createShape(BOX, 18, 100, 8);
    elem_1.translate(0, 0, -34);
    segments[1].obj.addChild(elem_1);
    
    PShape left_part = createShape(BOX, 10, 14, 2);
    PShape right_part = createShape(BOX, 10, 14, 2);
    left_part.translate(0, -22, -5);  
    right_part.translate(0, -22, 5); 
    segments[3].obj.addChild(left_part);
    segments[3].obj.addChild(right_part);

    PShape wrist = createShape(SPHERE, 4);
    wrist.translate(0, -4, 0);
    wrist.setStroke(220);
    segments[4].obj.addChild(wrist);
    
    PShape grip_l = createShape(BOX, 8, 8, 1);
    PShape grip_r = createShape(BOX, 8, 8, 1);
    grip_l.translate(0, -5, 0.5f);  
    grip_r.translate(0, -5, -0.5f); 
    gripper.obj.addChild(grip_l);
    gripper.obj.addChild(grip_r);

    for (int i = 0; i < 6; i++)
    {
      joints[i] = new Joint(r[i], angles[i]);
      effector_orient.add(joints[i].orient);
      effector_pos.add(joints[i].pos);
    }
  }

  // ------------------------------- UPDATE ARM ----------------------------------------------
  public void updateArm(PVector []angles)
  {
    PVector zeros = new PVector(0,0,0);
    effector_orient = zeros;
    
    if(virt_size == grip_size)
       dsize = 0;
    if(virt_size < grip_size)
       dsize = 0.1f;
    if(virt_size > grip_size)
       dsize = -0.1f;
       
     gripper.obj.getChild(1).translate(0, 0, dsize);  
     gripper.obj.getChild(2).translate(0, 0, -dsize); 
     virt_size += 2*dsize;
        
    for (int i = 0; i < 6; i++)
    {
      joints[i].orient = angles[i];
      effector_orient.add(angles[i]);
    } 

    // ---------------------------------- CALCULATING EFFECTOR POSITION -----------------------------------
   
    effector_pos.x = +80*cos(angles[0].y)*sin(angles[1].z)
    +105*cos(angles[0].y)*sin(angles[1].z + angles[2].z);
    effector_pos.y = -80-80*cos(angles[1].z)-105*cos(angles[1].z + angles[2].z);
    effector_pos.z = -80*sin(angles[0].y)*sin(angles[1].z)
    -105*sin(angles[0].y)*sin(angles[1].z + angles[2].z);
    
    joints[1].actual_pos.x = 0;
    joints[1].actual_pos.y = 0;
    joints[1].actual_pos.z = -80;
    joints[2].actual_pos.x = +80*cos(angles[0].y)*sin(angles[1].z);
    joints[2].actual_pos.y = -80-80*cos(angles[1].z);
    joints[2].actual_pos.z = -80*sin(angles[0].y)*sin(angles[1].z);
    
  }
 
  public void showArm()
  {
    pushMatrix();
    translate(position.x, position.y, position.z);
    base.show();
    for (int i = 0; i < 6; i++)
    {
      joints[i].trans();
      segments[i].show();
    } 
    
    if(!magnetic)
      gripper.show();
    else 
      magnet.show();

    popMatrix();
  }
}
class Button
{
  // coordinates, width and height
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
      textSize(0.4f*h);
      textAlign(CENTER, CENTER);
      text(title, x, y, w, h);
    }
  }
}
class Thing
{
  // position and size
  PVector pos;
  PVector orient;
  PVector vel;
  int wid, hei, dep;
  int colour;
  PShape obj, cuboid;
  boolean caught;

  Thing(int param, int px, int py, int pz, float xangle, float yangle, float zangle, int c)
  {
    obj = createShape(GROUP);

    pos = new PVector(px, py, pz);
    orient = new PVector(xangle, yangle, zangle);
    vel = new PVector(0,0,0);
    
    caught = false;
    
    dep = param;
    wid = param;
    hei = param;

    cuboid = createShape(BOX, wid, hei, dep);
    obj.addChild(cuboid);

    colour = c;
  }

  Thing(int pwidth, int pheight, int pdepth, int px, int py, int pz, float xangle, float yangle, float zangle, int c)
  {
    obj = createShape(GROUP);

    pos = new PVector(px, py, pz);
    orient = new PVector(xangle, yangle, zangle);
    vel = new PVector(0,0,0);
    
    caught = false;
    
    wid = pwidth;
    hei = pheight;
    dep = pdepth;

    cuboid = createShape(BOX, wid, hei, dep);
    obj.addChild(cuboid);

    colour = c;
  }
  
  public void changeValues(int param, int px, int py, int pz, float xangle, float yangle, float zangle, int c)
  {
    pos = new PVector(px, py, pz);
    orient = new PVector(xangle, yangle, zangle);
    vel = new PVector(0,0,0);   
    caught = false;   
    dep = param;
    wid = param;
    hei = param;
    colour = c;
    cuboid = createShape(BOX, wid, hei, dep);
    obj.removeChild(0);
    obj.addChild(cuboid);
  }

 public void update(PVector new_pos, PVector new_orient)
  {  
    pos.x = new_pos.x;
    pos.y = new_pos.y;
    pos.z = new_pos.z;
    orient.x = new_orient.x;
    orient.y = new_orient.y;
    orient.z = new_orient.z;
  }
  
  public void show()
  {  
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    rotateX(orient.x);
    rotateY(orient.y);
    rotateZ(orient.z);
    fill(colour);
    //noStroke();
    stroke(0);
    strokeWeight(1);
    obj.disableStyle();
    shape(obj);
    popMatrix();
  }
}
class Joint
{
  PVector pos;
  PVector orient;
  PVector actual_pos;

  Joint(PVector position, PVector rotations)
  {
    pos = position;
    orient = rotations;
    actual_pos = new PVector(0,0,0);
  }

  public void trans()
  {
    translate(pos.x, pos.y, pos.z);
    rotateX(orient.x);
    rotateY(orient.y);
    rotateZ(orient.z);
  }
}
class Memory
{
  // record storage
  private ArrayList <PVector> pos;
  private ArrayList <PVector> ang;
  private ArrayList <PVector> ori; 
  private IntList action; 
  private int MemoSize;
  float []dataArray;
  
  Memory()
  {
    pos = new ArrayList<PVector>();
    ang = new ArrayList<PVector>();
    ori = new ArrayList<PVector>();
    action = new IntList();
    MemoSize = 0;
    dataArray = new float[10];
    for(int i = 0; i < 10; i++)
       dataArray[i] = 0;
  }
  
  public void clearAll()
  {
    
    if(MemoSize != 0)
      pos.clear();
    if(MemoSize != 0)
      ang.clear();
    if(MemoSize != 0)
      ori.clear();
    if(MemoSize != 0)
      action.clear(); 
      
     MemoSize = 0;  
  }
  
  public float[] readMemo(int index)
  {   
    if(index < MemoSize)
    {    
      dataArray[0] = pos.get(index).x; 
      dataArray[1] = pos.get(index).y; 
      dataArray[2] = pos.get(index).z; 
      dataArray[3] = ang.get(index).x;
      dataArray[4] = ang.get(index).y;
      dataArray[5] = ang.get(index).z;
      dataArray[6] = ori.get(index).x;
      dataArray[7] = ori.get(index).y;
      dataArray[8] = ori.get(index).z;
      dataArray[9] = PApplet.parseFloat(action.get(index)); 
    }  
      return dataArray; 
  }

  public void writeMemo(PVector position, PVector angle, PVector orient,int c)
  {
    pos.add(position);
    ang.add(angle);
    ori.add(orient);
    action.append(c); 
    MemoSize++; 
  }
  
  public boolean checkSize(int index)
  {
    if(index < MemoSize)
      return true;
    
    return false;
  }
  
  public int getSize()
  {
    return MemoSize;
  }
  
  public void saveToFile()
  {
    //create and write to file
  
  
  }
  
} 
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
      textSize(0.4f*h);
      textAlign(CENTER, CENTER);
      text(title, x-w/4, y, w/2, h/2);
      text(txt2, x+w/4,y, w/2, h/2);
    }
  }
} 
  public void settings() {  size(800, 600, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "ROBOTIC_ARM_PROJECT" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
