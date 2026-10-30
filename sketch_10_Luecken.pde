//=== HAUPTPROGRAMM ===
Player player;
Platform[] platforms = new Platform[6];  //JETZT 6 (Bodenabschnitte + Plafformen)
Coin[] coins = new Coin[5];
Enemy[] enemies = new Enemy[2];
int score = 0;

float groundY = 500.f;
boolean leftPressed = false;
boolean rightPressed = false;
float cameraX = 0.f;

void setup() {
  size(800, 600);
  player = new Player(100.f, height-100.f-50.f);

  //BODENSEGMENTE (mit Lücken dazwischen)
  platforms[0] = new Platform(0.f, groundY, 500.f, height-groundY);      //Start-Boden(0 bis 500)
  platforms[1] = new Platform(700.f, groundY, 600.f, height-groundY);    //Zweiter Boden(700 bis 1300)
  platforms[2] = new Platform(1500.f, groundY, 1500.f, height-groundY);  //Restlicher Boden

  //HOCHPLATTFORMEN (wie gehabt)
  platforms[3] = new Platform(300.f, 400.f, 150.f, 20.f);
  platforms[4] = new Platform(600.f, 300.f, 150.f, 20.f);
  platforms[5] = new Platform(900.f, 200.f, 150.f, 20.f);

  coins[0] = new Coin(350.f, 360.f);
  coins[1] = new Coin(650.f, 260.f);
  coins[2] = new Coin(950.f, 160.f);
  coins[3] = new Coin(1200.f, 460.f);  //Auf dem Boden
  coins[4] = new Coin(1300.f, 460.f);  //Auf dem Boden

  //Gegner erstellen (X. Y, linkeGrenzen, rechteGrenzen)
  enemies[0] = new Enemy(750.f, groundY - 40.f, 700.f, 1300.f);
  enemies[1] = new Enemy(320.f, 400.f-40.f, 300.f, 430.f);
}

void draw() {
  background(135, 206, 235);

  float leftMargin = width/4.f;
  if (player.getXPos() < cameraX + leftMargin) {
    cameraX = player.getXPos() - leftMargin;
  }

  float rightMargin = width/3.f;
  if (player.getXPos() > cameraX + rightMargin) {
    cameraX = player.getXPos() - rightMargin;
  }
  if (cameraX < 0) cameraX = 0;


  translate(-cameraX, 0);

  //Boden-Parameter entfällt fast, da der Boden jetzt Plattformen sind!
  player.update(leftPressed, rightPressed, platforms, coins, enemies);
  player.draw();

  //Den starren Boden-rect(0, groundY, 3000, ...) HABEN WIR ENTFERNT
  //Stattdessen zeichnen sicha lle Plattformen/Bodenstücken hier:
  for (int i = 0; i < platforms.length; i++) {
    platforms[i].draw();
  }

  for (int i = 0; i < coins.length; i++) {
    coins[i].draw();
  }

  //NEU: Gegner aktualisieren und zeichnen
  for (int i = 0; i < enemies.length; i++) {
    enemies[i].update();
    enemies[i].draw();
  }

  fill(0);
  textSize(24);
  text("Score: " + score, cameraX +20, 40);
}

void keyPressed() {
  if (key == 'a' || key == 'A') leftPressed = true;
  if (key == 'd' || key == 'D') rightPressed = true;
  if (key == ' ') player.jump();
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

  //Parameter 'float ground' wurde entfernt, da der Boden jetzt Teil von 'platforms' ist
  public void update(boolean left, boolean right, Platform[] platforms, Coin[] coins, Enemy[] enemies) {
    if (left && xPos > 0) xPos -= speed;
    if (right) xPos += speed;

    velocityY += gravity;
    yPos += velocityY;

    //NEU: Plattform-  &Kollision (einheitlich über das Array!)
    if (velocityY > 0) {
      for (int i = 0; i < platforms.length; i++) {
        Platform p = platforms[i];
        if (xPos + size > p.x && xPos < p.x + p.w) {
          if (yPos + size >= p.y && yPos + size - velocityY <= p.y) {
            yPos = p.y - size;
            velocityY = 0.f;
            isJumping = false;
          }
        }
      }
    }

    //Münz-Kollision(Overlap)
    for (int i = 0; i < coins.length; i++) {
      Coin c = coins[i];
      if (!c.isCollected) {
        if (xPos < c.x + c.size && xPos + size > c.x &&
          yPos < c.y + c.size && yPos + size > c.y) {
          c.isCollected = true;
          score += 10;
        }
      }
    }

    //Gegner-Kollision
    for (int i = 0; i < enemies.length; i++) {
      Enemy e = enemies[i];
      if (e.isAlive) {
        if (xPos < e.x + e.size && xPos + size > e.x &&
          yPos < e.y + e.size && yPos + size > e.y) {
          if (velocityY > 0 && (yPos + size - velocityY) <= e.y +15.f) {
            e.isAlive = false;
            velocityY = jumpStrength * 0.7f;
            score += 50;
          } else {
            //Respawn
            xPos = 100.f;
            yPos = 450.f;
            velocityY = 0.f;
          }
        }
      }
    }

    //NEU: Abgrundprüfung! Fällt der Spieler unten aus dem Bild
    if (yPos > height) {
      xPos = 100.f;
      yPos = 450.f;
      velocityY = 0.f;
    }
  }

  public void draw() {
    fill(255);
    rect(xPos, yPos, size, size);
  }
}


class Platform {
  float x, y, w, h;

  public Platform(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  public void draw() {
    fill(139, 69, 19);
    rect(x, y, w, h);
  }
}

//NEU: Die Münz-Klasse
class Coin {
  float x, y;
  float size = 20.f;
  boolean isCollected = false;     //Flag: Wurde is schon eingesammelt?

  public Coin(float x, float y) {
    this.x = x;
    this.y = y;
  }

  public void draw() {
    if (!isCollected) {  //Zeichne nur, wenn noch nicht gesammelt
      fill(255, 215, 0);  //Gold-Gelb
      //Ein Kreis wird in Processing von der Mitte aus gezeichnet
      //wir wollen der Einfachheit halber (Kollision) aber aus der Ecke zeichnen
      rect(x, y, size, size);
    }
  }
}

//NEU: Die Gegner-Klasse
class Enemy {
  float x, y;
  float size = 40.f;
  float speed = 2.f;  //Geschwindigkeit
  float leftBound, rightBound;   //Patroullien-Grenzen
  boolean isAlive = true;

  public Enemy(float x, float y, float leftBound, float rightBound) {
    this.x = x;
    this.y = y;
    this.leftBound = leftBound;
    this.rightBound = rightBound;
  }

  public void update() {
    if (!isAlive) return;
    //Bewegung nach links/rechts
    x += speed;
    //An den Grenzen die Richtung umkehren
    if (x < leftBound || x + size > rightBound) {
      speed *= -1;  //Kehrt das Vorzeichen um (aus +2 wird -2 und umgekehrt)
    }
  }

  public void draw() {
    if (isAlive) {
      fill(200, 20, 60); //Knalliges Rot
      rect(x, y, size, size);
    }
  }
}
