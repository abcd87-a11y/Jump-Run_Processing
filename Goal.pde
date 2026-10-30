class Goal extends GameObject {
  public Goal(float x, float y) {
    super(x, y, 40.f, 100.f);
  }

  public void draw() {
    //Fahnenmast (Grau)
    fill(100);
    rect(x, y, 10.f, h);

    //Tuch/Flagge (Grün)
    fill(0, 200, 0);
    triangle(x +10.f, y, x + 40.f, y + 20.f, x + 10.f, y +40.f);
  }
}
