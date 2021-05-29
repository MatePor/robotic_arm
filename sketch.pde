float phi, theta, psi, roll, pitch, yaw, da;
PVector []angles;

int grip_size, max_grip;
boolean grip_on, blocked;

boolean roll_up, button_is_pressed, keyboard, automatic, 
  recording, inverse, menu, mouse_follow, looking, moving, config;

int num_of_things, num_of_c_buttons;

float camX, camY, camD;
PVector camCenter;
PImage roof;

thing things[];
Arm robot;
button c_buttons[]; 
button START, MENU_B, INSTRUCTIONS, AUTHOR, DOCUMENTATION, 
  FLY, CONTROLS, ZOOM_IN, ZOOM_OUT, MAN_AUT, INV_KIN, RECORD;

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
  grip_size = 10;
  max_grip = 24;
  grip_on = true;
  blocked = false;

  // angles(position)
  phi = 0;
  theta = PI/4;
  psi = -5*PI/4;
  roll = 0;
  pitch = 0;
  yaw = 0;

  angles = new PVector[6];
  for (int i = 0; i < 6; i++)
    angles[i] = new PVector(0, 0, 0);

  // angle step
  da = PI/128; 

  // create an arm
  robot = new Arm(angles, new PVector(0, 0, 0), "NUm 1");

  // things
  num_of_things = 2;
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
      test_thing = new thing(ran, int(random(-200, 200)), - ran/2, int(random(-200, 200)), 0, random(PI), 0, rand_color);
      for (int j = 0; j < i; j++)
        if (isColliding(test_thing, things[j]))
          ok = false;
    }
    while (!ok);

    things[i] = test_thing;
  }

  // buttons
  START = new button(width/2, height/3, width/2, 70, "START");
  INSTRUCTIONS = new button(width/2, height/3 + 90, width/2, 70, "INSTRUCTIONS");
  DOCUMENTATION = new button(width/2, height/3 + 180, width/2, 70, "DOCUMENTATION");
  AUTHOR = new button(width/2, height/3 + 270, width/2, 70, "AUTHOR");

  MENU_B = new button(80, 20, 160, 40, "MENU");

  //FLY = new button(240, 20, 160, 40, "FLY MODE");
  //MAN_AUT = new button(240, 20, 160, 40, "AUTOMATIC");
  //INV_KIN = new button(240, 20, 160, 40, "INV_KIN");
  //RECORD = new button(240, 20, 160, 40, "RECORD");

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

  // control booleans (switching modes)
  menu = true;
  keyboard = false;
  automatic = false;
  recording = false;
  inverse = false;
  mouse_follow = false;
  looking = false;
  moving = true;
  config = false;
}

void draw()
{
  background(255);

  lights();
  anythingPressed();

  if (menu)
    openMenu();
  else
  { 
    //check_cursor();
    controls();

    pushMatrix();
    cam();

    pushMatrix();
    // keep the same reference frame for all the 
    translate(-camCenter.x, -camCenter.y, - camCenter.z);
    translate(width/2, height/2 + 150, 0);

    // roof dome
    fill(0, 150, 255);
    noStroke();
    PShape dome = createShape(SPHERE, 1500);
    //dome.disableStyle();
    //dome.setTexture(roof);
    shape(dome);

    animation();
    popMatrix();
    popMatrix();
    
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
  camCenter.y = height/2;

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
    rect(80, 230, 160, 300);
    textSize(12);
    textAlign(CENTER, CENTER);
    fill(0);

    text("phi: " + toDegr(phi), 40, 100, 76, 38);
    text("theta: "+ toDegr(theta), 40, 140, 76, 38 );
    text("psi: "+ toDegr(psi), 40, 180, 76, 38);
    text("roll: "+ toDegr(roll), 40, 220, 76, 38);
    text("pitch: "+toDegr(pitch), 40, 260, 76, 38);
    text("yaw: "+ toDegr(yaw), 40, 300, 76, 38);
    text("grip size: "+ str(grip_size), 40, 340, 76, 38);

    for (int i = 0; i < num_of_c_buttons; i++)
      c_buttons[i].show();
  }

  MagnGlass(width - 50, 44, "+");
  MagnGlass(width - 50, 133, "-");
  ZOOM_IN.show();
  ZOOM_OUT.show();
  MENU_B.show();
  CONTROLS.show();
}

void animation()
{
  // FLOOR AND OBJECTS ---------------  
  pushMatrix();
  translate(0, 150);
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
  fill(255, 0, 0);
  sphere(15);
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
  textAlign(CENTER);
  rectMode(CENTER);
  fill(0);
  text(sign, x, y-2, 30, 30);
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

void openMenu()
{
  background(0);
  fill(120);
  rect(width/2, height/2, 700, 500 );

  fill(220);
  textSize(30);
  text("* Robotic Arm Simulator - 2021 *", width/2, 100, width*2/3, 300);
  START.show();
  INSTRUCTIONS.show();
  DOCUMENTATION.show();
  AUTHOR.show();

  START.pressed = isPressed(START);
  INSTRUCTIONS.pressed = isPressed(INSTRUCTIONS);
  DOCUMENTATION.pressed = isPressed(DOCUMENTATION);
  AUTHOR.pressed = isPressed(AUTHOR);
}

void mouseReleased()
{
  if (START.pressed)
    menu = false; 


  if (!menu && MENU_B.pressed)
    menu = true;

  /*
   if(START.pressed)
   menu = false;
   if(START.pressed)
   menu = false;
   if(START.pressed)
   menu = false;
   if(START.pressed)
   menu = false;
   */
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
  START.pressed = isPressed(START);
  presses.add(START.pressed);

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

  // control panel
  if (CONTROLS.pressed)    
  { 
    if (!roll_up)  
      roll_up = true;
    else
      roll_up = false;
  }

  // menu/instructions


  // arm motion 
  if (!keyboard && roll_up)
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
      yaw -= da;
    if (c_buttons[11].pressed) 
      yaw += da;  

    if (yaw >= PI/2)
      yaw = PI/2;
    if (yaw <= -PI/2)
      yaw = -PI/2;

    if (c_buttons[12].pressed)
      grip_size -= 1;
    if (c_buttons[13].pressed) 
      grip_size += 1;  

    if (grip_size >= max_grip)
      grip_size = max_grip;
    if (grip_size <= 0)
      grip_size = 0;
  }

  // mechanics
  /*
  if(grip_on)
   grip_size -= 2;
   else 
   grip_size += 2;
   
   if(grip_size == 0 || grip_size == max_grip)
   grip_on = !grip_on; 
   */
}
