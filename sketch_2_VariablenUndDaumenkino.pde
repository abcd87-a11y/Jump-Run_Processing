//Wir deklarieren unsere Variablen für die Position ganz oben
//(In reinem Java wären das jetzt die Attribute unserer Klasse)
float playerX = 100.f;
float playerY = 100.f;


void setup() {
  size(800, 600);
}

void draw() {
  background(135, 206, 235);
  
  //Logik: Wir verändern die xPos bei jedem Frame um 2 Pixel;
  playerX = playerX + 2.f;

  //Zeichnen: Wir nutzen jetzt die Variablen, nicht mehr die festen Zahlen!
  rect(playerX, playerY, 50, 50);
  
  //%.1f formatiert die float-Zahl auf eine Nachkommastelle.
  //%n ist in printf der sichere Zeilenumbruch.
  System.out.printf("Aktuelle X-Position: %.1f%n", playerX);
}
