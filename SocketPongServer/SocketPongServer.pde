import java.util.*;
import websockets.*;

static final boolean SERVER_DEBUG_ENABLED = false;
static final boolean CLIENT_DEBUG_ENABLED = false;
WebsocketServer ws;
Paddle paddleLeft;
Paddle paddleRight;
ArrayList<Ball> pongBalls;

String jsonClientMsg;
boolean ballAdded = false;
int ballDiameter = 50;
int paddleLength = 100;
int scoreLeft = 0;
int scoreRight = 0;
int updateFreqMs = 20;
int now;

void setup(){
  size(800, 800);
  
  pongBalls = new ArrayList<Ball>();
  paddleLeft = new Paddle(paddleLength, Paddle.PADDLE_LEFT, #FFFF00);
  paddleRight = new Paddle(paddleLength, Paddle.PADDLE_RIGHT, null);
  ws = new WebsocketServer(this, 8443, "");
  now = millis();
}

void draw(){
  background(0);

  /*
   * Send message to client/player
   */
  if(millis() > now + updateFreqMs) {
    jsonClientMsg = generateJsonGameInfo();
    if( SERVER_DEBUG_ENABLED ){ println("Server Sending\n" + jsonClientMsg); }
    ws.sendMessage(jsonClientMsg);
    now = millis();
  }
  
  if( keyPressed ){
    if( key == 's' && !ballAdded ){
      ballAdded = true;
      pongBalls.add( new Ball(ballDiameter, 3) );
      
      for( Ball b : pongBalls ){
        b.startBall();
      }
    }
  }
  
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

  /*
   * No need to update the other paddles, their info comes directly from
   * the client messages
   */
  paddleLeft.update();
  for( Ball ball : pongBalls ){
    ball.update();
    
    if( ball.x < width / 2 ){
      ball.isCollision(paddleLeft);
    } else {
      ball.isCollision(paddleRight);
    }
    
    ball.draw();
  } //<>//

  paddleLeft.draw();
  paddleRight.draw();
  drawScore();
}

void keyReleased(){
 ballAdded = false;
 paddleLeft.paddleDirection = ""; 
 paddleRight.paddleDirection = ""; 
}

String generateJsonGameInfo(){
    JSONObject obj = paddleLeft.toJsonObj(null);
    JSONArray arrObj = new JSONArray();
    
    for( int i = 0; i < pongBalls.size(); i++ ){
      JSONObject ballObj = pongBalls.get(i).toJsonObj(null); //<>//
      arrObj.setJSONObject(i, ballObj);
    }
    
    obj.setJSONArray("pongBalls", arrObj);    
    obj.setInt("scoreLeft", scoreLeft);
    obj.setInt("scoreRight", scoreRight);
    
    return obj.toString();
}

void drawScore(){
  textSize(16);
  fill(paddleLeft.paddleColor);
  text("Score: " + scoreLeft, 50, 50);
  fill(paddleRight.paddleColor);
  text("Score: " + scoreRight, width - 100 - 50, 50);
}

/*
 * Called when getting a message from the client/player
 */
void webSocketServerEvent(String gameInfoJsonString){
  if( CLIENT_DEBUG_ENABLED ){ println("message from client:\n" + gameInfoJsonString); }
  paddleRight.parseJsonString(gameInfoJsonString);
}
