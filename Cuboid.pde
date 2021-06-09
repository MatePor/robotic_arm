class thing
{
  // position and size
  PVector pos;
  PVector orient;
  int wid, hei, dep;
  color colour;
  PShape obj, cuboid;


  thing(int param, int px, int py, int pz, float xangle, float yangle, float zangle, color c)
  {
    obj = createShape(GROUP);

    pos = new PVector(px, py, pz);
    orient = new PVector(xangle, yangle, zangle);

    dep = param;
    wid = param;
    hei = param;

    cuboid = createShape(BOX, wid, hei, dep);
    obj.addChild(cuboid);

    colour = c;
  }

  thing(int pwidth, int pheight, int pdepth, int px, int py, int pz, float xangle, float yangle, float zangle, color c)
  {
    obj = createShape(GROUP);

    pos = new PVector(px, py, pz);
    orient = new PVector(xangle, yangle, zangle);

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
    pos = new_pos;
    orient = new_orient;
  }
}
