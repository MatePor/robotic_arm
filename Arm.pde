class Arm
{
  String ID;
  int grip_size, max_grip_size;
  thing base, gripper;
  joint []joints = new joint[6];
  thing []segments = new thing[6];
  PVector []r = new PVector[6];
  PVector effector_pos, effector_orient;
  PVector position;
  PVector []effector_pos_history;
  PVector []move_history;

  Arm(PVector []angles, PVector pos, String ID_)
  {
    position = pos;

    ID = ID_;
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

    for (int i = 0; i < 6; i++)
    {
      joints[i] = new joint(r[i], angles[i]);
      effector_orient.add(joints[i].orient);
      effector_pos.add(joints[i].pos);
    }
  }


  void updateArm(PVector []angles)
  {
    PVector zeros = new PVector(0,0,0);
    effector_orient = zeros; 
    
    for (int i = 0; i < 6; i++)
    {
      joints[i].orient = angles[i];
      effector_orient.add(angles[i]);
    } 

    effector_pos.x = -80*cos(angles[1].z)*cos(angles[0].y)
    -80*cos(angles[2].z - angles[1].z)*cos(angles[0].y);
    
    effector_pos.y = -80+80*sin(-angles[1].z) + 75*sin(angles[1].z - angles[2].z);
    
    effector_pos.z = -80*cos(angles[1].z)*sin(-angles[0].y)
    -80*cos(angles[2].z - angles[1].z)*sin(-angles[0].y);

    //effector_pos.add(new PVector(0, -12, 0));
  }

  void showArm()
  {
    pushMatrix();
    translate(position.x, position.y, position.z);
    base.show();
    for (int i = 0; i < 6; i++)
    {
      joints[i].trans();
      segments[i].show();
    } 

    //gripper.show();
    // gripper animation
    stroke(0);
    strokeWeight(1);
    pushMatrix();
    translate(0, -12);
    rotateX(PI/2);
    box(8, max_grip, 2);
    rect(0, 0, 8, grip_size);

    translate(0, -grip_size/2, 4);
    rotateX(PI/2);
    rect(0, 0, 8, 8);

    translate(0, 0, -grip_size);
    rect(0, 0, 8, 8);

    popMatrix();
    popMatrix();
  }
}
