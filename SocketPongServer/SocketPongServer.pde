import websockets.*;

static final boolean DEBUG_ENABLED = false;
WebsocketServer ws;
Ball ball;
Paddle paddleLeft;
Paddle paddleRight;

String jsonClientMsg;
int ballDiameter = 50;
int paddleLength = 100;
int updateFreqMs = 20;
int now;

void setup(){
  size(800, 800);
  
  ball = new Ball(ballDiameter, 3);
  paddleLeft = new Paddle(paddleLength, Paddle.PADDLE_LEFT, #FFFF00);
  paddleRight = new Paddle(paddleLength, Paddle.PADDLE_RIGHT, null);
  //ws = new WebsocketServer(this, 8000, "/unnamed");
  ws = new WebsocketServer(this, 8000, "");
  now = millis();
}

void draw(){
  background(0);

  /*
   * Send message to client/player
   */
  if(millis() > now + updateFreqMs) {
    jsonClientMsg = paddleLeft.toJsonObj( ball.toJsonObj(null) ).toString();
    if( DEBUG_ENABLED ){
      println("Server Sending\n" + jsonClientMsg);
    }
    ws.sendMessage(jsonClientMsg);
    now = millis();
  }
  
  if( keyPressed ){
    if( key == 's' ){
      ball.startBall();
    }
  }

  /*
   * No need to update the other paddles, their info comes directly from
   * the client messages
   */
  ball.update();
  paddleLeft.update();
  
  if( ball.x < width / 2 ){
    ball.isCollision(paddleLeft);
  } else {
    ball.isCollision(paddleRight); //<>//
  }

  ball.draw();
  paddleLeft.draw();
  paddleRight.draw();
}

/*
 * Called when getting a message from the client/player
 */
void webSocketServerEvent(String gameInfoJsonString){
  if( DEBUG_ENABLED ){
    println("message from client:\n" + gameInfoJsonString);
  }
  paddleRight.parseJsonString(gameInfoJsonString);
}
