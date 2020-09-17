import java.util.Calendar;
PGraphics pg;
PGraphics finalImage;

int PIXELSIZE = 50;
int PIXELSX = 10;
int PIXELSY = 10;
final int SIZEX = PIXELSIZE * PIXELSX;
final int SIZEY = PIXELSIZE * PIXELSY;

final int GRIDBUTTONX1 = SIZEX + 10;
final int GRIDBUTTONY1 = 10;
final int GRIDBUTTONX2 = SIZEX + 90;
final int GRIDBUTTONY2 = 90;
final int SLIDERX1 = 100;
final int SLIDERX2 = 355;
final int SLIDER1Y = SIZEY + 20;
final int SLIDER2Y = SIZEY + 50;
final int SLIDER3Y = SIZEY + 80;
final int FILLBUTTONX1 = SIZEX + 10;
final int FILLBUTTONY1 = 110;
final int FILLBUTTONX2 = SIZEX + 90;
final int FILLBUTTONY2 = 190;
final int SAVEBUTTONX1 = SIZEX + 10;
final int SAVEBUTTONY1 = 210;
final int SAVEBUTTONX2 = SIZEX + 90;
final int SAVEBUTTONY2 = 290;
final int TRANSPARENCYBUTTONX1 = 420;
final int TRANSPARENCYBUTTONY1 = SIZEY + 20;
final int TRANSPARENCYBUTTONX2 = 550;
final int TRANSPARENCYBUTTONY2 = SIZEY + 80;

FillMode f = new FillMode();
int[][][] pixelArray = new int[PIXELSX][PIXELSY][3];
ArrayList<int[][][]> goBack = new ArrayList<int[][][]>();
boolean grid = true;
int brushR = 0;
int brushG = 0;
int brushB = 0;
int draggable = 0;
boolean rUnlocked = false;
boolean gUnlocked = false;
boolean bUnlocked = false;
boolean transparency = false;
boolean fill = false;
boolean saved = false;
int saveTimer = 0;
PImage temp;
int goBackIndex = 0;
boolean goingBack = false;
boolean showInfo = false;
void settings(){
  size(SIZEX+100, SIZEY+100);
}

void setup(){
  pg = createGraphics(SIZEX, SIZEY);
  finalImage = createGraphics(PIXELSX, PIXELSY);
  for(int i = 0; i < PIXELSX; i++){
    for(int j = 0; j < PIXELSY; j++){
      for(int k = 0; k < 3; k++){
        pixelArray[i][j][k] = 255;
      }
    }
  }
  int[][][] arr = new int[PIXELSX][PIXELSY][3];
  for(int i = 0; i < PIXELSX; i++){
    for(int j = 0; j < PIXELSY; j++){
      for(int k = 0; k < 3; k++){
        arr[i][j][k] = pixelArray[i][j][k];
      }
    }
  }
  goBack.add(arr);
}

void draw(){
  if(mousePressed){
    if(mouseX >= 0 && mouseX < width - 100 && mouseY >= 0 && mouseY < height-100 && !rUnlocked && !gUnlocked && !bUnlocked){
      int x = mouseX / PIXELSIZE;
      int y = mouseY / PIXELSIZE;
      if(fill){
        f.setColor(pixelArray[x][y][0], pixelArray[x][y][1], pixelArray[x][y][2]);
        ArrayList<int[]> needToFill = f.fillColor(x, y);
        for(int i = 0; i < needToFill.size(); i++){
          int tempx = needToFill.get(i)[0];
          int tempy = needToFill.get(i)[1];
          if(transparency){
            pixelArray[tempx][tempy][0] = -1;
            pixelArray[tempx][tempy][1] = -1;
            pixelArray[tempx][tempy][2] = -1;
          }
          else{
            pixelArray[tempx][tempy][0] = brushR;
            pixelArray[tempx][tempy][1] = brushG;
            pixelArray[tempx][tempy][2] = brushB;
          }
        }
        f.clearInfo();
      }
      else if(transparency){
        pixelArray[x][y][0] = -1;
        pixelArray[x][y][1] = -1;
        pixelArray[x][y][2] = -1;
      }
      else{
        pixelArray[x][y][0] = brushR;
        pixelArray[x][y][1] = brushG;
        pixelArray[x][y][2] = brushB;
      }
    }
    if(rUnlocked){
      brushR = mouseX - SLIDERX1;
      brushR = constrain(brushR, 0, 255);
    }
    else if(gUnlocked){
      brushG = mouseX - SLIDERX1;
      brushG = constrain(brushG, 0, 255);
    }
    else if(bUnlocked){
      brushB = mouseX - SLIDERX1;
      brushB = constrain(brushB, 0, 255);
    }
  }
  pg.beginDraw();
  pg.background(255, 0);
  for(int i = 0; i < PIXELSX; i++){
    for(int j = 0; j < PIXELSY; j++){
      if(pixelArray[i][j][0] == -1){
        pg.noStroke();
        pg.fill(200);
        pg.rect(i*PIXELSIZE, j*PIXELSIZE, PIXELSIZE/2, PIXELSIZE/2);
        pg.rect(i*PIXELSIZE + PIXELSIZE/2, j*PIXELSIZE + PIXELSIZE/2, PIXELSIZE/2, PIXELSIZE/2);
        pg.fill(255);
        pg.rect(i*PIXELSIZE + PIXELSIZE/2, j*PIXELSIZE, PIXELSIZE/2, PIXELSIZE/2);
        pg.rect(i*PIXELSIZE, j*PIXELSIZE + PIXELSIZE/2, PIXELSIZE/2, PIXELSIZE/2);
        pg.noFill();
      }
      else{
        pg.fill(pixelArray[i][j][0], pixelArray[i][j][1], pixelArray[i][j][2]);
      }
      if(grid){
        pg.strokeWeight(1);
        pg.stroke(0);
      }
      else{
        pg.noStroke();
      }
      pg.rect(i*PIXELSIZE, j*PIXELSIZE, PIXELSIZE, PIXELSIZE);
    }
  }
  if(showInfo && mouseX >= 0 && mouseX < width - 100 && mouseY >= 0 && mouseY < height-100 && !rUnlocked && !gUnlocked && !bUnlocked){
      int x = mouseX / PIXELSIZE;
      int y = mouseY / PIXELSIZE;
      pg.fill(0);
      pg.textSize(15);
      pg.text("("+pixelArray[x][y][0]+",", mouseX + 10, mouseY);
      pg.text(pixelArray[x][y][1]+",", mouseX + 50, mouseY);
      pg.text(pixelArray[x][y][2]+")", mouseX + 85, mouseY);
    }
  pg.endDraw();
  
  image(pg, 0, 0);
  rectMode(CORNERS);
  noStroke();
  fill(230);
  rect(0, SIZEY, SIZEX + 100, SIZEY + 100);
  rect(SIZEX, 0, SIZEX + 100, SIZEY + 100);
  drawGridButton();
  draggable = drawRGBSliders();
  drawSaveButton();
  drawTransparencyButton();
  drawFillButton();
}

void mousePressed(){
  if(goingBack){
    goingBack = false;
    int[][][] arr = new int[PIXELSX][PIXELSY][3];
    for(int i = 0; i < PIXELSX; i++){
      for(int j = 0; j < PIXELSY; j++){
        for(int k = 0; k < 3; k++){
          arr[i][j][k] = pixelArray[i][j][k];
        }
      }
    }
    goBack.add(arr);
  }
  if(overButton(GRIDBUTTONX1, GRIDBUTTONY1, GRIDBUTTONX2, GRIDBUTTONY2)){
    if(grid){
      grid = false;
    }
    else{
      grid = true;
    }
  }
  else if(overButton(TRANSPARENCYBUTTONX1, TRANSPARENCYBUTTONY1, TRANSPARENCYBUTTONX2, TRANSPARENCYBUTTONY2)){
    if(transparency){
      transparency = false;
    }
    else{
      transparency = true;
    }
  }
  else if(overButton(SAVEBUTTONX1, SAVEBUTTONY1, SAVEBUTTONX2, SAVEBUTTONY2) && !saved){
    minimize();
    saved = true;
  }
  else if(overButton(FILLBUTTONX1, FILLBUTTONY1, FILLBUTTONX2, FILLBUTTONY2)){
    if(fill){
      fill = false;
    }
    else{
      fill = true;
    }
  }
  else if(draggable == 1){
    rUnlocked = true;
  }
  else if(draggable == 2){
    gUnlocked = true;
  }
  else if(draggable == 3){
    bUnlocked = true;
  }
}

void mouseReleased(){
  rUnlocked = false;
  gUnlocked = false;
  bUnlocked = false;
  int[][][] arr = new int[PIXELSX][PIXELSY][3];
  for(int i = 0; i < PIXELSX; i++){
    for(int j = 0; j < PIXELSY; j++){
      for(int k = 0; k < 3; k++){
        arr[i][j][k] = pixelArray[i][j][k];
      }
    }
  }
  if(goBack.size() == 1){
    goBack.add(arr);
  }
  else{
    boolean flag = false;
    for(int i = 0; i < PIXELSX; i++){
      for(int j = 0; j < PIXELSY; j++){
        for(int k = 0; k < 3; k++){
          if(pixelArray[i][j][k] != goBack.get(goBack.size()-1)[i][j][k]){
            flag = true;
          }
        }
      }
    }
    if(flag){
      goBack.add(arr);
    }
    if(goBack.size() > 50){
      goBack.remove(0);
    }
  }
  goBackIndex = 0;
}

void keyPressed(){
  if(key == 'z' && goBack.size() > 0 && goBackIndex < goBack.size()-1){
    goingBack = true;
    goBackIndex++;
    for(int i = 0; i < PIXELSX; i++){
      for(int j = 0; j < PIXELSY; j++){
        for(int k = 0; k < 3; k++){
          pixelArray[i][j][k] = goBack.get(goBack.size()-goBackIndex-1)[i][j][k];
        }
      }
    }
  }
  if(key == 'y' && goBackIndex > 0){
    goBackIndex--;
    for(int i = 0; i < PIXELSX; i++){
      for(int j = 0; j < PIXELSY; j++){
        for(int k = 0; k < 3; k++){
          pixelArray[i][j][k] = goBack.get(goBack.size()-goBackIndex-1)[i][j][k];
        }
      }
    }
  }
  if(key == 'a'){
    if(showInfo){
      showInfo = false;
    }
    else{
      showInfo = true;
    }
  }
}
void drawGridButton(){
  rectMode(CORNERS);
  fill(255);
  strokeWeight(2);
  stroke(0);
  rect(GRIDBUTTONX1, GRIDBUTTONY1, GRIDBUTTONX2, GRIDBUTTONY2);
  fill(0);
  textSize(20);
  text("Grid:", GRIDBUTTONX1 + 20, GRIDBUTTONY1 + 20);
  textSize(30);
  if(grid){
    text("ON", GRIDBUTTONX1 + 15, GRIDBUTTONY1 + 60);
  }
  else{
    text("OFF", GRIDBUTTONX1 + 15, GRIDBUTTONY1 + 60);
  }
}

int drawRGBSliders(){
  if(transparency){
    noStroke();
    fill(200);
    rect(SLIDERX1 - 70, SLIDER1Y + 10, SLIDERX1 - 50, SLIDER2Y);
    rect(SLIDERX1 - 50, SLIDER2Y, SLIDERX1 - 30, SLIDER3Y - 10);
    noFill();
  }
  else{
    fill(brushR, brushG, brushB);
  }
  strokeWeight(2);
  stroke(0);
  rect(SLIDERX1 - 70, SLIDER1Y + 10, SLIDERX1 - 30, SLIDER3Y - 10);
  strokeWeight(3);
  line(SLIDERX1, SLIDER1Y, SLIDERX2, SLIDER1Y);
  line(SLIDERX1, SLIDER2Y, SLIDERX2, SLIDER2Y);
  line(SLIDERX1, SLIDER3Y, SLIDERX2, SLIDER3Y);
  textSize(20);
  fill(255, 0, 0);
  text(brushR, SLIDERX2 + 15, SLIDER1Y + 5);
  fill(0, 230, 0);
  text(brushG, SLIDERX2 + 15, SLIDER2Y + 5);
  fill(0, 0, 255);
  text(brushB, SLIDERX2 + 15, SLIDER3Y + 5);
  rectMode(RADIUS);
  strokeWeight(1);
  fill(255);
  int x1 = SLIDERX1 + brushR;
  int x2 = SLIDERX1 + brushG;
  int x3 = SLIDERX1 + brushB;
  rect(x1, SLIDER1Y, 10, 10);
  rect(x2, SLIDER2Y, 10, 10);
  rect(x3, SLIDER3Y, 10, 10);
  if(overButton(x1, SLIDER1Y, 10)){
    line(x1 - 7, SLIDER1Y - 7, x1 + 7, SLIDER1Y + 7);
    line(x1 - 7, SLIDER1Y + 7, x1 + 7, SLIDER1Y - 7);
    return 1;
  }
  else if(overButton(x2, SLIDER2Y, 10)){
    line(x2 - 7, SLIDER2Y - 7, x2 + 7, SLIDER2Y + 7);
    line(x2 - 7, SLIDER2Y + 7, x2 + 7, SLIDER2Y - 7);
    return 2;
  }
  else if(overButton(x3, SLIDER3Y, 10)){
    line(x3 - 7, SLIDER3Y - 7, x3 + 7, SLIDER3Y + 7);
    line(x3 - 7, SLIDER3Y + 7, x3 + 7, SLIDER3Y - 7);
    return 3;
  }
  return 0;
}

void drawSaveButton(){
  rectMode(CORNERS);
  fill(255);
  strokeWeight(2);
  stroke(0);
  rect(SAVEBUTTONX1, SAVEBUTTONY1, SAVEBUTTONX2, SAVEBUTTONY2);
  fill(0);
  textSize(30);
  text("SAVE", SAVEBUTTONX1 + 5, SAVEBUTTONY1 + 50);
  if(saved){
    if(saveTimer > 120){
      saveTimer = 0;
      saved = false;
    }
    textSize(14);
    text("Image saved", SAVEBUTTONX1, SAVEBUTTONY1 + 100);
    saveTimer++;
  }
}

void drawTransparencyButton(){
  rectMode(CORNERS);
  fill(255);
  strokeWeight(2);
  stroke(0);
  rect(TRANSPARENCYBUTTONX1, TRANSPARENCYBUTTONY1, TRANSPARENCYBUTTONX2, TRANSPARENCYBUTTONY2);
  fill(0);
  textSize(18);
  text("Transparency:", TRANSPARENCYBUTTONX1 + 5, TRANSPARENCYBUTTONY1 + 20);
  textSize(30);
  if(transparency){
    text("ON", TRANSPARENCYBUTTONX1 + 40, TRANSPARENCYBUTTONY1 + 50);
  }
  else{
    text("OFF", TRANSPARENCYBUTTONX1 + 40, TRANSPARENCYBUTTONY1 + 50);
  }
}

void drawFillButton(){
  rectMode(CORNERS);
  fill(255);
  strokeWeight(2);
  stroke(0);
  rect(FILLBUTTONX1, FILLBUTTONY1, FILLBUTTONX2, FILLBUTTONY2);
  fill(0);
  textSize(20);
  text("Fill:", FILLBUTTONX1 + 25, FILLBUTTONY1 + 20);
  textSize(30);
  if(fill){
    text("ON", FILLBUTTONX1 + 15, FILLBUTTONY1 + 60);
  }
  else{
    text("OFF", FILLBUTTONX1 + 15, FILLBUTTONY1 + 60);
  }
}
boolean overButton(int x, int y, int size){
  return (mouseX >= x - size && mouseX <= x + size && mouseY >= y - size && mouseY <= y + size);
}

boolean overButton(int x1, int y1, int x2, int y2){
  return (mouseX >= x1 && mouseX <= x2 && mouseY >= y1 && mouseY <= y2);
}

String getTime(){
  Calendar c = Calendar.getInstance(); 
  String str = c.toString();
  String[] list = str.split(",");
  String year = list[29].substring(5, list[29].length());
  String month = String.valueOf(Integer.valueOf(list[30].substring(6, list[30].length()))+1);
  month = addZero(month);
  String day = list[33].substring(13, list[33].length());
  day = addZero(day);
  String hour = list[39].substring(12, list[39].length());
  hour = addZero(hour);
  String minute = list[40].substring(7, list[40].length());
  minute = addZero(minute);
  String second = list[41].substring(7, list[41].length());
  second = addZero(second);
  return month + "-" + day + "-" + year + " " + hour + "." + minute + "." + second;
}

String addZero(String str){
  if(str.length() == 1){
    str = 0 + str;
  }
  return str;
}

void minimize(){
  finalImage.beginDraw();
  finalImage.background(255, 0);
  finalImage.strokeWeight(1);
  for(int i = 0; i < PIXELSX; i++){
    for(int j = 0; j < PIXELSY; j++){
      if(pixelArray[i][j][0] != -1){
        finalImage.stroke(pixelArray[i][j][0], pixelArray[i][j][1], pixelArray[i][j][2], 255);
        finalImage.point(i, j);
      }
    }
  }
  finalImage.endDraw();
  finalImage.save(getTime() + ".png");
}
