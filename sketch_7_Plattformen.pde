//=== HAUPTPROGRAMM ===
Player player;
Platform[] platforms = new Platform[3]; //Ein Array für unsere Plattformen!
float groundY = 500.f;
boolean leftPressed = false;
boolean rightPressed = false;
float cameraX = 0.f;

void setup() {
  size(800, 600);
  player = new Player(100.f, height-100.f-50.f);

  //Wir erstellen 3 Plattformen wie eine kleine Treppe
  //new Platform(x,y, breite, höhe)
  platforms[0] = new Platform(300.f, 400.f, 150.f, 20.f);
  platforms[1] = new Platform(600.f, 300.f, 150.f, 20.f);
  platforms[2] = new Platform(900.f, 200.f, 150.f, 20.f);
}

void draw() {
  background(135, 206, 235);

  //Neu: Kamera berechnen. Sie soll den Spieler in der Mitte halten.
  //Wir ziehen die halbe bzw. auf 3.f geändert Bildschirmbreite ab, damit der Spieler zentriert ist
  float leftMargin = width/4;
  if (player.getXPos() < cameraX + leftMargin) {
    // Kamera schiebt sich sanft mit, statt zu springen
    cameraX = player.getXPos() - leftMargin;
  }

  // 2. Rechter Rand: Wie nah darf der Spieler an den rechten Rand?
  float rightMargin = width/3.f;
  if (player.getXPos() > cameraX + rightMargin) {
    cameraX = player.getXPos() - rightMargin;
  }
  if (cameraX < 0) cameraX = 0;


  translate(-cameraX, 0);

  //Neu: Wir übergen das Plattform-Array an den Spieler damit er übeprüfen kann, ob er darauf steht
  player.update(leftPressed, rightPressed, groundY, platforms);
  player.draw();

  //Boden zeichnen
  fill(34, 139, 34);
  rect(0, groundY, 3000, height - groundY);

  //Neu: Alle Plattformen zeichnen
  for (int i = 0; i < platforms.length; i++) {
    platforms[i].draw();
  }
}

void keyPressed() {
  if (key == 'a' || key == 'A') leftPressed = true;
  if (key == 'd' || key == 'D') rightPressed = true;

  if (key == ' ') player.jump();    //Methode befindet sich in der Player-Klasse
}

void keyReleased() {
  if (key =='a' || key == 'A') leftPressed = false;
  if (key =='d' || key == 'D') rightPressed = false;
}

//===Klassen===
class Player {
  private float xPos, yPos;
  private float size = 50.f;
  private float speed = 5.f;
  private float velocityY = 0.f;
  private float gravity = 0.5f;
  private float jumpStrength = -12.f;
  private boolean isJumping = false;

  public Player(float startX, float startY) {
    this.xPos = startX;
    this.yPos = startY;
  }

  public float getXPos() {
    return this.xPos;
  }

  public void jump() {
    if (!isJumping) {
      velocityY = jumpStrength;
      isJumping = true;
    }
  }

  //Neu: Die Methode fordert jetzt das Array der Plattform an
  public void update(boolean left, boolean right, float ground, Platform[] platforms) {
    //1. Horizontale Logik
    if (left && xPos > 0) xPos -= speed;
    if (right) xPos += speed;

    //2. Vertikale Logik
    velocityY += gravity;
    yPos += velocityY;

    //3. NEU: Plattform-Kollision
    if (velocityY > 0) { //Wir prüfen nur, wenn wir nach UNTEN fallen
      for (int i = 0; i < platforms.length; i++) {
        Platform p = platforms[i];

        //Prüfen: Sind wir horizontal im Bereich der Plattform?
        if (xPos + size > p.x && xPos < p.x + p.w) {
          //Prüfen: Steckt unsere Unterkante jetzt IN oder UNTER der Plattform...
          //...UND war sie im letzten Frame noch ÜBER der Plattform?
          //(yPos - velocityY rechnet quasi einen Fame in der Zeit zurück)
          if (yPos + size >= p.y && yPos + size - velocityY <= p.y) {
            yPos = p.y - size; //Exakt auf die Plattform setzen
            velocityY = 0.f;
            isJumping = false;
          }
        }
      }
    }

    //4. Bodenkollision
    if (yPos + size >= ground) {
      yPos = ground - size;
      velocityY = 0.f;
      isJumping = false;
    }
  }

  public void draw() {
    fill(255);
    rect(xPos, yPos, size, size);
  }
}

//NEU: Die Plattform-Klasse
class Platform {
  //Damit der Player leicht darauf zugreifen kann, lassen wir die Attribute hier mal package-privte (ohne private/public)
  float x, y, w, h;

  public Platform(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  public void draw() {
    fill(139, 69, 19);  //Braun wie Holzbretter
    rect(x, y, w, h);
  }
}
