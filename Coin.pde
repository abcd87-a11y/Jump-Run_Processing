class Coin extends GameObject {
  boolean isCollected = false;     //Flag: Wurde is schon eingesammelt?
  private PImage img;

  public Coin(float x, float y, PImage img) {
    super(x, y, 20.f, 20.f);      //ruft den Konstruktor von Gameobject auf
    this.img = img;
  }

  public void draw() {
    if (!isCollected) {  //Zeichne nur, wenn noch nicht gesammelt
      if (img != null) {
        image(img, x, y, w, h);
      } else {
        fill(255, 215, 0);
        rect(x, y, w, h);
      }
    }
  }
}
