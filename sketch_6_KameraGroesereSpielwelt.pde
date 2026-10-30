//=== HAUPTPROGRAMM ===
Player player;
float groundY = 500.f;
boolean leftPressed = false;
boolean rightPressed = false;

//NEU: Eine Variable für unsere Kamera-Verschiebung
float cameraX = 0.f;

void setup() {
  size(800, 600);
  player = new Player(100.f, height-100.f-50.f);    //100 sind die Bodenhöhe, und 50 die Spielerhöhe
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

  //Die Kamera soll am linken Rand stoppen (damit man nicht links aus der Welt läuft)
  if (cameraX < 0) cameraX = 0;

  //NEU: Wir verschieben das gesamte Koordinatensystem nach links (daher -camerX)
  //Alles, was ab hier gezeichnet wird, ist Teil der großen Welt!
  translate(-cameraX, 0);  //Bsp Spieler ist 1000 - cameraX = position der Spielwelt

  player.update(leftPressed, rightPressed, groundY);
  player.draw();

  //Boden zeichnen (NEU: Jetzt 3000 Pixel breit statt "width")
  fill(34, 139, 34);
  rect(0, groundY, 3000, height - groundY);

  //Neu: Ein paar Hindernisse/Bäume als Orientierung in der großen Welt
  fill(139, 69, 19);  //braun
  rect(600, groundY - 80, 40, 80);
  rect(1200, groundY - 120, 60, 120);
  rect(2200, groundY - 60, 30, 60);
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

  //NEU: Der Getter, damit das Hauptprogramm die Position für die Kamera lesen darf
  public float getXPos() {
    return this.xPos;
  }

  public void jump() {
    if (!isJumping) {
      velocityY = jumpStrength;
      isJumping = true;
    }
  }

  public void update(boolean left, boolean right, float ground) {
    //1. Horizontale Logik
    if (left && xPos > 0) xPos -= speed;

    //Änderung: Der Spieler kann jetzt nach rechts laufen ( < width wurde entfernt)
    if (right) xPos += speed;

    //2. Vertikale Logik
    velocityY += gravity;
    yPos += velocityY;

    //3 Bodenkollision
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

/*
// Ohne translate müssten wir das hier machen:
 
 // Spieler zeichnen
 rect(player.getXPos() - cameraX, player.getYPos(), 50, 50);
 
 // Baum 1
 rect(600 - cameraX, groundY - 80, 40, 80);
 
 // Baum 2
 rect(1200 - cameraX, groundY - 120, 60, 120);
 
 // Baum 3
 rect(2200 - cameraX, groundY - 60, 30, 60);
 
 */
