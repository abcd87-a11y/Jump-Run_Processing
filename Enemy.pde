class Enemy extends GameObject {
  float speed = 2.f;  //Geschwindigkeit
  float leftBound, rightBound;   //Patroullien-Grenzen
  boolean isAlive = true;

  public Enemy(float x, float y, float leftBound, float rightBound) {
    super(x, y, 40.f, 40.f);
    this.leftBound = leftBound;
    this.rightBound = rightBound;
  }

  public void update() {
    if (!isAlive) return;
    //Bewegung nach links/rechts
    x += speed;
    //An den Grenzen die Richtung umkehren
    if (x < leftBound || x + w > rightBound) {
      speed *= -1;  //Kehrt das Vorzeichen um (aus +2 wird -2 und umgekehrt)
    }
  }

  public void draw() {
    if (isAlive) {
      fill(200, 20, 60); //Knalliges Rot
      rect(x, y, w, h);
    }
  }
}
