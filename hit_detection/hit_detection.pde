ArrayList<Laser> lasers = new ArrayList<Laser>();
ArrayList<Dot> dots = new ArrayList<Dot>();
final int LASERSIZE = 5;
final int DOTSIZE = 20;
final int SPEED = 1;
final int FREQUENCY = 1;
final int LASER_COLOR_R = 255;
final int LASER_COLOR_G = 255;
final int LASER_COLOR_B = 255;
boolean gameOver = false;
int score = 0;
int highscore = 0;
int gameOverTimer = 0;
void setup(){
  size(500, 500);
  cursor(CROSS);
}

void draw(){
  background(0);
  if(!gameOver){
    if(random(0, 60) >= 60 - FREQUENCY){
      dots.add(new Dot());
    }
    int len = lasers.size();
    for(int i = 0; i < len; i++){
      lasers.get(i).display();
      int len2 = dots.size();
      if(len2 > 0){
        for(int j = len2 - 1; j >= 0; j--){
          float dotX = dots.get(j).x;
          float dotY = dots.get(j).y;
          if(lasers.get(i).hitDot(dotX, dotY)){
            dots.remove(dots.get(j));
            score++;
          }
        }
      }
    }
    int len2 = dots.size();
    for(int i = 0; i < len2; i++){
      dots.get(i).display();
      dots.get(i).update();
    }
    for(int i = len - 1; i >= 0; i--){
      lasers.get(i).update();
    }
    displayScore();
    displayTurret();
  }
  else{
    gameOverTimer++;
    dots.clear();
    lasers.clear();
    if(score > highscore){
      highscore = score;
    }
    fill(255);
    stroke(255);
    textSize(50);
    text("Score: " + score, 130, 200);
    text("Highscore: " + highscore, 80, 300);
  }
}

void mousePressed(){
  if(!gameOver){
    lasers.add(new Laser(mouseX, mouseY));
  }
  else if(gameOverTimer > 60){
    score = 0;
    gameOverTimer = 0;
    gameOver = false;
  }
}

void displayScore(){
  fill(255);
  stroke(255);
  textSize(30);
  text(score, 10, 30);
}

void displayTurret(){
  noStroke();
  fill(0);
  ellipse(width/2, height, 50, 50);
  fill(200);
  rect(width/2 - 15, height - 10, 30, 10);
  stroke(200);
  strokeWeight(7);
  float magnitude = sqrt(sq(mouseX - width/2) + sq(mouseY - height));
  float xComponent = (mouseX - width/2) / magnitude * 25;
  float yComponent = (mouseY - height) / magnitude * 25;
  line(width/2, height, width/2 + xComponent, height + yComponent);
}

class Laser{
  float time;
  float slope;
  float lineEnd;
  Laser(float x, float y){
    this.time = 30;
    this.slope = (y - height) / (x - width/2);
    this.lineEnd = -height / slope + width/2;
  }
  
  void update(){
    if(time <= 0){
      lasers.remove(this);
    }
    else{
      time--;
    }
  }
  
  void display(){
    int r = int(time / 30 * LASER_COLOR_R);
    int g = int(time / 30 * LASER_COLOR_G);
    int b = int(time / 30 * LASER_COLOR_B);
    stroke(r, g, b);
    strokeWeight(LASERSIZE);
    line(width/2, height, lineEnd, 0);
  }
  
  boolean hitDot(float pointX, float pointY){
    float equationX = (-width/2*slope + height - (pointX/slope) - pointY) / -(1/slope + slope);
    float equationY = slope * (equationX - width/2) + height;
    return abs(dist(equationX, equationY, pointX, pointY)) < (DOTSIZE + LASERSIZE) / 2;
  }
}

class Dot{
  float x;
  float y;
  float speed;
  Dot(){
    this.x = random(50, width - 50);
    this.y = 0;
    int difficulty = score;
    if(difficulty > 100){
      difficulty = 100;
    }
    this.speed = (0.5 + random(1, 2) * difficulty / 50) * SPEED;
  }
  
  void update(){
    y += speed;
    if(y > height){
      gameOver = true;
    }
  }
  
  void display(){
    fill(255);
    noStroke();
    ellipse(x, y, DOTSIZE, DOTSIZE);
  }
}
