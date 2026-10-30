//Position- und Geschwindigkeits-Variablen
float playerX = 100.f;
float playerY = 100.f;
float speed = 5.f;    //Wie schnell sind wir?

//Wahrheitswerte (Booleans) für unsere Steuerung
boolean leftPressed = false;
boolean rightPressed = false;

void setup() {
  size(800, 600);
}

void draw() {
  background(135, 206, 235);
  
 //1.Logik: Wir prüfen die Booleans
 //das passiert ~60x pro Sekunde, also extrem flüssig
 if(leftPressed == true) playerX -= speed;
 if(rightPressed == true) playerX += speed;
 
 //2. Zeichnen
 rect(playerX,playerY, 50,50);
}

//Java-Event: Wird vom System aufgerufen, sobald eine Taste Heruntergedrückt wird
void keyPressed(){
 //'key' ist eine in Processing eingebaute Variable vom Typ char (Zeichen)
 if(key == 'a' || key == 'A') leftPressed = true;
 if(key == 'd' || key == 'D') rightPressed = true;
}

//Java-Event: Wird vom System aufgerufen, sobald eine Taste Losgelassen wird
void keyReleased(){
 if(key =='a' || key == 'A') leftPressed = false;
 if(key =='d' || key == 'D') rightPressed = false;
}
