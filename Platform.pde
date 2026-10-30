class Platform extends GameObject {
  public Platform(float x, float y, float w, float h) {
    super(x, y, w, h);
  }

  public void draw() {
    fill(139, 69, 19);
    rect(x, y, w, h);
  }
}
