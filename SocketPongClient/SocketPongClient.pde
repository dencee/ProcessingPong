import java.util.*;
import websockets.*;

static final boolean SERVER_DEBUG_ENABLED = false;
static final boolean CLIENT_DEBUG_ENABLED = false;
WebsocketClient wsc;
ArrayList<Ball> pongBalls;
Object listModLock = new Object();
Paddle paddleLeft;
Paddle paddleRight;

String jsonClientMsg;
int ballDiameter = 50;
int paddleLength = 100;
int scoreLeft = 0;
int scoreRight = 0;
int updateFreqMs = 20;
int now;

void setup() {
  size(800, 800);
  
  pongBalls = new ArrayList<Ball>();
  paddleLeft = new Paddle(paddleLength, Paddle.PADDLE_LEFT, null);
  paddleRight = new Paddle(paddleLength, Paddle.PADDLE_RIGHT, #0000FF);
  //wsc= new WebsocketClient(this, "ws://localhost:8000/unnamed");
  //wsc= new WebsocketClient(this,  "ws://172.31.61.66:8843");
  wsc= new WebsocketClient(this,  "ws://44.242.154.68:8843");
  now = millis();
}

void draw() {
  background(0);

  // Send message to server/host
  if(millis() > now + updateFreqMs) {
    jsonClientMsg = paddleRight.toJsonObj(null).toString();
    if( CLIENT_DEBUG_ENABLED ){ println("Client Sending\n" + jsonClientMsg); }
    wsc.sendMessage(jsonClientMsg);
    now = millis();
  }

  paddleRight.update();
  
  synchronized(listModLock) {
    for( Ball ball : pongBalls ){
      if( ball.x < width / 2 ){
        ball.isCollision(paddleLeft);
      } else {
        ball.isCollision(paddleRight);
      }
    
      ball.draw();
    }
  }

  paddleLeft.draw();
  paddleRight.draw();
  drawScore();
}

void drawScore(){
  fill(paddleLeft.paddleColor);
  text("Score: " + scoreLeft, 50, 50);
  fill(paddleRight.paddleColor);
  text("Score: " + scoreRight, width - 100 - 50, 50);
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
  
  synchronized(listModLock){
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

// Called when getting a message from the server/host
void webSocketEvent(String gameInfoJsonString){
  if( SERVER_DEBUG_ENABLED ){
    println("message from server:\n" + gameInfoJsonString);
  }
  paddleLeft.parseJsonString(gameInfoJsonString);
  parseJsonPongBalls(gameInfoJsonString);
  parseScore(gameInfoJsonString);
}
