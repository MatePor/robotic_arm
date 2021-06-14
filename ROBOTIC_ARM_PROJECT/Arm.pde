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
    dsize = 0.5;
    magnetic = false;
    magn_ON = false;
    
    color grey = color(55);
    color red = color(210, 0, 0);
    
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
    grip_l.translate(0, -5, 0.5);  
    grip_r.translate(0, -5, -0.5); 
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
       dsize = 0.1;
    if(virt_size > grip_size)
       dsize = -0.1;
       
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
