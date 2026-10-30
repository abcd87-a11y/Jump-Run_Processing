//Die Oberklasse - das Fundament für ALLES in unserer Spielwelt
class GameObject {
  protected float x, y;
  protected float w, h;

  public GameObject(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  //AABB-Kollisionsprüfung
  public boolean touches(GameObject other) {
    return (this.x < other.x + other.w &&
      this.x + this.w > other.x &&
      this.y < other.y + other.h &&
      this.y + this.h > other.y);
  }
}
