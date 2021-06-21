class Thing
{
  // position and size
  PVector pos;
  PVector orient;
  PVector vel;
  int wid, hei, dep;
  float r_bound;
  color colour;
  PShape obj, cuboid;
  boolean caught;

  Thing(int param, int px, int py, int pz, float xangle, float yangle, float zangle, color c)
  {
    obj = createShape(GROUP);

    pos = new PVector(px, py, pz);
    orient = new PVector(xangle, yangle, zangle);
    vel = new PVector(0,0,0);
    
    caught = false;
    
    dep = param;
    wid = param;
    hei = param;
    r_bound = sqrt(3*dep*dep/4);
    
    cuboid = createShape(BOX, wid, hei, dep);
    obj.addChild(cuboid);

    colour = c;
  }

  Thing(int pwidth, int pheight, int pdepth, int px, int py, int pz, float xangle, float yangle, float zangle, color c)
  {
    obj = createShape(GROUP);

    pos = new PVector(px, py, pz);
    orient = new PVector(xangle, yangle, zangle);
    vel = new PVector(0,0,0);
    
    caught = false;
    
    wid = pwidth;
    hei = pheight;
    dep = pdepth;
    r_bound = sqrt(wid*wid/4+hei*hei/4+dep*dep/4);
    
    cuboid = createShape(BOX, wid, hei, dep);
    obj.addChild(cuboid);

    colour = c;
  }
  
  public void changeValues(int param, int px, int py, int pz, float xangle, float yangle, float zangle, color c)
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

 void update(PVector new_pos, PVector new_orient)
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
