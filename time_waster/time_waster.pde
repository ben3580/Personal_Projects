PImage bigimg1;
PImage bigimg2;
PImage bigimg3;
ArrayList<Coin> coins = new ArrayList<Coin>();
float playerX = 250;
float playerY = 250;
int score = 0;
boolean auto = false;
Coin temp;
boolean tempPickedUp = false;
boolean tempChosen = false;
void setup() {
  rectMode(CENTER);
  imageMode(CENTER);
  size(500, 500);
  PImage img1;
  PImage img2;
  PImage img3;
  img1 = loadImage("1.png");
  img2 = loadImage("2.png");
  img3 = loadImage("3.png");
  bigimg1 = scaleImage(img1, 2);
  bigimg2 = scaleImage(img2, 2);
  bigimg3 = scaleImage(img3, 2);
  
}

void draw() {  
  background(255);
  if(random(0, 60) > 58){
    coins.add(new Coin((int)random(50, 450), (int)random(100, 450)));
  }
  for(int i = coins.size()-1; i >= 0; i--){
    Coin c = coins.get(i);
    c.display();
    c.update();
    if(c.isNear((int)playerX, (int)playerY)){
      c.pickUp();
    }
  }
  if(!auto){
  float dx = mouseX - playerX;
  playerX += dx * 0.05;
  float dy = mouseY - playerY;
  playerY += dy * 0.05;
  }
  else if(auto && coins.size() > 0){
    if(!tempChosen){
      temp = coins.get((int)random(0, coins.size()-1));
      tempChosen = true;
    }
    float magnitude = sqrt(sq(temp.x - playerX) + sq(temp.y - playerY));
    float xComponent = (temp.x - playerX) / magnitude * 2;
    float yComponent = (temp.y - playerY) / magnitude * 2;
    playerX += xComponent;
    playerY += yComponent;
    if(temp.isNear((int)playerX, (int)playerY)){
      tempChosen = false;
    }
  }
  fill(0);
  rect(playerX, playerY, 30, 30);
  rect(250, 30, 500, 60);
  fill(255);
  image(bigimg1, 30, 35);
  textSize(40);
  text(score, 70, 50);
}

void mousePressed(){
  if(auto){
    auto = false;
  }
  else{
    auto = true;
  }
}

PImage scaleImage(PImage source, int factor){
  int lenW = source.width;
  int lenH = source.height;
  int[][] locations = new int[(int)sq(factor)][2];
  int loc;
  float r, g, b, a;
  PImage destination = createImage(lenW * factor, lenH * factor, ARGB);
  source.loadPixels();
  destination.loadPixels();
  for (int x = 0; x < lenW; x++) {
    for (int y = 0; y < lenH; y++ ) {
      loc = x + y*source.width;
      r = red(source.pixels[loc]);
      g = green(source.pixels[loc]);
      b = blue(source.pixels[loc]);
      a = alpha(source.pixels[loc]);
      if(a > 0) a = 255;
      for(int i = 0; i < factor; i++){
        for(int j = 0; j < factor; j++){
          int num = i*factor+j;
          locations[num][0] = x * factor + i;
          locations[num][1] = y * factor + j;
        }
      }
      for(int i = 0; i < locations.length; i++){
        loc = locations[i][0] + locations[i][1]*destination.width;
        destination.pixels[loc] = color(r, g, b, a);
      }
    }
  }
  destination.updatePixels();
  return destination;
}

class Coin{
  int x;
  int y;
  int timer;
  boolean pickedUp;
  Coin(int x, int y){
    this.x = x;
    this.y = y;
    timer = 0;
    pickedUp = false;
  }
  
  void display(){
    if(!pickedUp){
      if(timer < 15){
        image(bigimg1, x, y);
      }
      else if(timer < 30){
        image(bigimg2, x, y);
      }
      else if(timer < 45){
        image(bigimg3, x, y);
      }
      else{
        image(bigimg2, x, y);
      }
    }
    else{
      tint(255, 255-timer*8);
      if(timer % 8 < 2){
        image(bigimg1, x, y);
      }
      else if(timer % 8 < 4){
        image(bigimg2, x, y);
      }
      else if(timer % 8 < 6){
        image(bigimg3, x, y);
      }
      else{
        image(bigimg2, x, y);
      }
      noTint();
    }
  }
  
  void update(){
    if(!pickedUp){
      if(timer == 60){
        timer = 0;
      }
    }
    else{
      if(timer == 30){
        coins.remove(this);
      }
      y += (timer - 20) / 5;
    }
    timer++;
  }
  
  void pickUp(){
    if(!pickedUp){
      pickedUp = true;
      timer = 0;
      score++;
    }
  }
  
  boolean isNear(int x, int y){
    return dist(this.x, this.y, x, y) < 40;
  }
}
