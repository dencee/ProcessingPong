import websockets.*;

static final boolean DEBUG_ENABLED = false;
WebsocketClient wsc;
Ball ball;
Paddle paddleLeft;
Paddle paddleRight;

String jsonClientMsg;
int ballDiameter = 50;
int paddleLength = 100;
int updateFreqMs = 20;
int now;

void setup() {
  size(800, 800);
  
  ball = new Ball(ballDiameter, 3);
  paddleLeft = new Paddle(paddleLength, Paddle.PADDLE_LEFT, null);
  paddleRight = new Paddle(paddleLength, Paddle.PADDLE_RIGHT, #0000FF);
  //wsc= new WebsocketClient(this, "ws://localhost:8000/unnamed");
  wsc= new WebsocketClient(this,  "ws://76.167.223.125:8000");
  now = millis();
}

void draw() {
  background(0);

  // Send message to server/host
  if(millis() > now + updateFreqMs) {
    jsonClientMsg = paddleRight.toJsonObj(null).toString();
    if( DEBUG_ENABLED ){
      println("Client Sending\n" + jsonClientMsg);
    }
    wsc.sendMessage(jsonClientMsg);
    now = millis();
  }
  
  ball.update();
  paddleRight.update();
  
  ball.isCollision(paddleLeft);
  ball.isCollision(paddleRight);

  ball.draw();
  paddleLeft.draw();
  paddleRight.draw();
}

// Called when getting a message from the server/host
void webSocketEvent(String gameInfoJsonString){
  if( DEBUG_ENABLED ){
    println("message from server:\n" + gameInfoJsonString);
  }
  ball.parseJsonString(gameInfoJsonString);
  paddleLeft.parseJsonString(gameInfoJsonString);
}
