//=== HAUPTPROGRAMM ===
Player player;
Platform[] platforms = new Platform[6];  //(Bodenabschnitte + Plafformen)
Coin[] coins = new Coin[5];
Enemy[] enemies = new Enemy[2];
Goal goal;
int score = 0;
int lives = 3;      //wir starten mir 3 Leben
int gameState = 0;  //0 = Spielen, 1 = Gewonnen, 2 = Game Over(NEU)

float groundY = 500.f;
boolean leftPressed = false;
boolean rightPressed = false;
float cameraX = 0.f;

void setup() {
  size(800, 600);
  resetGame();    //Wir rufen einfach unsere Reset-Funktion auf!
}

//Auf Startpunkt zurücksetzen
void resetGame() {
  score = 0;
  lives = 3;
  gameState = 0;
  cameraX = 0.f;

  player = new Player(100.f, height-100.f-50.f);

  //BODENSEGMENTE (mit Lücken dazwischen)
  platforms[0] = new Platform(0.f, groundY, 500.f, height-groundY);
  platforms[1] = new Platform(700.f, groundY, 600.f, height-groundY);    //(weiteStart, hoeheStart, weite+weiteStart, hoeheStart+ hoehe) = (700, 500, 700+600 = 1300, 500 + (600-500) = 600)
  platforms[2] = new Platform(1500.f, groundY, 1500.f, height-groundY);

  //Plattformen
  platforms[3] = new Platform(300.f, 400.f, 150.f, 20.f);
  platforms[4] = new Platform(600.f, 300.f, 150.f, 20.f);
  platforms[5] = new Platform(900.f, 200.f, 150.f, 20.f);

  //Coins
  coins[0] = new Coin(350.f, 360.f);
  coins[1] = new Coin(650.f, 260.f);
  coins[2] = new Coin(950.f, 160.f);
  coins[3] = new Coin(1200.f, 460.f);  //Auf dem Boden
  coins[4] = new Coin(1300.f, 460.f);

  //Gegner
  enemies[0] = new Enemy(750.f, groundY - 40.f, 700.f, 1300.f);  //(X. Y, linkeGrenzen, rechteGrenzen)
  enemies[1] = new Enemy(320.f, 400.f-40.f, 300.f, 450.f);

  //Ziel
  goal = new Goal(2500.f, groundY  - 100.f);
}

void draw() {
  background(135, 206, 235);


  if (gameState == 0) {    //Spielen
    //Normale SPIEL-Logik
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

    player.update(leftPressed, rightPressed, platforms, coins, enemies, goal);
    player.draw();

    for (int i = 0; i < platforms.length; i++)  platforms[i].draw();
    for (int i = 0; i < coins.length; i++) coins[i].draw();
    for (int i = 0; i < enemies.length; i++) {
      enemies[i].update();
      enemies[i].draw();
    }

    goal.draw();

    //UsetInterface(UI): Score zeichnen
    fill(0);
    textSize(24);
    text("Score: " + score, cameraX + 20, 40);
    //NEU: UI für Leben zeichnen (3 rote Quadrate/Herzen obren rechts)
    fill(220, 20, 60);
    for (int i = 0; i < lives; i++) {
      rect(cameraX + width - 120 + (i*30), 20, 20, 20);
    }
  } else if (gameState == 1) {  //GEWONNEN
    //Kamera beibehalten
    translate(-cameraX, 0);
    //Welt im Hintergrund zeichnen
    for (int i = 0; i < platforms.length; i++) platforms[i].draw();
    goal.draw();
    player.draw();

    //Großer Gewonnen-Text in der Bildschirmbreite
    fill(0, 150, 0);
    textAlign(CENTER, CENTER);
    textSize(48);
    text("LEVEL GESCHAFFT", cameraX + width / 2.f, height / 2.f -30 );
    textSize(24);
    text("Endscore: " + score, cameraX + width / 2.f, height/2.f +30);

    //Hinweis für Neustart
    fill(0);
    text("Drücke 'R' für Neustart", cameraX + width / 2.f, height / 2.f + 50);
    //Textausrichtung zurücksetzen
    textAlign(LEFT, BASELINE);
  } else if (gameState == 2) {    //GAME OVER
    translate(-cameraX, 0);
    for (int i = 0; i < platforms.length; i++) platforms[i].draw();

    fill(200, 0, 0);
    textAlign(CENTER, CENTER);
    textSize(48);
    text("GAME OVER", cameraX + width / 2.f, height / 2.f);

    //Hinweis für Neustart
    fill(0);
    textSize(24);
    text("Drücke 'R' für Neustart", cameraX + width / 2.f, height / 2.f +30);
    textAlign(LEFT, BASELINE);
  }
}

void keyPressed() {
  if (key == 'a' || key == 'A') leftPressed = true;
  if (key == 'd' || key == 'D') rightPressed = true;
  if (key == ' ') player.jump();

  //NEU: Mit 'R' setzten wir das Spiel komplett zurück
  if (key == 'r' || key == 'R') resetGame();
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

  //NEU: Sprung-Zähler für Doppelsprung
  private int jumpCount = 0;
  private int maxJumps = 2;

  public Player(float startX, float startY) {
    this.xPos = startX;
    this.yPos = startY;
  }

  public float getXPos() {
    return this.xPos;
  }

  //NEU: Die jump()-Methode erlaubt Sprünge, solange jumpCount < maxJumps ist!
  public void jump() {
    if (jumpCount < maxJumps) {
      velocityY = jumpStrength;  //Impuls nach oben
      jumpCount++;               //Zähler hochzählen (1 = BodenSprung, 2 = LuftSprung
    }
  }

  //Update
  public void update(boolean left, boolean right, Platform[] platforms, Coin[] coins, Enemy[] enemies, Goal goal) {
    //Bewegung
    if (left && xPos > 0) xPos -= speed;
    if (right) xPos += speed;

    //Sprung
    velocityY += gravity;
    yPos += velocityY;

    //Plattform & Kollision (einheitlich über das Array!)
    if (velocityY > 0) {
      for (int i = 0; i < platforms.length; i++) {
        Platform p = platforms[i];
        if (xPos + size > p.x && xPos < p.x + p.w) {
          if (yPos + size >= p.y && yPos + size - velocityY <= p.y) {
            yPos = p.y - size;
            velocityY = 0.f;
            jumpCount = 0; //NEU: Auf der Plattform landen setzt die Sprünge auf 0 zurück
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
          if (velocityY > 0 && (yPos + size - velocityY) <= e.y +15.f) {    //Denk drann Y steht aufm kopf, deshalb velocityY > 0 und  <= e.y + 15.f: Lag im letzten Frame noch über/auf der Oberkante des Gegners
            e.isAlive = false;
            velocityY = jumpStrength * 0.7f;
            score += 50;
          } else {
            //NEU: Leben abziehen & Respawn / Game Over
            lives--;
            if (lives <= 0) {
              gameState = 2;  //Game Over!
            } else {
              xPos = 100.f;
              yPos = 450.f;
              velocityY = 0.f;
            }
          }
        }
      }
    }
    //Boden-Kollision für Abrung-Respawn / Boden
    if (yPos > height) {
      lives--;  //Auch der Abgrund kostet 1 Leben!
      if (lives <= 0) {
        gameState = 2;  //Game Over!
      } else {
        xPos = 100.f;
        yPos = 450.f;
        velocityY = 0.f;
        jumpCount = 0;   //NEU: Beim Respawn den Zähler zurücksetzten
      }
    }

    //Ziel-Kollision prüfen
    if (xPos < goal.x + goal.w &&xPos + size > goal.x &&
      yPos < goal.y + goal.h &&yPos + size > goal.y) {
      gameState = 1;
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

//Die Münz-Klasse
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

//Die Gegner-Klasse
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

//Die Goal-Klasse für die Ziel-Flagge
class Goal {
  float x, y;
  float w = 40.f;
  float h = 100.f;

  public Goal(float x, float y) {
    this.x = x;
    this.y = y;
  }

  public void draw() {
    //Fahnenmast (Grau)
    fill(100);
    rect(x, y, 10.f, h);

    //Tuch/Flagge (Grün)
    fill(0, 200, 0);
    triangle(x +10.f, y, x + 40.f, y + 20.f, x + 10.f, y +40.f);
  }
}
