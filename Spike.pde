class Spike extends GameObject {
  public Spike(float x, float y) {
    super(x, y, 30.f, 30.f);
  }

  public void draw() {
    fill(120);
    triangle(x, y + h, x + w /2.f, y, x +w, y + h); //Ein Dreieck mit der Spitze nach oben: (x1, y1, x2, y2, x3 ,y3)
  }
}
