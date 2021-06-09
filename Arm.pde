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
  
  public boolean magnetic;

  Arm(PVector []angles, PVector pos, String ID_, int max_grip_)
  {
    position = pos;
    
    ID = ID_;
    max_grip = max_grip_;
    grip_size = 0;
    virt_size = 0;
    dsize = 0.5;
    magnetic = false;
    
    color grey = color(180);
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
    grip_l.translate(0, -5, 0.5);  
    grip_r.translate(0, -5, -0.5); 
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
