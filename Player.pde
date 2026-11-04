class Player extends GameObject {
  //Werte jetzt skaliert auf SEL-Einheiten (pro Sekunde)
  private float speed = 300.f;
  private float velocityY = 0.f;
  private float gravity = 1200.f;
  private float jumpStrength = -550.f;

  //Sprung-Zähler für Doppelsprung
  private int jumpCount = 0;
  private int maxJumps = 2;

  //NEU: Blickrichtung und Schuss-Cooldown
  private boolean facingRight = true;
  private float shootCooldown = 0.f;
  private float cooldownTime = 0.25f;  //0.25 Sekunden Pause statte Frame-Anzahl

  private PImage img;  //NEU: Variable für das Spieler-Bild

  public Player(float startX, float startY, PImage img) {
    super(startX, startY, 50.f, 50.f);
    this.img = img;
  }

  public float getXPos() {
    return this.x;
  }

  // RÜCKGABE GEÄNDERT: boolean statt void
  public boolean jump() {
    if (jumpCount < maxJumps) {
      velocityY = jumpStrength;
      jumpCount++;
      return true; // Sprung erfolgreich!
    }
    return false;  // Kein Sprung mehr übrig
  }

  // RÜCKGABE GEÄNDERT: boolean statt void
  public boolean shoot(Bullet[] bullets, PImage bulletImg) {
    if (shootCooldown > 0) return false; // Noch am Nachladen

    for (int i = 0; i < bullets.length; i++) {
      if (bullets[i] == null || !bullets[i].isActive) {
        if (facingRight) {
          bullets[i] = new Bullet(x + w, y + (h / 2.f) - 5.f, 600.f, bulletImg);
        } else {
          bullets[i] = new Bullet(x - 10.f, y + (h / 2.f) - 5.f, -600.f, bulletImg);
        }
        shootCooldown = cooldownTime;
        return true; // Schuss erfolgreich!
      }
    }
    return false;
  }


  public void update(boolean left, boolean right, Platform[] platforms, Coin[] coins, Enemy[] enemies, FlyingEnemy[] flyers, Spike[] spikes, Bullet[] bullets, Goal goal, float dt, processing.sound.SoundFile coinSound) {
    //Horizontal mit dt bewegen
    if (left && x > 0) {
      x-= speed *dt;
      facingRight = false; //Schaut nach links
    }
    if (right) {
      x += speed *dt;
      facingRight = true;  //Schaut nach rechts
    }

    //Cooldown herunterzählen
    if (shootCooldown > 0) {
      shootCooldown -= dt;
    }

    //Gravitation und Veritkal-Bewegung mit dt
    velocityY += gravity *dt;
    y += velocityY *dt;

    //Plattform & Kollision (One-Way von oben)
    if (velocityY > 0) {
      for (int i = 0; i < platforms.length; i++) {
        Platform p = platforms[i];
        if (x + w > p.x && x < p.x + p.w) {
          if (y + h >= p.y && y + h - (velocityY * dt) <= p.y + 10.f) {
            y = p.y - h;
            velocityY = 0.f;
            jumpCount = 0; //Auf der Plattform landen setzt die Sprünge auf 0 zurück
          }
        }
      }
    }

    //Münze
    for (int i = 0; i < coins.length; i++) {
      Coin c = coins[i];
      if (!c.isCollected && this.touches(c)) {
        c.isCollected = true;
        score += 10;
        if (coinSound != null) coinSound.play(); //Sound abspielen!
        //Gelbe Partikel in der Mitte der Münze
        spawnParticles(c.x+c.w/2.f, c.y + c.h / 2.f, 255, 215, 0, 10);
      }
    }

    //Bodengegner
    for (int i = 0; i < enemies.length; i++) {
      Enemy e = enemies[i];
      if (e.isAlive && this.touches(e)) {
        if (velocityY > 0 && (y + h - (velocityY *dt)) <= e.y +15.f) {    //Denk drann Y steht aufm kopf, deshalb velocityY > 0 und  <= e.y + 15.f: Lag im letzten Frame noch über/auf der Oberkante des Gegners
          e.isAlive = false;
          velocityY = jumpStrength * 0.7f;
          score += 50;
          //Rote Partikel
          spawnParticles(e.x+e.w /2.f, e.y+ e.h/2.f, 220, 20, 60, 15);
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
    // Fliegende Gegner vs. Player (Berührung = Verletzung, kein Kopfsprung)
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
            //Orangene Treffer-Partikel
            spawnParticles(e.x + e.w / 2.f, e.y + e.h / 2.f, 255, 40, 0, 12);
          }
        }
      }
    }

    //Projektile vs. fliegende Gegner
    for (int i = 0; i < bullets.length; i++) {
      Bullet b = bullets[i];
      if (b != null && b.isActive) {
        for (int j = 0; j < flyers.length; j++) {
          FlyingEnemy f = flyers[j];
          if (f.isAlive && b.touches(f)) {
            f.isAlive = false;
            b.isActive = false;
            score += 75;
            //Violette Treffer-Partikel
            spawnParticles(f.x + f.w / 2.f, f.y + f.h /2.f, 148, 0, 211, 12);
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

  //NEU: draw()-Methode mit Bild-Untersützung
  public void draw() {
    if (img != null) {
      image(img, x, y, w, h);
    } else {
      fill(255);
      rect(x, y, w, h);
    }
  }
}
