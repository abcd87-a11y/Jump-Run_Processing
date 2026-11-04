class Spike extends GameObject {
  private PImage img;

  public Spike(float x, float y, PImage img) {
    super(x, y, 30.f, 30.f);
    this.img = img;
  }

  public void draw() {
    if (img != null) {
      image(img, x, y, w, h);
    } else {
      fill(120);
      triangle(x, y + h, x + w /2.f, y, x +w, y + h); //Ein Dreieck mit der Spitze nach oben: (x1, y1, x2, y2, x3 ,y3)
    }
  }
}
