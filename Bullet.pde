class Bullet extends GameObject {
  float speedX = 600.f; //Positiv nach rechts, Negativ nach links
  boolean isActive = true;
  private PImage img;

  public Bullet(float startX, float startY, float speedX, PImage img) {
    super(startX, startY, 10.f, 10.f);
    this.speedX = speedX;
    this.img = img;
  }

  // Nimmt cameraX entgegen, um den Bildschimrand korrekt zu prüfen
  public void update(float cameraX, float dt) {
    if (!isActive) return;

    x += speedX *dt; //Kugel bewegt sich horizontal

    //Kugel löschen, wenn sie links oder rechts aus dem sichtbaren Bild fliegt
    if (x > cameraX + width + 100 || x < cameraX - 100) isActive = false;
  }

  public void draw() {
    if (isActive) {
      if (img != null) {
        image(img, x, y, w, h);
      } else {
        fill(255, 140, 0);
        rect(x, y, w, h);
      }
    }
  }
}
