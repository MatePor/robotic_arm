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

float phi, theta, psi, roll, pitch, yaw, da;
float DES_phi, DES_theta, DES_psi, DES_roll, DES_pitch, DES_yaw;
PVector []angles;

boolean grip_on, blocked, magnet;

boolean roll_up, button_is_pressed, keyboard, automatic, 
  recording, inverse, menu_o, inst, docu, auth, mouse_follow, looking, moving, config;

int num_of_things, num_of_c_buttons;

float camX, camY, camD;
PVector camCenter;
PImage roof;


menu my_menu;
thing things[];
Arm robot;
button c_buttons[]; 
button MOVE_B, MGNT_ON, MENU_B, FLY, CONTROLS, ZOOM_IN, ZOOM_OUT, MAN_AUT, INV_KIN, RECORD, MODE_B, CH_EFF;
int mode_num;
String []mode_names = {"MANUAL_B", "EULER_A", "INVERSE_K", "RECORDED_P", "AUTOMATIC"};

public void setup()
{
  
  //surface.setTitle("Robotic Arm 2021");
  //surface.setLocation(30, 30);
  rectMode(CENTER);
  //roof = loadImage("roof.jpg");

  // INITIALIZE VARIABLES
  // camera position angles and distance
  camX = 0;
  camY = 0;
  camD = 1.5f;
  camCenter = new PVector(width/2, height/2 - 100, 0);

  // gripper parameters
  //grip_size = 10;
  //max_grip = 24;
  //grip_on = true;
  blocked = false;

  // angles(position)
  phi = 0;
  theta = PI/4;
  psi = -5*PI/4;
  roll = 0;
  pitch = 0;
  yaw = 0;
  mode_num = 0;
  
  DES_phi = 0;
  DES_theta = 0;
  DES_psi = 0;
  DES_roll = 0;
  DES_pitch = 0;
  DES_yaw = 0;
  
  angles = new PVector[6];
  for (int i = 0; i < 6; i++)
    angles[i] = new PVector(0, 0, 0);

  // angle step
  da = PI/128; 

  // create an arm
  robot = new Arm(angles, new PVector(0, 0, 0), "NUm 1", 26);

  // things
  num_of_things = 1500;
  things = new thing[num_of_things];
  for (int i = 0; i < num_of_things; i++)
  {
    int ran = PApplet.parseInt(random(10, 24));
    boolean ok;
    thing test_thing;

    do
    {
      ok = true;  
      int rand_color = color(random(255), random(255), random(255));
      test_thing = new thing(ran, PApplet.parseInt(random(-100,100)), PApplet.parseInt(random(-5000,-100)), PApplet.parseInt(random(-100, 100)), 0, random(PI), 0, rand_color);
      for (int j = 0; j < i; j++)
        if (isColliding(test_thing, things[j]))
          ok = false;
          
        if(isColliding(test_thing, robot.base))
          ok = false;
    }
    while (!ok);

    things[i] = test_thing;
  }

  // buttons

  MENU_B = new button(80, 20, 160, 40, "MENU");

  //FLY = new button(240, 20, 160, 40, "FLY MODE");
  RECORD = new button(240, 20, 160, 40, "RECORD");
  MODE_B = new button(240, 60, 160, 40, "MANUAL");
  CH_EFF = new button(240, 100, 160, 40, "CHANGE EFFECTOR");
  MOVE_B = new button(240, 140, 160, 40, "MOVE");
  MGNT_ON = new button(240, 180, 160, 40, "MAGN ON");
  
  
  num_of_c_buttons = 14;
  button_is_pressed = false;
  c_buttons = new button[num_of_c_buttons];

  // zoom c_buttons
  ZOOM_IN = new button(width - 47, 54, 56, 70, ""); 
  ZOOM_OUT = new button(width - 47, 143, 56, 70, "");

  // control c_buttons
  int k = 0;
  for (int i = 0; i < num_of_c_buttons; i++)
  {
    c_buttons[i] = new button(100 +(i%2)*40, 100+40*k, 40, 40, (i%2==0)?"+":"-");

    if (i%2 == 1)
      k++;
  }

  // control ON/OFF
  CONTROLS = new button(80, 60, 160, 40, "CONTROLS");

  roll_up = false;

  my_menu = new menu();
  // control booleans (switching modes)
  menu_o = true;
  inst = false;
  docu = false;
  auth = false;
  keyboard = false;
  automatic = false;
  recording = false;
  inverse = false;
  mouse_follow = false;
  looking = false;
  moving = true;
  config = false;
  magnet = false;
}

public void draw()
{
  background(255);
  lights();

  anythingPressed();
  if (menu_o)
  {
    my_menu.BACK_B.pressed = isPressed(my_menu.BACK_B);
    my_menu.openMenu();
  }
  else
  { 
    //check_cursor();
    controls();


    // physics and interaction
    gravity();
    
    if(robot.magn_ON)
       move_object();
     
    pushMatrix();
    cam();

    pushMatrix();
    // keep the same reference frame for all the 
    //translate(-camCenter.x, -camCenter.y, - camCenter.z);
    //translate(width/2, height/2 + 150, 0);

    // roof dome
    translate(0,150,0);
    fill(0, 150, 255);
    noStroke();
    PShape dome = createShape(SPHERE, 1500);
    //dome.disableStyle();
    //dome.setTexture(roof);
    shape(dome);

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

public void cam()
{
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

public void panel()
{
  // INTERFACE
  noFill();
  strokeWeight(2);
  stroke(0);

  if (roll_up)
  {  
    fill(240, 180);
    rect(80, 220, 160, 280);
    rect(240, 40, 160, 80);
    textSize(10);
    textAlign(CENTER, CENTER);
    MODE_B.show();
    RECORD.show();
    CH_EFF.show();
    if(robot.magnetic)
      MGNT_ON.show();
      
    fill(0);
    
    switch(mode_num)
    {
     case 0:
      text("phi: " + toDegr(phi), 40, 100, 76, 38);
      text("theta: "+ toDegr(theta), 40, 140, 76, 38 );
      text("psi: "+ toDegr(psi), 40, 180, 76, 38);
      text("roll: "+ toDegr(roll), 40, 220, 76, 38);
      text("pitch: "+toDegr(pitch), 40, 260, 76, 38);
      text("yaw: "+ toDegr(yaw), 40, 300, 76, 38);
      text("grip size: "+ str(robot.grip_size), 40, 340, 76, 38);
      
      for (int i = 0; i < num_of_c_buttons; i++)
        c_buttons[i].show();
       break;
     case 1: 
      MOVE_B.show();
      text("phi: " + toDegr(DES_phi), 40, 100, 76, 38);
      text("theta: "+ toDegr(DES_theta), 40, 140, 76, 38 );
      text("psi: "+ toDegr(DES_psi), 40, 180, 76, 38);
      text("roll: "+ toDegr(DES_roll), 40, 220, 76, 38);
      text("pitch: "+toDegr(DES_pitch), 40, 260, 76, 38);
      text("yaw: "+ toDegr(DES_yaw), 40, 300, 76, 38);
      text("grip size: "+ str(robot.grip_size), 40, 340, 76, 38);
      
      for (int i = 0; i < num_of_c_buttons; i++)
        c_buttons[i].show();
      
      //for(int i = 0; i < 6; i++)
      //{
         //stroke(0);
         //fill(255);
         //rect(60,100+i*40, 80,40);   
     // }
        
       if(!robot.magnetic)
       {
       c_buttons[12].show();
       c_buttons[13].show();
       }
       break;
     case 2: 
       break;
     case 3:
       break;
     case 4: 
       break;
     case 5: 
       break;
     default: 
       break;
    }
  }

  MagnGlass(width - 50, 44, "+");
  MagnGlass(width - 50, 133, "-");
  ZOOM_IN.x = width - 47;
  ZOOM_OUT.x = width - 47;
  ZOOM_IN.show();
  ZOOM_OUT.show();
  MENU_B.show();
  CONTROLS.show();
}

public void animation()
{
  // FLOOR AND OBJECTS ---------------  
  pushMatrix();
  rotateX(-PI/2);
  fill(200, 150);
  ellipse(0, 0, 3000, 3000);
  popMatrix();

  update_angles();
  robot.updateArm(angles);
  robot.showArm();

  pushMatrix();
  translate(robot.position.x, robot.position.y, robot.position.z);
  translate(robot.effector_pos.x, robot.effector_pos.y, robot.effector_pos.z);
  rotateX(robot.effector_orient.x);
  rotateY(robot.effector_orient.y);
  rotateZ(robot.effector_orient.z);
  noFill();
  strokeWeight(0.1f);
  sphere(30);
  popMatrix();

  for (int i = 0; i < num_of_things; i++)
  {
    //things[i].update(robot.effector_pos, robot.effector_orient);
    things[i].show();
  }
} 

public boolean isPressed(button b)
{
  if (mousePressed && mouseX > b.x-b.w/2 && mouseX < b.x+ b.w/2 
    && mouseY > b.y - b.h/2 && mouseY < b.y + b.h/2)  
    return true;   
  return false;
}

public boolean isColliding(thing A, thing B)
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

public void MagnGlass(int x, int y, String sign)
{
  noFill();
  stroke(0);
  strokeWeight(3);
  ellipse(x, y, 30, 30);
  strokeWeight(7);
  line(x+15*cos(-PI/3), y+15*sin(PI/3), x+35*cos(-PI/3), y+35*sin(PI/3));
  strokeWeight(1);
  textSize(25);
  textAlign(CENTER, CENTER);
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

public void update_angles()
{
  angles[0].y = phi;
  angles[1].z = theta;
  angles[2].z = psi;
  angles[3].y = roll;
  angles[4].z = pitch;
  angles[5].x = yaw;
}

public void move_angles()
{
  phi += signum(DES_phi-phi)*da;
  theta += signum(DES_theta-theta)*da;
  psi += signum(DES_psi-psi)*da;
  roll += signum(DES_roll-roll)*da;
  pitch += signum(DES_pitch-pitch)*da;
  yaw += signum(DES_yaw-yaw)*da;
}

public int signum(float x)
{
  if(x > 0)
    return 1;
  if(x < 0)
    return -1;
 
  return 0; 
}

public void mouseReleased()
{
  if (MENU_B.pressed)
    menu_o = true;
  
  if(roll_up)
  { 
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
    
  if(CH_EFF.pressed)
    {
      robot.magnetic = !robot.magnetic;
    }
    
   if(robot.magnetic && MGNT_ON.pressed)
   {
        robot.magn_ON = !robot.magn_ON;
        
        if(!robot.magn_ON)
        {   
          for(int i = 0; i < num_of_things; i++)
              things[i].caught = false;
              
          MGNT_ON.title = "MGN -ON";
         }
         else 
         MGNT_ON.title = "MGN -OFF";
         
         MGNT_ON.pressed = false;
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
      inst = true;
  
    if (my_menu.DOCUMENTATION.pressed)
      docu = true;
  
    if (my_menu.AUTHOR.pressed)
      auth = true;
  
    if (my_menu.BACK_B.pressed)
    {
      inst = false;
      auth = false;
      docu = false;
    }
  }
}

public void anythingPressed()
{
  button_is_pressed = false;
  ArrayList <Boolean> presses = new ArrayList<Boolean>();

  for (int i = 0; i < num_of_c_buttons; i++)
  {
    c_buttons[i].pressed = isPressed(c_buttons[i]);
    presses.add(c_buttons[i].pressed);
  }

  ZOOM_IN.pressed = isPressed(ZOOM_IN);
  presses.add(ZOOM_IN.pressed);
  ZOOM_OUT.pressed = isPressed(ZOOM_OUT);
  presses.add(ZOOM_OUT.pressed);
  MENU_B.pressed = isPressed(MENU_B);
  presses.add(MENU_B.pressed);
  CONTROLS.pressed = isPressed(CONTROLS);
  presses.add(CONTROLS.pressed);
  MOVE_B.pressed = isPressed(MOVE_B);
  presses.add(MOVE_B.pressed);
  MODE_B.pressed = isPressed(MODE_B);
  presses.add(MODE_B.pressed);
  if(robot.magnetic)
  {    
    MGNT_ON.pressed = isPressed(MGNT_ON);
       presses.add(MGNT_ON.pressed);
  }
  CH_EFF.pressed = isPressed(CH_EFF);
  presses.add(CH_EFF.pressed);
  
  for (int i = 0; i < presses.size(); i++)
    if (presses.get(i))
      button_is_pressed = true;
}

public String toDegr(float x)
{
  float degr_x = 180/PI * x;
  float decimals = degr_x - PApplet.parseInt(degr_x);
  int d1 = PApplet.parseInt(decimals*10);
  int d2 = PApplet.parseInt(decimals*100) - d1;

  if (d2 >= 5)
    d1++;

  float degr = PApplet.parseInt(degr_x) + d1/10;

  return str(degr) + '\u00b0';
}

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
      
    euler_angles();    
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

public void manual_control()
{
  // PHI
      if (c_buttons[0].pressed) 
        phi += da;
      if (c_buttons[1].pressed)
        phi -= da;

      if (phi >= 2*PI)
        phi = 0;
      if (phi <= -2*PI)
        phi = 0;  

      // THETA
      if (c_buttons[2].pressed)
        theta -= da;
      if (c_buttons[3].pressed) 
        theta += da;

      if (theta >= 7*PI/12)
        theta = 7*PI/12;
      if (theta <= -7*PI/12)
        theta = -7*PI/12;

      // PSI
      if (c_buttons[4].pressed)
        psi -= da;
      if (c_buttons[5].pressed) 
        psi += da;     

      if (psi >= 2*PI)
        psi = 0;
      if (psi <= -2*PI)
        psi = 0;

      // ROLL
      if (c_buttons[6].pressed) 
        roll += da;
      if (c_buttons[7].pressed)
        roll -= da;

      if (roll >= 2*PI)
        roll = 0;
      if (phi <= -2*PI)
        roll = 0;  

      // PITCH
      if (c_buttons[8].pressed)
        pitch -= da;
      if (c_buttons[9].pressed) 
        pitch += da;

      if (pitch >= PI/2)
        pitch = PI/2;
      if (pitch <= -PI/2)
        pitch = -PI/2;

      // YAW
      if (c_buttons[10].pressed)
        yaw += da;
      if (c_buttons[11].pressed) 
        yaw -= da;  

      if (yaw >= PI/6)
        yaw = PI/6;
      if (yaw <= -PI/6)
        yaw = -PI/6;

      if (c_buttons[12].pressed)
        robot.grip_size += 1;
      if (c_buttons[13].pressed) 
        robot.grip_size -= 1;  

      if (robot.grip_size >= robot.max_grip)
        robot.grip_size = robot.max_grip;
      if (robot.grip_size <= 0)
        robot.grip_size = 0;
}

public void euler_angles()
{
   
   // PHI
      if (c_buttons[0].pressed) 
        DES_phi += da;
      if (c_buttons[1].pressed)
        DES_phi -= da;

      if (phi >= 2*PI)
        DES_phi = 0;
      if (phi <= -2*PI)
        DES_phi = 0;  

      // THETA
      if (c_buttons[2].pressed)
        DES_theta -= da;
      if (c_buttons[3].pressed) 
        DES_theta += da;

      if (theta >= 7*PI/12)
        DES_theta = 7*PI/12;
      if (theta <= -7*PI/12)
        DES_theta = -7*PI/12;

      // PSI
      if (c_buttons[4].pressed)
        DES_psi -= da;
      if (c_buttons[5].pressed) 
        DES_psi += da;     

      if (psi >= 2*PI)
        DES_psi = 0;
      if (psi <= -2*PI)
        DES_psi = 0;

      // ROLL
      if (c_buttons[6].pressed) 
        DES_roll += da;
      if (c_buttons[7].pressed)
        DES_roll -= da;

      if (roll >= 2*PI)
        DES_roll = 0;
      if (phi <= -2*PI)
        DES_roll = 0;  

      // PITCH
      if (c_buttons[8].pressed)
        DES_pitch -= da;
      if (c_buttons[9].pressed) 
        DES_pitch += da;

      if (pitch >= PI/2)
        DES_pitch = PI/2;
      if (pitch <= -PI/2)
       DES_pitch = -PI/2;

      // YAW
      if (c_buttons[10].pressed)
        DES_yaw += da;
      if (c_buttons[11].pressed) 
        DES_yaw -= da;  

      if (yaw >= PI/6)
        DES_yaw = PI/6;
      if (yaw <= -PI/6)
        DES_yaw = -PI/6;
  
  if (c_buttons[12].pressed)
        robot.grip_size += 1;
     if (c_buttons[13].pressed) 
        robot.grip_size -= 1;  

      if (robot.grip_size >= robot.max_grip)
        robot.grip_size = robot.max_grip;
      if (robot.grip_size <= 0)
        robot.grip_size = 0;
 
}

public void inverse_kinematics()
{
  // mouse mode (w/d)
  // x,y,z
  // 
  //
}

public void recorded_play()
{
  
  
  
}

public void automatic_mode()
{
  
  
  
  
}

public void move_object()
{ 
  for(int i = 0; i < num_of_things; i++)
  {
    thing A = things[i];
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
  
public void gravity()
{
  float g = 0.25f;
 
  for(int i = 0; i < num_of_things; i++)
  {
    if(things[i].pos.y < -things[i].hei/2 && !things[i].caught)
    {   
        things[i].vel.y += g; 
        things[i].pos.y += things[i].vel.y;
    }
    else
    {
       things[i].pos.y = -things[i].hei/2;
       things[i].vel = new PVector(0,0,0);
    } 
   
   
  }   
  
  
  
  
  
}
class Arm
{
  String ID;
  int grip_size,  max_grip;
  private float virt_size, dsize;
  private thing base, gripper, magnet;
  private joint []joints = new joint[6];
  private thing []segments = new thing[6];
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
    
    int grey = color(180);
    base = new thing(50, 0, -25, 0, 0, 0, 0, grey);

    effector_pos = new PVector(0, 0, 0); 
    effector_orient = new PVector(0, 0, 0);

    r[0]= new PVector(0, -56, 0); 
    r[1] = new PVector(0, -24, 0); 
    r[2] = new PVector(0, -80, 0); 
    r[3] = new PVector(0, -36, 0); 
    r[4] = new PVector(0, -39, 0); 
    r[5] = new PVector(0, -4, 0); 

    segments[0] = new thing(26, 40, 26, 0, -16, 0, 0, 0, 0, grey);
    segments[1] = new thing(18, 100, 8, 0, -38, 17, 0, 0, 0, grey);
    segments[2] = new thing(26, 46, 26, 0, -12, 0, 0, 0, 0, grey);
    segments[3] = new thing(16, 28, 16, 0, -14, 0, 0, 0, 0, grey);
    segments[4] = new thing(8, 8, 8, 0, 0, 0, 0, 0, 0, grey);
    segments[5] = new thing(4, 10, 4, 0, -8, 0, 0, 0, 0, grey);

    gripper = new thing(8, 2, max_grip+2, 0, -14, 0, 0, 0, 0, grey);
    magnet = new thing(10, 4, 10, 0, -15, 0, 0, 0, 0, grey);
    
    // decorations 
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
      joints[i] = new joint(r[i], angles[i]);
      effector_orient.add(joints[i].orient);
      effector_pos.add(joints[i].pos);
    }
  }


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

    effector_pos.x = +80*sin(angles[1].z)*cos(angles[0].y)
    +75*sin(angles[1].z + angles[2].z)*cos(angles[0].y);
    //-80*cos(angles[2].z - angles[1].z)*cos(angles[0].y);
    
    effector_pos.y = -80-80*cos(angles[1].z) - 75*cos(angles[1].z + angles[2].z)
     - 20*cos(angles[3].y)*cos(angles[1].z + angles[2].z + angles[4].z)+
     20*sin(angles[3].y)*cos(angles[1].z + angles[2].z + angles[5].x);
    
    effector_pos.z = -80*sin(angles[1].z)*sin(angles[0].y)
    -75*sin(angles[1].z + angles[2].z)*sin(angles[0].y);
    //-80*cos(angles[2].z - angles[1].z)*sin(-angles[0].y);

    // effector_pos.add(new PVector(0, -12, 0));
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
 
    //angles[0].y
    //angles[1].z 
    //angles[2].z 
    //angles[3].y
    //angles[4].z 
    //angles[5].x
    
    if(!magnetic)
      gripper.show();
    else 
      magnet.show();
    /*
    effector_pos.x = modelX(0,0,0);
    effector_pos.y = modelY(0,0,0);
    effector_pos.z = modelZ(0,0,0);
    */
    popMatrix();
  }
}
class button
{
  private int x, y, w, h;
  public String title;
  
  // MAKE PRIVATE AND GET isPressed FUNCTION HERE
  // isPressed needs to be added here so that 
  // everything checking whether is clicked can
  // be done with one line od code 
  // not as it is now
  
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
      textSize(0.4f*h);
      text(title, x, y, w, h);
    }
  }
}
class thing
{
  // position and size
 private PVector pos;
  PVector orient;
  PVector vel;
  int wid, hei, dep;
  int colour;
  PShape obj, cuboid;
  boolean caught;


  thing(int param, int px, int py, int pz, float xangle, float yangle, float zangle, int c)
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

  thing(int pwidth, int pheight, int pdepth, int px, int py, int pz, float xangle, float yangle, float zangle, int c)
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

  public void update(PVector new_pos, PVector new_orient)
  {  
    pos.x = new_pos.x;
    pos.y = new_pos.y;
    pos.z = new_pos.z;
    orient.x = new_orient.x;
    orient.y = new_orient.y;
    orient.z = new_orient.z;
  }
}
class joint
{
  PVector pos;
  PVector orient;

  joint(PVector position, PVector rotations)
  {
    pos = position;
    orient = rotations;
  }

  public void trans()
  {
    translate(pos.x, pos.y, pos.z);
    rotateX(orient.x);
    rotateY(orient.y);
    rotateZ(orient.z);
  }
}
class menu
{
  button START, MENU_B, INSTRUCTIONS, AUTHOR, DOCUMENTATION, BACK_B;
  
  menu()
  {
  START = new button(width/2, height/3, width/2, 70, "START");
  INSTRUCTIONS = new button(width/2, height/3 + 90, width/2, 70, "INSTRUCTIONS");
  DOCUMENTATION = new button(width/2, height/3 + 180, width/2, 70, "DOCUMENTATION");
  AUTHOR = new button(width/2, height/3 + 270, width/2, 70, "AUTHOR");
  BACK_B = new button(100, 100, 80, 80, "BACK");
    
  }
  
  public void openMenu()
 {
  background(0);
  fill(120);
  rect(width/2, height/2, width-100, height-100);

  fill(220);
  textSize(30);
  text("* Robotic Arm Simulator - 2021 *", width/2, 100, width*2/3, 300);
  
  println("work");
  
  START.show();
  INSTRUCTIONS.show();
  DOCUMENTATION.show();
  AUTHOR.show();
  
  START.pressed = isPressed(START);
  INSTRUCTIONS.pressed = isPressed(INSTRUCTIONS);
  DOCUMENTATION.pressed = isPressed(DOCUMENTATION);
  AUTHOR.pressed = isPressed(AUTHOR);

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

public void openDocumentation()
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
