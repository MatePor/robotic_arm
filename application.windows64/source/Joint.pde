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
