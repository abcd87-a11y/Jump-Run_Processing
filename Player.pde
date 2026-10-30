class Player extends GameObject {
  private float speed = 5.f;
  private float velocityY = 0.f;
  private float gravity = 0.5f;
  private float jumpStrength = -12.f;

  //Sprung-Zähler für Doppelsprung
  private int jumpCount = 0;
  private int maxJumps = 2;

  //NEU: Blickrichtung und Schuss-Cooldown
  private boolean facingRight = true;
  private int shootCooldown = 0;
  private int cooldownTime = 15;  //15 Frames Pause zwischen den Schüssen (~0.25 Sek)

  public Player(float startX, float startY) {
    super(startX, startY, 50.f, 50.f);
  }

  public float getXPos() {
    return this.x;
  }

  public void jump() {
    if (jumpCount < maxJumps) {
      velocityY = jumpStrength;  //Impuls nach oben
      jumpCount++;               //Zähler hochzählen (1 = BodenSprung, 2 = LuftSprung
    }
  }

  //NEU: Schießen mit Blickrichtung und Cooldown
  public void shoot(Bullet[] bullets) {
    if (shootCooldown > 0) return;  //Noch am Nachladen

    for (int i = 0; i < bullets.length; i++) {
      if (bullets[i] == null || !bullets[i].isActive) {
        //Nach rechts schießen
        if (facingRight) {
          bullets[i] = new Bullet(x + w, y + (h / 2.f) - 5.f, 10.f);
        }
        //Nach links schießen
        else {
          bullets[i] = new Bullet(x-10.f, y + (h / 2.f) - 5.f, -10.f);
        }
        shootCooldown = cooldownTime; //Cooldown starten
        break;
      }
    }
  }

  //Signatur erweiter um Bullet[] bullets
  public void update(boolean left, boolean right, Platform[] platforms, Coin[] coins, Enemy[] enemies, FlyingEnemy[] flyers, Spike[] spikes, Bullet[] bullets, Goal goal) {
    //NEU: Blickrichtung beim Laufen aktualisieren
    if (left && x > 0) {
      x-= speed;
      facingRight = false; //Schaut nach links
    }
    if (right) {
      x += speed;
      facingRight = true;  //Schaut nach rechts
    }

    //NEU: Cooldown herunterzählen
    if (shootCooldown > 0) {
      shootCooldown--;
    }

    //Sprung
    velocityY += gravity;
    y += velocityY;

    //Plattform & Kollision (One-Way von oben)
    if (velocityY > 0) {
      for (int i = 0; i < platforms.length; i++) {
        Platform p = platforms[i];
        if (x + w > p.x && x < p.x + p.w) {
          if (y + h >= p.y && y + h - velocityY <= p.y) {
            y = p.y - h;
            velocityY = 0.f;
            jumpCount = 0; //Auf der Plattform landen setzt die Sprünge auf 0 zurück
          }
        }
      }
    }

    //Münz-Kollision(Overlap) mit touches()
    for (int i = 0; i < coins.length; i++) {
      Coin c = coins[i];
      if (!c.isCollected && this.touches(c)) {
        c.isCollected = true;
        score += 10;
      }
    }

    //Gegner-Kollision nutzt jetzt e.w und e.h aus GameObject
    for (int i = 0; i < enemies.length; i++) {
      Enemy e = enemies[i];
      if (e.isAlive && this.touches(e)) {
        if (velocityY > 0 && (y + h - velocityY) <= e.y +15.f) {    //Denk drann Y steht aufm kopf, deshalb velocityY > 0 und  <= e.y + 15.f: Lag im letzten Frame noch über/auf der Oberkante des Gegners
          e.isAlive = false;
          velocityY = jumpStrength * 0.7f;
          score += 50;
        } else {
          //Leben abziehen & Respawn / Game Over
          lives--;
          if (lives <= 0) {
            gameState = 2;  //Game Over!
          } else {
            x = 100.f;
            y = 450.f;
            velocityY = 0.f;
          }
        }
      }
    }
    //NEU: Fliegende Gegner vs. Player (Berührung = Verletzung, kein Kopfsprung)
    for (int i = 0; i < flyers.length; i++) {
      FlyingEnemy f  = flyers[i];
      if (f.isAlive && this.touches(f)) {
        lives--;
        if (lives <= 0) {
          gameState = 2;  //Game Over
        } else {
          x = 100.f;
          y = 450.f;
          velocityY = 0.f;
        }
      }
    }

    //Projektile vs Gegner (Kugel <-> Gegner mit touches())
    for (int i = 0; i < bullets.length; i++) {
      Bullet b = bullets[i];
      if (b !=null && b.isActive) {
        for (int j = 0; j < enemies.length; j++) {
          Enemy e = enemies[j];
          if (e.isAlive && b.touches(e)) {
            e.isAlive = false;    //Gegner schalten wir aus
            b.isActive = false;   //Kugel verschwindet
            score += 50;
          }
        }
      }
    }

    //NEU: Projektile vs. fliegende Gegner
    for (int i = 0; i < bullets.length; i++) {
      Bullet b = bullets[i];
      if (b != null && b.isActive) {
        for (int j = 0; j < flyers.length; j++) {
          FlyingEnemy f = flyers[j];
          if (f.isAlive && b.touches(f)) {
            f.isAlive = false;
            b.isActive = false;
            score += 75;
          }
        }
      }
    }

    //Stachel mit touches
    for (int i = 0; i < spikes.length; i++) {
      Spike s = spikes[i];
      if (this.touches(s)) {
        //Treffer Leben abziehen und Respawn
        lives--;
        if (lives <= 0) {
          gameState = 2;  //Game over
        } else {
          x = 100.f;
          y = 450.f;
          velocityY = 0.f;
          jumpCount = 0;
        }
      }
    }

    //Boden-Kollision für Abrung-Respawn / Boden
    if (y > height) {
      lives--;  //Auch der Abgrund kostet 1 Leben!
      if (lives <= 0) {
        gameState = 2;  //Game Over!
      } else {
        x = 100.f;
        y = 450.f;
        velocityY = 0.f;
        jumpCount = 0;  //Beim Respawn den Zähler zurücksetzten
      }
    }

    //Ziel  mit touches()
    if (this.touches(goal)) gameState = 1;
  }

  public void draw() {
    fill(255);
    rect(x, y, w, h);
  }
}
