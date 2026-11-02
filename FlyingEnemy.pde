class FlyingEnemy extends GameObject {
  float speed = 120.f;
  float topBound, bottomBound;      //Grenzen für die vertikale Bewegung
  boolean isAlive  = true;

  public FlyingEnemy(float x, float y, float topBound, float bottomBound) {
    super(x, y, 35.f, 35.f);    //Etwas kleinera als der Bodengegner
    this.topBound = topBound;
    this.bottomBound = bottomBound;
  }

  public void update(float dt) {
    if (!isAlive) return;
    //Bewegung auf der Y-Achse
    y +=speed *dt;
    //Richtungswechsel an den Grenzen
    if (y < topBound || y + h > bottomBound) speed *= -1;
  }

  public void draw() {
    if (isAlive) {
      fill(18, 0, 211);
      rect(x, y, w, h);
    }
  }
}
