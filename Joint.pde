class Joint
{
  PVector pos;
  PVector orient;

  Joint(PVector position, PVector rotations)
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
