class Bullet extends GameObject {
  float speedX = 10.f; //Positiv nach rechts, Negativ nach links
  boolean isActive = true;

  public Bullet(float startX, float startY, float speedX) {
    super(startX, startY, 10.f, 10.f);
    this.speedX = speedX;
  }


  //NEU: Nimmt cameraX entgegen, um den Bildschimrand korrekt zu prüfen
  public void update(float cameraX) {
    if (!isActive) return;

    x += speedX; //Kugel bewegt sich horizontal

    //Kugel löschen, wenn sie links oder rechts aus dem sichtbaren Bild fliegt
    if (x > cameraX + width + 100 || x < cameraX - 100) isActive = false;
  }

  public void draw() {
    if (isActive) {
      fill(255, 140, 0);
      rect(x, y, w, h);
    }
  }
}
