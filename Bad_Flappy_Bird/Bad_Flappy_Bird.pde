float ypos;
float yposDisplay;
float yvel;
float yacc;
float rect1x = 700;
float rect1y;
float rect2x = 700;
float rect2y;
boolean fly = false;
boolean rect1OnScreen = false;
boolean rect2OnScreen = false;
float timer = 0;
float sinTimer = 0;
float flapTimer = 0;
boolean start = true;
boolean gameOver = false;
int score;
int highScore;
boolean passPipe = false;
float cloudx = 750;
float cloudy;
float groundx = 40;
boolean displayBird = true;

void setup(){
  size(600, 800);
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  rect1y = random(300, 500);
  rect2y = random(300, 500);
}
void draw(){
  background(#00C5FF);
  if(cloudx >= 750){
    cloudy = random(60, 200);
  }
  cloudx -= 1;
  if(cloudx <= -150){
    cloudx = 750;
  }
  drawCloud(cloudx, cloudy);
  strokeWeight(2);
  stroke(0);
  fill(#11D600);
  rect(rect1x, rect1y - 440, 100, 700);
  rect(rect1x, rect1y + 440, 100, 700);
  rect(rect2x, rect2y - 440, 100, 700);
  rect(rect2x, rect2y + 440, 100, 700);
  strokeWeight(2);
  stroke(0);
  fill(#F7E187);
  rect(300, 750, 604, 104);
  strokeWeight(0);
  fill(0, 230, 0);
  rect(300, 710, 600, 19);
  if(gameOver == false){
    groundx -= 4;
  }
  if(groundx == 0){
    groundx = 40;
  }
  fill(#6EBF6A);
  rect(groundx, 710, 20, 19);
  rect(groundx + 40, 710, 20, 19);
  rect(groundx + 80, 710, 20, 19);
  rect(groundx + 120, 710, 20, 19);
  rect(groundx + 160, 710, 20, 19);
  rect(groundx + 200, 710, 20, 19);
  rect(groundx + 240, 710, 20, 19);
  rect(groundx + 280, 710, 20, 19);
  rect(groundx + 320, 710, 20, 19);
  rect(groundx + 360, 710, 20, 19);
  rect(groundx + 400, 710, 20, 19);
  rect(groundx + 440, 710, 20, 19);
  rect(groundx + 480, 710, 20, 19);
  rect(groundx + 520, 710, 20, 19);
  rect(groundx + 560, 710, 20, 19);
  if(gameOver == false){
    yposDisplay = ypos;
  }
  if(displayBird == false){
    strokeWeight(35);
    stroke(0);
    point(200, yposDisplay);
  }else{
    strokeWeight(2);
    stroke(0);
    fill(#F0C800);
    ellipse(200, yposDisplay, 50, 35);
    fill(255);
    ellipse(215, yposDisplay - 5, 20, 20);
    strokeWeight(7);
    point(217, yposDisplay - 5);
    strokeWeight(2);
    fill(#E85A2A);
    ellipse(220, yposDisplay + 10, 25, 15);
    line(207, yposDisplay + 10, 232, yposDisplay + 10);
    fill(#F5E9AF);
    if(gameOver == false){
      flapTimer ++;
    }
    if(flapTimer <= 14){
      ellipse(182, yposDisplay - 7, 20, 20);
    }else if(flapTimer >= 15 && flapTimer <= 29){
      ellipse(182, yposDisplay - 2, 20, 10);
    }else if(flapTimer >= 30 && flapTimer <= 44){
      ellipse(182, yposDisplay + 3, 20, 20);
    }
    if(flapTimer == 45){
      flapTimer = 0;
    }
    
  }
  if(start == true){
    textSize(50);
    fill(0);
    text("Bad Flappy Bird", 300, 200);
    textSize(20);
    text("Click anywhere to play", 300, 500);
    sinTimer += 1;
    ypos = 400 + 30 * sin(sinTimer/30);
    strokeWeight(2);
    stroke(0);
    fill(255);
    rect(525, 750, 150, 100);
    textSize(18);
    fill(0);
    if(displayBird == true){
    text("Get this ugly", 525, 730);
    text("bird outta here", 525, 760);
    }else{
      text("I want the", 525, 730);
      text("bird back", 525, 760);
    }
    if(mouseX >= 450 && mouseY >= 700){
      if(mousePressed){
        if(displayBird == true){
          displayBird = false;
        }
        else{
          displayBird = true;
        }
        delay(200);
      }
    }
  }
  if(start == false && gameOver == false){
    yacc = 0.8;
  if(rect1OnScreen == false){
    rect1x = 700;
    rect1y = random(200, 600);
    rect1OnScreen = true;
  }else if(rect1OnScreen == true){
    rect1x -= 4;
  }
  if(rect1x <= - 50){
    rect1OnScreen = false;
  }
  
  timer++;
  if(timer >= 95){
    if(rect2OnScreen == false){
      rect2x = 700;
      rect2y = random(200, 600);
      rect2OnScreen = true;
    }else if(rect2OnScreen == true){
      rect2x -= 4;
    }
    if(rect2x <= - 50){
      rect2OnScreen = false;
    }
  }
  if(fly == true){
    yvel = -14;
    fly = false;
  }
  yvel = constrain(yvel, -15, 15);
  ypos = constrain(ypos, -100, 675);
  yvel += yacc;
  ypos += yvel;
  if(200 == rect1x + 60 || 200 == rect2x + 60){
    score ++;
  }
  if(ypos >= rect1y + 75 || ypos <= rect1y - 75){
    if(200 >= rect1x - 60 && 200 <= rect1x + 60){
      gameOver = true;
      timer = 0;
      ypos = rect1y;
    }
  }
  if(ypos >= rect2y + 75 || ypos <= rect2y - 75){
    if(200 >= rect2x - 60 && 200 <= rect2x + 60){
      gameOver = true;
      timer = 0;
      ypos = rect1y;
    }
  }
  if(ypos >= 690){
    gameOver = true;
    timer = 0;
    ypos = rect1y;
  }
  fill(0);
  textSize(50);
  text(score, 300, 150);
  if(score >= highScore){
    highScore = score;
  }
  }

  if(gameOver == true){
    yposDisplay += 15;
    yposDisplay = constrain(yposDisplay, -100, 690);
    timer ++;
    strokeWeight(0);
    fill(timer * 20);
    if(timer <= 10){
      rect(300, 25, 600, 50);
      rect(300, 775, 600, 50);
      rect(25, 400, 50, 800);
      rect(575, 400, 50, 800);
    }
   
    if(timer >= 60){
      strokeWeight(5);
      stroke(255);
      fill(0);
      rect(300, 325, 400, 550);
      textSize(50);
      fill(255);
      text("Game Over", 300, 100);
      textSize(35);
      text("Score", 300, 200);
      text("High Score", 300, 325);
      textSize(50);
      text(score, 300, 250);
      text(highScore, 300, 375);
      textSize(20);
      text("Click anywhere to play again", 300, 550);
      if(highScore < 10){
        strokeWeight(3);
        stroke(50);
        fill(0);
        quad(130, 440, 150, 440, 180, 490, 160, 490);
        quad(200, 440, 220, 440, 190, 490, 170, 490);
        strokeWeight(5);
        ellipse(175, 500, 50, 50);
      }else{
        strokeWeight(3);
        stroke(255);
        fill(240, 0, 0);
        quad(130, 440, 150, 440, 180, 490, 160, 490);
        quad(200, 440, 220, 440, 190, 490, 170, 490);
        strokeWeight(5);
        fill(#9B7C00);
        ellipse(175, 500, 50, 50);
      }
      if(highScore < 25){
        strokeWeight(3);
        stroke(50);
        fill(0);
        quad(255, 440, 275, 440, 305, 490, 285, 490);
        quad(325, 440, 345, 440, 315, 490, 295, 490);
        strokeWeight(5);
        ellipse(300, 500, 50, 50);
      }else{
        strokeWeight(3);
        stroke(255);
        fill(240, 0, 0);
        quad(255, 440, 275, 440, 305, 490, 285, 490);
        quad(325, 440, 345, 440, 315, 490, 295, 490);
        strokeWeight(5);
        fill(#EAEAEA);
        ellipse(300, 500, 50, 50);
      }
      if(highScore < 50){
        strokeWeight(3);
        stroke(50);
        fill(0);
        quad(380, 440, 400, 440, 430, 490, 410, 490);
        quad(450, 440, 470, 440, 440, 490, 420, 490);
        strokeWeight(5);
        ellipse(425, 500, 50, 50);
      }else{
        strokeWeight(3);
        stroke(255);
        fill(240, 0, 0);
        quad(380, 440, 400, 440, 430, 490, 410, 490);
        quad(450, 440, 470, 440, 440, 490, 420, 490);
        strokeWeight(5);
        fill(#EDCE32);
        ellipse(425, 500, 50, 50);
      }
      if(mousePressed){
        start = true;
        gameOver = false;
        timer = 0;
        score = 0;
        sinTimer = 0;
        rect1x = 700;
        rect2x = 700;
        rect1OnScreen = false;
        rect2OnScreen = false;
      }
    }
  }
}
void mousePressed(){
  fly = true;
  if(mouseX <= 450 || mouseY <= 700){
    if(start == true){
      start = false;
    }
  }
}
void drawCloud(float x, float y){
  noStroke();
  fill(255);
  ellipse(x, y, 100, 100);
  ellipse(x - 50, y - 10, 80, 80);
  ellipse(x + 30, y, 70, 70);
}
