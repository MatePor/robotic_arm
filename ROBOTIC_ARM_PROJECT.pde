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

void setup()
{
  size(800, 600, P3D);
  //surface.setTitle("Robotic Arm 2021");
  //surface.setLocation(30, 30);
  rectMode(CENTER);
  //roof = loadImage("roof.jpg");

  // INITIALIZE VARIABLES
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
  num_of_things = 1;
  things = new thing[num_of_things];
  for (int i = 0; i < num_of_things; i++)
  {
    int ran = int(random(10, 24));
    boolean ok;
    thing test_thing;

    do
    {
      ok = true;  
      color rand_color = color(random(255), random(255), random(255));
      test_thing = new thing(ran, int(random(-100,100)), - ran/2, int(random(-100, 100)), 0, random(PI), 0, rand_color);
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

void draw()
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

void panel()
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

void animation()
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
  strokeWeight(0.1);
  sphere(30);
  popMatrix();

  for (int i = 0; i < num_of_things; i++)
  {
    //things[i].update(robot.effector_pos, robot.effector_orient);
    things[i].show();
  }
} 

boolean isPressed(button b)
{
  if (mousePressed && mouseX > b.x-b.w/2 && mouseX < b.x+ b.w/2 
    && mouseY > b.y - b.h/2 && mouseY < b.y + b.h/2)  
    return true;   
  return false;
}

boolean isColliding(thing A, thing B)
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

void update_angles()
{
  angles[0].y = phi;
  angles[1].z = theta;
  angles[2].z = psi;
  angles[3].y = roll;
  angles[4].z = pitch;
  angles[5].x = yaw;
}

void move_angles()
{
  phi += signum(DES_phi-phi)*da;
  theta += signum(DES_theta-theta)*da;
  psi += signum(DES_psi-psi)*da;
  roll += signum(DES_roll-roll)*da;
  pitch += signum(DES_pitch-pitch)*da;
  yaw += signum(DES_yaw-yaw)*da;
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

void anythingPressed()
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

void manual_control()
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

void euler_angles()
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

void inverse_kinematics()
{
  // mouse mode (w/d)
  // x,y,z
  // 
  //
}

void recorded_play()
{
  
  
  
}

void automatic_mode()
{
  
  
  
  
}

void move_object()
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
  
void gravity()
{
  float g = 0.05;
 
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