class Goal extends GameObject {
  private PImage img;

  public Goal(float x, float y, PImage img) {
    super(x, y, 40.f, 100.f);
    this.img = img;
  }

  public void draw() {
    if (img != null) {
      image(img, x, y, w, h);
    } else {
      //Fahnenmast (Grau)
      fill(100);
      rect(x, y, 10.f, h);
      //Tuch/Flagge (Grün)
      fill(0, 200, 0);
      triangle(x +10.f, y, x + 40.f, y + 20.f, x + 10.f, y +40.f);
    }
  }
}
