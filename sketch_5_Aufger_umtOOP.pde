//=== HAUPTPROGRAMM ===
Player player;  //Wir deklarieren eine Variable vom Typ 'Player'
float groundY = 500.f;
boolean leftPressed = false;
boolean rightPressed = false;

void setup() {
  size(800, 600);
  //wir erschaffen unser Spieler-Objekt und geben ihm Starkoordianten
  player = new Player(100.f, height-100.f-50.f);
}

void draw() {
  background(135, 206, 235);

  //Wir übergeben dem Spieler die Tasten und den Boden
  player.update(leftPressed, rightPressed, groundY);
  player.draw();

  //Boden zeichnen
  fill(34, 139, 34);
  rect(0, groundY, width, height - groundY);
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
//Das wäre in reinem Java eine eigene Datei "Player.java")
class Player {
  //Attribute: Alles was 'private' ist, gehört nut dem Spieler
  private float xPos, yPos;
  private float size = 50.f;
  private float speed = 5.f;
  private float velocityY = 0.f;
  private float gravity = 0.5f;
  private float jumpStrength = -12.f;
  private boolean isJumping = false;

  //Konstruktor (wird beim 'new' Aufruf ausgeführt)
  public Player(float startX, float startY) {
    this.xPos = startX;
    this.yPos = startY;
  }

  //Methoden (Fähigkeiten des Spielers)
  public void jump() {
    if (!isJumping) {
      velocityY = jumpStrength;
      isJumping = true;
    }
  }

  public void update(boolean left, boolean right, float ground) {
    //1. Horizontale Logik mit Begrenzung
    if (left && xPos > 0) xPos -= speed;
    if (right && (xPos+size < width)) xPos += speed;

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
