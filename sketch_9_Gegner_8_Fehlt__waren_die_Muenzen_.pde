//=== HAUPTPROGRAMM ===
Player player;
Platform[] platforms = new Platform[3];
Coin[] coins = new Coin[5];
Enemy[] enemies = new Enemy[2];    //Neu: Ein Array für unsere Gegner!
int score = 0;

float groundY = 500.f;
boolean leftPressed = false;
boolean rightPressed = false;
float cameraX = 0.f;

void setup() {
  size(800, 600);
  player = new Player(100.f, height-100.f-50.f);

  platforms[0] = new Platform(300.f, 400.f, 150.f, 20.f);
  platforms[1] = new Platform(600.f, 300.f, 150.f, 20.f);
  platforms[2] = new Platform(900.f, 200.f, 150.f, 20.f);

  coins[0] = new Coin(350.f, 360.f);
  coins[1] = new Coin(650.f, 260.f);
  coins[2] = new Coin(950.f, 160.f);
  coins[3] = new Coin(1200.f, 460.f);  //Auf dem Boden
  coins[4] = new Coin(1300.f, 460.f);  //Auf dem Boden

  //NEU: Gegner erstellen (X. Y, linkeGrenzen, rechteGrenzen)
  //Ein Gegner auf dem Boden, einer auf der ersten Plattform
  enemies[0] = new Enemy(700.f, groundY - 40.f, 500.f, 1100.f);
  enemies[1] = new Enemy(320.f, 400.f-40.f, 300.f, 430.f);
}

void draw() {
  background(135, 206, 235);

  float leftMargin = width/4;
  if (player.getXPos() < cameraX + leftMargin) {
    cameraX = player.getXPos() - leftMargin;
  }

  float rightMargin = width/3.f;
  if (player.getXPos() > cameraX + rightMargin) {
    cameraX = player.getXPos() - rightMargin;
  }
  if (cameraX < 0) cameraX = 0;


  translate(-cameraX, 0);

  //Neu: Gegner an die update-Methode übernehmen
  player.update(leftPressed, rightPressed, groundY, platforms, coins, enemies);
  player.draw();

  fill(34, 139, 34);
  rect(0, groundY, 3000, height - groundY);

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

  //NEU: Nimmt jetzt auch Enemy[] an
  public void update(boolean left, boolean right, float ground, Platform[] platforms, Coin[] coins, Enemy[] enemies) {
    if (left && xPos > 0) xPos -= speed;
    if (right) xPos += speed;

    velocityY += gravity;
    yPos += velocityY;

    //Platt-form Kollision
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
          c.isCollected = true;   //Münze "verschwindet"
          score += 10;            //10 Punkte aufs Konto! (Greift auf die globale Variable zu)
        }
      }
    }

    //NEU: Gegner-Kollision
    for (int i = 0; i < enemies.length; i++) {
      Enemy e = enemies[i];
      if (e.isAlive) {
        //Algemeine Überschneidung prüfen
        if (xPos < e.x + e.size && xPos + size > e.x &&
          yPos < e.y + e.size && yPos + size > e.y) {
          //Fallen wir von OBEN auf den Gegner?
          if (velocityY > 0 && (yPos + size - velocityY) <= e.y +15.f) {
            e.isAlive = false;                //Gegner plattmachen!
            velocityY = jumpStrength * 0.7f;  //Kleiner Abprall-Hüpfer nach oben
            score += 50;
          } else {
            //Von der Seite erwischt -> Zurück zum Start! (Respawn)
            xPos = 100.f;
            yPos = ground - size;
            velocityY = 0.f;
          }
        }
      }
    }

    //Bodenkollision
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
