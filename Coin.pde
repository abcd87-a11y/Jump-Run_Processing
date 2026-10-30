class Coin extends GameObject {
  boolean isCollected = false;     //Flag: Wurde is schon eingesammelt?

  public Coin(float x, float y) {
    super(x, y, 20.f, 20.f);      //ruft den Konstruktor von Gameobject auf
  }

  public void draw() {
    if (!isCollected) {  //Zeichne nur, wenn noch nicht gesammelt
      fill(255, 215, 0);
      rect(x, y, w, h);
    }
  }
}
