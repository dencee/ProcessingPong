public class Paddle {
  static final int PADDLE_WIDTH = 30;
  static final int PADDLE_LEFT = 0;
  static final int PADDLE_RIGHT = 1;
  int x;
  int y;
  int size;
  int speed;
  boolean isAlive;
  Integer paddleColor;
  Integer paddleLR;
  String paddleDirection;
  String name;
  JSONObject jsonOut;
  JSONObject jsonIn;
  
  Paddle(String name, int paddleSize, int paddleLR, Integer paddleColor){
    this.name = name;
    this.y = height / 2;
    this.size = paddleSize;
    this.speed = 15;
    this.isAlive = false;
    this.paddleColor = (paddleColor == null) ? #FFFFFF : paddleColor;
    this.paddleLR = paddleLR;
    this.paddleDirection = "";
    jsonOut = new JSONObject();
    jsonIn = new JSONObject();
    
    if( paddleLR == PADDLE_LEFT ){
      this.x = 0;
    } else if( paddleLR == PADDLE_RIGHT ){
      this.x = width - PADDLE_WIDTH;
    }
  }
  
  void draw(){
    push();
    
    strokeWeight(5);
    stroke(this.paddleColor);
    fill(this.paddleColor, 50);
    rect(this.x, this.y, PADDLE_WIDTH, this.size);
    textSize(22);
    fill((this.paddleColor ^ 0x00FFFFFF) | 0xFF000000);  // Invert color with max alpha 
    strokeWeight(15);
    text(this.name.replace("", "\n").trim(), this.x + 5, this.y + 25);
    
    pop();
  }
  
  void update(){
    if (keyPressed && key == CODED) {
      if (keyCode == UP) {
        this.paddleDirection = "up";
        this.y = (this.y - this.speed >= 0) ? this.y - this.speed : 0;
      } else if (keyCode == DOWN) {
        this.paddleDirection = "down";
        boolean isAboveScreen = this.y + this.size + this.speed < height;
        this.y = isAboveScreen ? this.y + this.speed : height - this.size;
      }
    }
  }
  
  JSONObject toJsonObj(JSONObject jsonObj){
    this.jsonOut = (jsonObj == null) ? new JSONObject() : jsonObj;
    
    this.jsonOut.setString("name", this.name);
    this.jsonOut.setInt("x", this.x);
    this.jsonOut.setInt("y", this.y);
    this.jsonOut.setInt("Color", this.paddleColor);
    return this.jsonOut;
  }
  
  void parseJsonString(String jsonString){
    jsonIn = parseJSONObject(jsonString);
    if( jsonIn != null ){
      this.x = jsonIn.getInt("x");
      this.y = jsonIn.getInt("y");
      this.paddleColor = jsonIn.getInt("Color");
    }
  }
}
