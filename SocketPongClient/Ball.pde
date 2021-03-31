public class Ball {
  int x;
  int y;
  int size;
  int speed;
  int speedX;
  int speedY;
  Integer ballColor;
  boolean isAlive;
  boolean isIntersects;
  JSONObject jsonOut;

  Ball(int size, int speed) {
    this.x = width / 2;
    this.y = height / 2;
    this.size = size;
    this.speed = speed;
    this.speedX = 0;
    this.speedY = 0;
    this.ballColor = #FFFFFF;
    this.isAlive = false;
    this.isIntersects = false;
    jsonOut = new JSONObject();
  }

  void draw() {
    push();
    
    strokeWeight(5);
    stroke(this.ballColor);
    fill(this.ballColor, 100);
    ellipse(this.x, this.y, this.size, this.size);
    
    pop();
  }

  JSONObject toJsonObj(JSONObject jsonObj) {
    JSONObject obj = (jsonObj == null) ? jsonOut : jsonObj;

    obj.setInt("color", this.ballColor);
    obj.setInt("x", this.x);
    obj.setInt("y", this.y);
    return obj;
  }

  void parseJsonString(JSONObject jsonObj) {
    if ( jsonObj != null ) {
      this.ballColor = jsonObj.getInt("color");
      this.x = jsonObj.getInt("x");
      this.y = jsonObj.getInt("y");
    }
  }
}
