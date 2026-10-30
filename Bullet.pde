class Bullet extends GameObject {
  float speed = 10.f; //fliegt flott nach rechts
  boolean isActive = true;

  public Bullet(float startX, float startY) {
    super(startX, startY, 10.f, 10.f);
  }

  public void update() {
    if (!isActive) return;
    x += speed; //Kugel bewegt sich horizontal
  }

  public void draw() {
    if (isActive) {
      fill(255, 140, 0);
      rect(x, y, w, h);
    }
  }
}
