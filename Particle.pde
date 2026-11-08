class Particle {
  float x, y;
  float vx, vy;    //Geschwindigkeit in x- und y-Richung
  float life;      //Verbleibende Lebensdauer
  float maxLife;
  int r, g, b;       //Farbe
  float size;
  boolean isActive = true;

  public Particle (float x, float y, int r, int g, int b) {
    this.x = x;
    this.y = y;
    this.r = r;
    this.g = g;
    this.b = b;

    //Zufällige Flugrichtung in alle Seiten
    this.vx = random(-200.f, 200.f);
    this.vy = random(-200.f, 200.f);

    //Lebensdauer zwischen 0.2 und 0.5 Sekunden
    this.maxLife = random(0.2f, 0.5f);
    this.life = this.maxLife;

    this.size = random(4.f, 8.f);
  }

  public void update(float dt) {
    if (!isActive) return;

    x += vx* dt;
    y += vy * dt;

    vx *= 0.95f;
    vy *= 0.95f;

    life -= dt;
    if (life <= 0) isActive = false;
  }

  public void draw() {
    if (!isActive) return;
    //Transparenz (Alpha) sinkt synchron mit der Lebensdauer von 255 auf 0
    float alpha = (life/maxLife) * 255.f;

    noStroke();
    fill(r, g, b, alpha);
    rect(x, y, size, size);
  }
}
