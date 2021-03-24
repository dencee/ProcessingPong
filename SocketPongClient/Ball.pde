public class Ball {
  int x;
  int y;
  int size;
  int speed;
  int speedX;
  int speedY;
  boolean isAlive;
  boolean isIntersects;
  JSONObject jsonOut;
  JSONObject jsonIn;

  Ball(int size, int speed) {
    this.x = width / 2;
    this.y = height / 2;
    this.size = size;
    this.speed = speed;
    this.speedX = 0;
    this.speedY = 0;
    this.isAlive = false;
    this.isIntersects = false;
    jsonOut = new JSONObject();
    jsonIn = new JSONObject();
  }

  void draw() {
    fill(#FFFFFF);
    ellipse(this.x, this.y, this.size, this.size);
  }

  void update() {
    this.x += this.speedX;
    this.y += this.speedY;

    // Reset if out of bounds left or right
    if ( this.x < -this.size || this.x - this.size > width) {
      this.isAlive = false;
    }

    // Rebound top or bottom
    if ( this.y - this.size <= 0 || this.y + this.size >= height ) {
      this.speedY = -this.speedY;
    }
  }

  void startBall() {
    if ( !this.isAlive ) {
      this.isAlive = true;
      this.x = width / 2;
      this.y = height / 2;

      int calcSpeed = int(random(speed)) + 3;
      this.speedX = (random(1) >= 0.5) ? calcSpeed : -calcSpeed;

      calcSpeed = int(random(speed)) + 3;
      this.speedY = (random(1) >= 0.5) ? calcSpeed : -calcSpeed;
    }
  }

  // Modified from:
  // http://jeffreythompson.org/collision-detection/circle-rect.php
  void isCollision(Paddle p) {
    // temporary variables to set edges for testing
    String side = "";
    float testX = this.x;
    float testY = this.y;

    // which edge is closest?
    if (this.x < p.x) {
      testX = p.x;                        // Ball is left of the paddle
      side = "left";
    } else if (this.x > p.x + Paddle.PADDLE_WIDTH) {
      testX = p.x + Paddle.PADDLE_WIDTH;  // Ball is right of the paddle
      side = "right";
    }
    if (this.y < p.y) {
      testY = p.y;                        // Ball is above the paddle
      side = "top";
    } else if (this.y > p.y + p.size) {
      testY = p.y + p.size;               // Ball is below the paddle
      side = "bottom";
    }

    // get distance from closest edges
    float distX = this.x - testX;
    float distY = this.y - testY;
    float distance = sqrt( (distX*distX) + (distY*distY) );

    // if the distance is less than the radius, collision!
    if (distance <= this.size / 2) {
      println("collision " + side);
      if ( !this.isIntersects ) {
        this.isIntersects = true;
        
        switch(side){
          case "right":
            this.speedX = (this.speedX < 0) ? -this.speedX : this.speedX;
            break;
          case "left":
            this.speedX = (this.speedX > 0) ? -this.speedX : this.speedX;
            break;
          case "top":
            this.speedY = (this.speedY > 0) ? -this.speedY : this.speedY;
            break;
          case "bottom":
            this.speedY = (this.speedY < 0) ? -this.speedY : this.speedY;
            break;
          default:
            // Can't tell where the ball is so make
            // no changes to the direction
            break;
        }
      }
    } else {
      /*
       * Sometimes upon first collision the ball would still be within
       * the paddle, causing the ball to rebound back and forth.
       * Resetting the variable here ensures there's only 1 change of
       * direction until the ball and paddle no longer intersect 
       */
      this.isIntersects = false;
      println("collision reset");
    }
  }

  JSONObject toJsonObj(JSONObject jsonObj) {
    JSONObject obj = (jsonObj == null) ? jsonOut : jsonObj;

    obj.setInt("ballX", this.x);
    obj.setInt("ballY", this.y);
    return obj;
  }

  void parseJsonString(String jsonString) {
    jsonIn = parseJSONObject(jsonString);
    if ( jsonIn != null ) {
      this.x = jsonIn.getInt("ballX");
      this.y = jsonIn.getInt("ballY");
    }
  }
}
