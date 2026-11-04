//=== HAUPTPROGRAMM ===
Player player;
Platform[] platforms = new Platform[6];  //(Bodenabschnitte + Plafformen)
Coin[] coins = new Coin[5];
Enemy[] enemies = new Enemy[2];
FlyingEnemy[] flyers = new FlyingEnemy[1];    //NEU
Spike[] spikes = new Spike[14];
Bullet[] bullets = new Bullet[10];
Goal goal;

int score = 0;
int lives = 3;      //wir starten mir 3 Leben
int gameState = 0;  //0 = Spielen, 1 = Gewonnen, 2 = Game Over(NEU)

float groundY = 500.f;
boolean leftPressed = false;
boolean rightPressed = false;
float cameraX = 0.f;

int lastTime = 0;
float dt = 0.f;

//Variable deklarieren
PImage playerImg;

void setup() {
  size(800, 600);
  playerImg = loadImage("player.png");
  resetGame();    //Wir rufen einfach unsere Reset-Funktion auf!
}

//Auf Startpunkt zurücksetzen
void resetGame() {
  score = 0;
  lives = 3;
  gameState = 0;
  cameraX = 0.f;
  
  //NEU: playerImg als Parameter an den Konstruktor übergeben
  player = new Player(100.f, height-100.f-50.f, playerImg);

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

  //NEU Fliegende Gegner in der Luft platzieren (fliegt zwischen Y = 150 und Y = 350)
  flyers[0] = new FlyingEnemy(1100.f, 250.f, 150.f, 350.f);

  //Ziel
  goal = new Goal(2500.f, groundY  - 100.f);

  //Spikes
  spikes[0] = new Spike(400.f, groundY - 30.f);    //Stachel auf dem ersten Boden
  spikes[1] = new Spike(700.f, 300.f -30.f);       //Zweite auf ersten Block
  float wert = 30.f;
  for (int i = 2; i <14; i++) {
    spikes[i] = new Spike(2500.f+wert, groundY -30.f);       //Hinter dem Ziel
    wert+= 30;
  }

  //NEU: Alle Kugeln im Magazin zurücksetzen
  for (int i = 0; i < bullets.length; i++) {
    bullets[i] = null;
  }
}

void draw() {
  //Delta Time in Sekunden berechnen
  int currentTime = millis();
  dt = (currentTime - lastTime) / 1000.f;
  lastTime = currentTime;
  //Schutz vor Ausreißen (z.B. beim Fenster-Moven oder Laden)
  if(dt > 0.1f) dt = 0.1f;
  
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
    
    //Player bekommt jetzt dt übergeben
    player.update(leftPressed, rightPressed, platforms, coins, enemies, flyers, spikes, bullets, goal,dt);
    player.draw();


    //Platform
    for (int i = 0; i < platforms.length; i++)  platforms[i].draw();
    //Coins
    for (int i = 0; i < coins.length; i++) coins[i].draw();
    
    //Enemies
    for (int i = 0; i < enemies.length; i++) {
      enemies[i].update(dt);
      enemies[i].draw();
    }

    //Flying Enemies
    for (int i = 0; i < flyers.length; i++) {
      flyers[i].update(dt);
      flyers[i].draw();
    }

    //Abgefeuerte Projektile fliegen lassen und zeichnen
    //NEU: Bullets mit cameraX updaten
    for (int i = 0; i < bullets.length; i++) {
      if (bullets[i] != null) {
        bullets[i].update(cameraX, dt);  //cameraX und dt wird mitgegeben
        bullets[i].draw();
      }
    }

    //Spikes
    for (int i = 0; i < spikes.length; i++) {
      spikes[i].draw();
    }

    goal.draw();

    //UsetInterface(UI): Score zeichnen
    fill(0);
    textSize(24);
    text("Score: " + score, cameraX + 20, 40);
    //UI für Leben zeichnen (3 rote Quadrate/Herzen obren rechts)
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
  if (key == 'r' || key == 'R') resetGame();

  if (key =='f' || key == 'F') player.shoot(bullets);
}

void keyReleased() {
  if (key =='a' || key == 'A') leftPressed = false;
  if (key =='d' || key == 'D') rightPressed = false;
}
