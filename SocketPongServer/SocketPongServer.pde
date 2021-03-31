import java.util.*;
import processing.net.*;

static final boolean SERVER_DEBUG_ENABLED = false;
static final boolean CLIENT_DEBUG_ENABLED = false;
Server server;
Client client;
ArrayList<Ball> pongBalls;
Object paddleHmModLock = new Object();
HashMap<String, Paddle> paddles = new HashMap<String, Paddle>();
Paddle myPaddle;

String jsonClientMsg;
boolean ballAdded = false;
int ballDiameter = 50;
int paddleLength = 100;
int scoreLeft = 0;
int scoreRight = 0;
int updateFreqMs = 20;
int now;

void setup(){
  size(800, 600);
  background(0);
/*  
  String leftOrRight = "";
  String initials = "";
  
  fill(255);
  textSize(26);
  text("Do you want a paddle on the\n    left or right side (L/R)?", 200, height/2);
  while(true){
    if( keyPressed ){
      if( key==ENTER||key==RETURN ){
        break;
      } else {
        println("pressed");
        leftOrRight += key;
        text(leftOrRight, 100, height/2 + 100);
      }
    }
  }
  
  while(true){
    text("Enter Your Initials", 100, height/2);
    if( keyPressed ){
      if( key==ENTER||key==RETURN ){
        break;
      } else {
        initials += key;
      }
    }
  }
*/  
  pongBalls = new ArrayList<Ball>();
  myPaddle = new Paddle("server", paddleLength, Paddle.PADDLE_LEFT, #FF0000);
  paddles.put("server", myPaddle);
  server = new Server(this, 8443);
  now = millis();
}

void draw(){
  background(0);

  sendDataToClients();
  
  readDataFromClient();
  
  addPongBall();
  
  purgePongBalls();

  // No need to update the other paddles, their info comes directly from
  // the client messages
  myPaddle.update();
  
  updateAndDrawPongBalls(); //<>//
  
  drawPaddles();

  drawScore();
}

void addPongBall(){
  if( keyPressed ){
    if( key == 's' && !ballAdded ){
      ballAdded = true;
      pongBalls.add( new Ball(ballDiameter, 3) );
      
      for( Ball b : pongBalls ){
        b.startBall();
      }
    }
  }
}

void purgePongBalls(){
Iterator<Ball> it = pongBalls.iterator();
  while(it.hasNext()){
    Ball b = it.next();
    if( !b.isAlive ){
      if( b.x < 0 ){
        scoreRight = scoreRight + 1;
      } else if ( b.x > width ){
        scoreLeft = scoreLeft + 1;
      }
      it.remove();
    }
  }
}

void updateAndDrawPongBalls(){
  for( Ball ball : pongBalls ){
    ball.update();
    
    for( String paddleName : paddles.keySet() ){
      Paddle paddle = paddles.get(paddleName);
      
      // TODO: This can be optimized
      if( ball.x < width / 2 ){
        if( paddle.paddleLR == Paddle.PADDLE_LEFT ){
          ball.isCollision(paddle);
        }
      } else {
        if( paddle.paddleLR == Paddle.PADDLE_RIGHT ){
          ball.isCollision(paddle);
        }
      }
    }
    
    ball.draw();
  }
}

void drawPaddles(){
  synchronized(paddleHmModLock){
    for( String paddleName : paddles.keySet() ){
      Paddle paddle = paddles.get(paddleName);
      paddle.draw();
    }
  }
}

void keyTyped(){
  
}

void keyReleased(){
 ballAdded = false;
 myPaddle.paddleDirection = ""; 
}

String generateJsonGameInfo(){
    JSONArray paddleArrObj = new JSONArray();
    JSONArray ballArrObj = new JSONArray();
    
    int cnt = 0;
    for( String id : paddles.keySet() ){
      JSONObject paddleObj = paddles.get(id).toJsonObj(null);
      paddleArrObj.setJSONObject(cnt, paddleObj);
      cnt++;
    }
    
    for( int i = 0; i < pongBalls.size(); i++ ){
      JSONObject ballObj = pongBalls.get(i).toJsonObj(null); //<>//
      ballArrObj.setJSONObject(i, ballObj);
    }
    
    JSONObject obj = new JSONObject();
    obj.setJSONArray("paddles", paddleArrObj);
    obj.setJSONArray("pongBalls", ballArrObj);    
    obj.setInt("scoreLeft", scoreLeft);
    obj.setInt("scoreRight", scoreRight);
    
    return obj.toString();
}

void drawScore(){
  textSize(22);
  fill(#FFFF00);
  text("Score: " + scoreLeft, 50, 50);
  text("Score: " + scoreRight, width - 100 - 50, 50);
}

void parseJsonPaddles(String gameInfoJsonString){
  JSONObject obj = parseJSONObject(gameInfoJsonString);
  JSONArray paddlesObj = obj.getJSONArray("paddles");
  
  // Code needs to be synch because it modifies the size of the paddles HM 
  synchronized(paddleHmModLock){ //<>//
    for( int i = 0; i < paddlesObj.size(); i++ ){
      JSONObject paddleObj = paddlesObj.getJSONObject(i);
      String paddleName = paddleObj.getString("name");
      
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
 * Send message to client(s)/player(s)
 */
void sendDataToClients(){
  if(millis() > now + updateFreqMs) {
    jsonClientMsg = generateJsonGameInfo();
    if( SERVER_DEBUG_ENABLED ){ println("Server Sending\n" + jsonClientMsg); }
    server.write(jsonClientMsg);
    now = millis();
  }
}

/*
 * Get a message from the client(s)/player(s)
 */
void readDataFromClient(){
  client = server.available();
  if( client != null ){
    String input = client.readString();
    parseJsonPaddles(input);
  }
}
