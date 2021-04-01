import java.util.*;
import processing.net.*;
import javax.swing.JOptionPane;

static final boolean SERVER_DEBUG_ENABLED = false;
static final boolean CLIENT_DEBUG_ENABLED = false;
Client client;
ArrayList<Ball> pongBalls;
Object ballListModLock = new Object();
Object paddleHmModLock = new Object();
HashMap<String, Paddle> paddles = new HashMap<String, Paddle>();
Paddle myPaddle;

String jsonClientMsg;
int ballDiameter = 50;
int paddleLength = 100;
int scoreLeft = 0;
int scoreRight = 0;
int updateFreqMs = 20;
int now;

void setup() {
  size(800, 600);
  
  myPaddle = getUserPaddle();
  paddles.put(myPaddle.name, myPaddle);
  pongBalls = new ArrayList<Ball>();
  client = new Client(this, "76.167.223.125", 8443);
  //client = new Client(this, "44.233.116.248", 8080);
  now = millis();
}

void draw() {
  background(0);
  
  sendDataToServer();
  
  readDataFromServer();
  
  // No need to update the other paddles, their info comes directly from
  // the client messages
  myPaddle.update();

  drawPongBalls();

  drawPaddles();
  
  drawScore();
}

void drawPongBalls(){
  synchronized(ballListModLock) {
    for( Ball ball : pongBalls ){
      ball.draw();
    }
  }
}

void drawPaddles(){
  synchronized(paddleHmModLock){
    for( String paddleName : paddles.keySet() ){
      paddles.get(paddleName).draw();
    }
  }
}

void drawScore(){
  textSize(22);
  fill(#FFFF00);
  text("Score: " + scoreLeft, 50, 50);
  text("Score: " + scoreRight, width - 100 - 50, 50);
}

Paddle getUserPaddle(){
  String leftOrRight = "";
  String initials = "";
  
  while( !leftOrRight.equals("l") && !leftOrRight.equals("r") ){
    leftOrRight = JOptionPane.showInputDialog("Left or Right side?(l/r)").toLowerCase();
  }
  
  while( initials.length() == 0 ){
    initials = JOptionPane.showInputDialog("Enter your initials:").toUpperCase();
  }
  
  initials = initials.length() > 3 ? initials.substring(0, 3) : initials;
  color randomColor = color(random(255), random(255), color(255));

  if( leftOrRight.equals("l") ){
    return new Paddle(initials, paddleLength, Paddle.PADDLE_LEFT, randomColor);
  } 
  
  return new Paddle(initials, paddleLength, Paddle.PADDLE_RIGHT, randomColor);
}

String generateJsonGameInfo(){
  JSONArray paddleArr = new JSONArray();
  JSONObject paddleObj = myPaddle.toJsonObj(null);
  
  paddleArr.setJSONObject(0, paddleObj);

  JSONObject obj = new JSONObject();
  obj.setJSONArray("paddles", paddleArr);
  return obj.toString();
}

void parseScore(String gameInfoJsonString) {
  JSONObject jsonObj = parseJSONObject(gameInfoJsonString);
  if( jsonObj != null ){
    scoreLeft = jsonObj.getInt("scoreLeft");
    scoreRight = jsonObj.getInt("scoreRight");
  }
}

void parseJsonPongBalls(String gameInfoJsonString){
  JSONObject obj = parseJSONObject(gameInfoJsonString);
  JSONArray pongBallsObj = obj.getJSONArray("pongBalls");
  
  synchronized(ballListModLock){
    // TODO: optimize this later. Maybe more efficient way than to clear
    // the list and re-add pong balls every cycle.
    pongBalls.clear();
  
    for( int i = 0; i < pongBallsObj.size(); i++ ){
      JSONObject ballObj = pongBallsObj.getJSONObject(i);
      Ball b = new Ball(ballDiameter, 3);
      b.parseJsonString(ballObj);
      pongBalls.add(b);
    }
  }
}

void parseJsonPaddles(String gameInfoJsonString){
  JSONObject obj = parseJSONObject(gameInfoJsonString);
  JSONArray paddlesObj = obj.getJSONArray("paddles");
  
  // Code needs to be synch because it modifies the size of the paddles HM 
  synchronized(paddleHmModLock){
    for( int i = 0; i < paddlesObj.size(); i++ ){
      JSONObject paddleObj = paddlesObj.getJSONObject(i);
      String paddleName = paddleObj.getString("name");

      // DO NOT update the client's paddle from server info,
      // it's updated in the client code (i.e., this code)
      if( paddleName.equals(myPaddle.name) ){
        continue; 
      }
      
      if( paddles.containsKey( paddleName ) ){
        Paddle paddle = paddles.get(paddleName);
        paddle.x = paddleObj.getInt("x");
        paddle.y = paddleObj.getInt("y");
      } else {
        int paddleLR = paddleObj.getInt("x") == 0 ? Paddle.PADDLE_LEFT : Paddle.PADDLE_RIGHT;
        paddles.put(paddleName, new Paddle(paddleName, paddleLength, paddleLR, paddleObj.getInt("Color")));
      }
    }
  }
}

/*
 * Send message to server/host
 */
void sendDataToServer(){
  if(millis() > now + updateFreqMs) {
    jsonClientMsg = generateJsonGameInfo();
    if( CLIENT_DEBUG_ENABLED ){ println("Client Sending\n" + jsonClientMsg); }
    client.write(jsonClientMsg);
    now = millis();
  }
}

/*
 * Called when getting a message from the server/host
 */
void readDataFromServer(){
  if (client.available() > 0) { 
    String gameInfoJsonString = client.readString();
    
    if( SERVER_DEBUG_ENABLED ){ println("message from server:\n" + gameInfoJsonString); }
    parseJsonPaddles(gameInfoJsonString);
    parseJsonPongBalls(gameInfoJsonString);
    parseScore(gameInfoJsonString);
  }
}
