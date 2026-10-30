//Position- und Geschwindigkeits-Variablen
float playerX = 100.f;
float playerY = 100.f;
float speed = 5.f;

//NEU: Variablen für den Sprung
float velocityY = 0.f;      //Aktuelle Fall-/Sprunggeschwindigkeit
float gravity = 0.5f;       //Schwerkraft zieht uns jede Frame nach unten
float jumpStrength = -12.f; //Minus, weil nach oben = kleineres Y
float groundY = 500.f;      //Wo ist der Boden?
boolean isJumping = false;  //Verhindert Doppelsprünge in der Luft


//Wahrheitswerte für unsere Steuerung
boolean leftPressed = false;
boolean rightPressed = false;

void setup() {
  size(800, 600);
}

void draw() {
  background(135, 206, 235);

  //1. HORIZONTALE LOGIK
  if (leftPressed && playerX >0) playerX -= speed;
  if (rightPressed && (playerX+50) < width) playerX += speed;

  //2. Vertikale Logik (Schwerkraft)
  velocityY += gravity;        //Schwerkraft macht uns immer schneller nach unten
  playerY += velocityY;        //Geschwindigkeit auf die Position anwenden

  //3.Kollision mit dem Boden
  //playerY ist die Oberkante des Rechtecks. Die Unterkante ist playerY + 50 (Höhe)
  if (playerY + 50 >= groundY) {
    playerY = groundY-50;      //Spieler exakt bündig auf den Boden setzen
    velocityY = 0.f;           //Aufprall: Wir fallen nicht weter
    isJumping = false;         //Wir beühren den Boden und dürfen wieder springen
  }

  //4. Zeichnen
  //Erst den Boden zeichnen (Grün: R=34,G139,B34)
  fill(34, 139, 34);
  rect(0, groundY, width, height-groundY); //Von x = 0, y = 500 bis ganz nach unten

  //Dann den Spieler zeichnen (weiß)
  fill(255);
  rect(playerX, playerY, 50, 50);
}


void keyPressed() {
  if (key == 'a' || key == 'A') leftPressed = true;
  if (key == 'd' || key == 'D') rightPressed = true;

  //NEU: Sprung mit Leertaste (nur möglich, wenn wir nicht schon springen)
  if (key == ' ' && !isJumping) {
    velocityY = jumpStrength;    //Wir geben einen stakren Impuls nach Oben
    isJumping = true;            //Wir sind jetzt in der Luft
  }
}

//Java-Event: Wird vom System aufgerufen, sobald eine Taste Losgelassen wird
void keyReleased() {
  if (key =='a' || key == 'A') leftPressed = false;
  if (key =='d' || key == 'D') rightPressed = false;
}
