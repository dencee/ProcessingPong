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
  String paddleDirection;
  String name;
  JSONObject jsonOut;
  JSONObject jsonIn;
  
  Paddle(int paddleSize, int paddleLR, Integer paddleColor){
    this.y = height / 2;
    this.size = paddleSize;
    this.speed = 15;
    this.isAlive = false;
    this.paddleColor = (paddleColor == null) ? #FFFFFF : paddleColor;
    this.paddleDirection = "";
    jsonOut = new JSONObject();
    jsonIn = new JSONObject();
    
    if( paddleLR == PADDLE_LEFT ){
      this.x = 0;
      this.name = "paddleL";
    } else if( paddleLR == PADDLE_RIGHT ){
      this.x = width - PADDLE_WIDTH;
      this.name = "paddleR";
    }
  }
  
  void draw(){
    fill(this.paddleColor);
    rect(this.x, this.y, PADDLE_WIDTH, this.size);
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
    
    this.jsonOut.setInt(this.name + "X", this.x);
    this.jsonOut.setInt(this.name + "Y", this.y);
    this.jsonOut.setInt(this.name + "Color", this.paddleColor);
    return this.jsonOut;
  }
  
  void parseJsonString(String jsonString){
    jsonIn = parseJSONObject(jsonString);
    if( jsonIn != null ){
      this.x = jsonIn.getInt(this.name + "X");
      this.y = jsonIn.getInt(this.name + "Y");
      this.paddleColor = jsonIn.getInt(this.name + "Color");
    }
  }
}
