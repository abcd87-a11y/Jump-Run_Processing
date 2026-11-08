class Enemy extends GameObject {
  float speed = 120.f;  //120 px/s
  float leftBound, rightBound;   //Patroullien-Grenzen
  boolean isAlive = true;
  private PImage img;

  public Enemy(float x, float y, float leftBound, float rightBound, PImage img) {
    super(x, y, 40.f, 40.f);
    this.leftBound = leftBound;
    this.rightBound = rightBound;
    this.img = img;
  }

  public void update(float dt) {
    if (!isAlive) return;

    x += speed * dt; // Bewegung anwenden

    // Check linke Grenze
    if (x <= leftBound) {
      x = leftBound;         // Harte Korrektur auf die Kante
      speed = Math.abs(speed); // Garantiert positiv (nach rechts)
    } 
    // Check rechte Grenze
    else if (x + w >= rightBound) {
      x = rightBound - w;    // Harte Korrektur auf die rechte Kante
      speed = -Math.abs(speed); // Garantiert negativ (nach links)
    }
  }

  public void draw() {
    if (isAlive) {
      if (img != null) {
        image(img, x, y, w, h);
      } else {
        fill(200, 20, 60); //Knalliges Rot
        rect(x, y, w, h);
      }
    }
  }
}
