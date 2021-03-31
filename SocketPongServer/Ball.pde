public class Ball {
  int[] colorProgression = {#FFFFFF, #FFFF00, #FFFA00, #FF0000,
                            #800080, #0000FF};
  int colorProgressionIndex;
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
    this.colorProgressionIndex = 0;
    this.ballColor = colorProgression[this.colorProgressionIndex];
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

      int calcSpeed = int(random(speed)) + 5;
      this.speedX = (random(1) >= 0.5) ? calcSpeed : -calcSpeed;

      calcSpeed = int(random(speed)) + 3;
      this.speedY = (random(1) >= 0.5) ? calcSpeed : -calcSpeed;
    }
  }

  // Modified from:
  // http://jeffreythompson.org/collision-detection/circle-rect.php
  void isCollision(Paddle p) {
    // temporary variables to set edges for testing
    String sideX = "";
    String sideY = "";
    float testX = this.x;
    float testY = this.y;

    // which edge is closest?
    if (this.x < p.x) {
      testX = p.x;                        // Ball is left of the paddle
      sideX = "left";
    } else if (this.x > p.x + (Paddle.PADDLE_WIDTH/2)) {
      testX = p.x + Paddle.PADDLE_WIDTH;  // Ball is right of the paddle
      sideX = "right";
    }
    if (this.y < p.y) {
      testY = p.y;                        // Ball is above the paddle
      sideY = "top";
    } else if (this.y > p.y + p.size) {
      testY = p.y + p.size;               // Ball is below the paddle
      sideY = "bottom";
    }

    // get distance from closest edges
    float distX = this.x - testX;
    float distY = this.y - testY;
    float distance = sqrt( (distX*distX) + (distY*distY) );

    // if the distance is less than the radius, collision!
    if (distance <= this.size / 2) {
      if( !this.isIntersects ){
        this.isIntersects = true;
        
        // Ball speed increases each collision with the paddle
        this.speedX += 2;
        this.speedY += 2;
        
        // Change the color the faster the ball gets!
        this.colorProgressionIndex += 1;
        if( this.colorProgressionIndex >= colorProgression.length ){
          this.ballColor = color(random(255), random(255), random(255));
        } else {
          this.ballColor = colorProgression[colorProgressionIndex];
        }
        
        switch(sideX) {
          case "right":
            this.speedX = (this.speedX < 0) ? -this.speedX : this.speedX;
            break;
          case "left":
            this.speedX = (this.speedX > 0) ? -this.speedX: this.speedX;
            break;
          default:
            // Can't tell where the ball is so make
            // no changes to the direction
            break;
        }   
        switch(sideY) {
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
      if( this.isIntersects ){
        this.isIntersects = false;
      }
    }
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
