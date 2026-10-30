void setup() {
  //Fenstergröße festlegen (Breite, Höhe in Pixeln
  size(800, 600);
}

void draw() {
  //Hintergründe festlegen (ein helles Blau für den Himmel)
  //Die Zahlen stehen für Rot, Grün, Blau
  background(135, 206, 235);

  //Unsere Spielfigur (erstmal nur ein simples Rechteck)
  //rect(xPos, yPos, breite, höhe)
  rect(100, 100, 50, 50);
}
