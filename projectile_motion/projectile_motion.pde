float xpos = 25;
float ypos = 395;
float xvel = 0;
float yvel = 0;
float xacc = 0;
float yacc = 0;
float power = 0;
float xComponent = 0;
float yComponent = 0;
float shotMagnitude = 0;
boolean shot = false;
boolean inMotion = false;
boolean targetHit = false;
boolean buildingPower = false;
float targetX = random(300, 800);
float targetY = random(100, 300);
int targetTransparency = 0;
int Y_AXIS = 1;
int X_AXIS = 2;
color c1, c2;
void setup(){
  size(1000,500);
  c1 = color(0);
  c2 = color(200);
  rectMode(CORNERS);
}
void draw(){
  background(200);
  xpos = constrain(xpos, 25, 1000);
  ypos = constrain(ypos, -200, 395);
  strokeWeight(1);
  setGradient(0, 400, 1000, 100, c1, c2, Y_AXIS);
  noFill();
  stroke(0);
  rect(50, 50, 70, 150);
  fill(0);
  strokeWeight(0);
  rect(50, -(power * 4) + 150, 70, 150);
  fill(0);
  textSize(20);
  text("Power", 30, 170);
  shotMagnitude = sqrt(sq(mouseX - xpos) + sq(mouseY - ypos));
  xComponent = (mouseX - xpos) / shotMagnitude;
  yComponent = (mouseY - ypos) / shotMagnitude;
  strokeWeight(5);
  point(25 + (xComponent * 1 * power), 395 + (yComponent * 1 * power));
  point(25 + (xComponent * 2 * power), 395 + (yComponent * 2 * power));
  point(25 + (xComponent * 3 * power), 395 + (yComponent * 3 * power));
  point(25 + (xComponent * 4 * power), 395 + (yComponent * 4 * power));
  point(25 + (xComponent * 5 * power), 395 + (yComponent * 5 * power));
  if(inMotion == true){
    if(targetX >= xpos-25 && targetX <= xpos+25 && targetY >= ypos-25 && targetY <= ypos+25){
      targetHit = true;
    }
  }
  if(targetHit == true){
    targetTransparency += 5;
    if(targetTransparency >= 200){
      targetTransparency = 0;
      targetX = random(300, 800);
      targetY = random(100, 300);
      targetHit = false;
    }
  }
  strokeWeight(0);
  fill(255, targetTransparency, targetTransparency);
  ellipse(targetX, targetY, 50, 50);
  fill(255);
  ellipse(targetX, targetY, 40, 40);
  fill(255, targetTransparency, targetTransparency);
  ellipse(targetX, targetY, 30, 30);
  fill(255);
  ellipse(targetX, targetY, 20, 20);
  fill(255, targetTransparency, targetTransparency);
  ellipse(targetX, targetY, 10, 10);
  xvel += xacc;
  yvel += yacc;
  xpos += xvel;
  ypos += yvel;
  strokeWeight(10);
  stroke(0);
  point(xpos, ypos);
  if(buildingPower == true){
    power += 0.5;
    power = constrain(power, 0, 25);
  }
  if(shot == true && xpos <= 1000 && ypos <= 400){
    xvel = xComponent * power;
    yvel = yComponent * power;
    yacc = 0.2;
    xacc = -0.005 * xvel;
    xacc = constrain(xacc, 0, xvel);
    buildingPower = false;
    power = 0;
    shot = false;
  }
  if(xpos >= 1000 || ypos >= 396){
    xpos = 25;
    ypos = 395;
    xvel = 0;
    yvel = 0;
    yacc = 0;
    xacc = 0;
    inMotion = false;
  }
}
void mousePressed(){
  buildingPower = true;
}
void mouseReleased(){
  if(xpos == 25 && ypos == 395){
  shot = true;
  inMotion = true;
  }
}
void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {

  noFill();

  if (axis == Y_AXIS) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  }  
  else if (axis == X_AXIS) {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
}
