// Minesweeper AI by Ben Liu
// May 14, 2020

// 2D array of all tile objects
Tile[][] tiles;
ArrayList<Tile> tileBucket = new ArrayList<Tile>();

////////////////////////////////////////////////////////////////////////////////////////////
// You can change this!

// Number of bombs in the game
// Make sure the # of mines do not exceed the # of tiles
int numOfMines = 10;

// Number of tiles in the game
// Make sure to resize the window below if you change the # of rows/columns
int columns = 9;
int rows = 9;

// Regular minesweeper rules:
// Easy:   9x9,   10 mines | size(561, 461);
// Medium: 16x16, 40 mines | size(841, 741);
// Expert: 30x16, 99 mines | size(1401, 741);
////////////////////////////////////////////////////////////////////////////////////////////

// Global variables
int totalTiles = columns * rows;
int timer = 0;
int flagsLeft = numOfMines;
int tilesLeft;
int aiMode = 0;
boolean firstClick = true;
boolean gameOver = false;
boolean win = false;

boolean calculating = false;

void settings(){
  final int SIZEX = columns * 40 + 201;
  final int SIZEY = rows * 40 + 101;
  size(SIZEX, SIZEY);
}
void setup() {
  // Declare the tile object array
  tiles = new Tile[columns][rows];
  textAlign(CENTER, CENTER);
  // Create all the tiles
  createTiles();
}

void draw() {
  background(220);
  // Display the top of the window
  stroke(0);
  strokeWeight(4);
  line(0, 96, width, 96);
  line(width - 198, 100, width - 198, height);

  // Display the three icons at the top
  drawFlag(0, 20);
  drawClock(100, 40);
  drawRestart(width * 0.875, 40);
  drawAIButton(width - 195, 99);

  // Display the text for the timer and the flags left
  fill(0);
  textSize(20);
  // Processing runs at 60 fps on default settings
  // Therefore, each 60 iterations of the void_draw is one second
  text(timer/60, 150, 40);
  text(flagsLeft, 50, 40);
  textSize(25);

  // Displays all the tiles
  int total = 0;
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {

      // Display methods
      tiles[i][j].displayTile();
      tiles[i][j].displayMine();
      tiles[i][j].displayFlag();
      tiles[i][j].displayNum();
      if(aiMode == 1){
        tiles[i][j].displayProbability();
      }
      if (!gameOver && !win) {
        calcCoveredTiles();
      }

      if (tiles[i][j].getRevealed()) {

        // If the player reveals a tile with a mine, then it's game over
        if (tiles[i][j].getMine()) {
          gameOver = true;
        }

        // If the player reveals a tile with no mines around it,
        // reveal all the adjacent tiles automatically
        if (tiles[i][j].getTileNum() == 0 && !tiles[i][j].getMine()) {
          revealEmptyTiles(i, j);
        }

        // Each revealed tile adds the accumulator variable "total"
        total++;
      }
        

      // When it's game over, then
      // 1. Show all the mines
      // 2. Display a X if the player flagged a tile without a mine (incorrect flagging)
      // 3. Show which mine they revealed
      if (gameOver) {
        tiles[i][j].displayAllMines();
        if (tiles[i][j].getFlag()&& !tiles[i][j].getMine()) {
          tiles[i][j].displayCross();
        }
        if (tiles[i][j].getRevealed()&& tiles[i][j].getMine()) {
          tiles[i][j].displayCross();
        }
      }
    }
  }

  // This determines whether all the tiles without a mine have been revealed
  // (this means the player won)
  tilesLeft = totalTiles - total - numOfMines;
  if (tilesLeft == 0 && !gameOver) {
    win = true;
  }
  if(!gameOver && !win){
    if (aiMode == 1 && !calculating) {
      deductiveReasoningProbability();
    }
    else if (aiMode == 2) {
      boolean didAction = deductiveReasoning();
      if(!didAction){
        calculateProbability();
        double probability = 100;
        boolean good = false;
        int c = 0;
        int r = 0;
        while(!good){
          c = (int)random(0, columns);
          r = (int)random(0, columns);
          if(!tiles[c][r].getRevealed() && !tiles[c][r].getFlag() && !tileBucket.contains(tiles[c][r])){
            good = true;
          }
        }
        Tile tile = tiles[c][r];
        for(int i = 0; i < columns; i++){
          for(int j = 0; j < rows; j++){
            if(tiles[i][j].getProbability() < probability){
              probability = tiles[i][j].getProbability();
              tile = tiles[i][j];
            }
          }
        }
        tile.reveal();
      }
    }
  }
  if (win) {
    fill(0, 200, 0);
    textSize(30);
    text("You win!", width * 0.625, 40);
  } else if (gameOver) {
    textSize(30);
    fill(255, 0, 0);
    text("Game over", width * 0.625, 40);
  } else {
    // Only run the timer if the game is active
    timer++;
  }
}

void mousePressed() {

  // Restart if the player clicks the restart button
  if (mouseX >= width * 0.875 - 25 && mouseX <= width * 0.875 + 25 && mouseY >= 15 && mouseY <= 65) {
    restart();
  }
  //(width - 150, 174 + 75x), x + 45, y + 75, (100, 50)
  else if (mouseX >= width - 150 && mouseX <= width - 50 && mouseY >= 174 && mouseY <= 224) {
    aiMode = 0;
  } else if (mouseX >= width - 150 && mouseX <= width - 50 && mouseY >= 249 && mouseY <= 299) {
    aiMode = 1;
  } else if (mouseX >= width - 150 && mouseX <= width - 50 && mouseY >= 324 && mouseY <= 374) {
    aiMode = 2;
  } else if (mouseY >= 100 && mouseX < width - 200) {

    // Calculates the tile's column and row from the mouse's position (in pixels)
    int column = mouseX / 40;
    int row = (mouseY - 100) / 40;

    if (!gameOver&& !win) {

      // Reveals a tile if the player left-clicks on a tile
      if (mouseButton == LEFT) {
        if (!tiles[column][row].getFlag() && !tiles[column][row].getRevealed()) {
          revealEvent(column, row);
        }
      }

      // Flags/Unflags a tile if the player right-clicks on a tile
      else if (mouseButton == RIGHT) {
        if (!tiles[column][row].getRevealed()) {
          flagEvent(column, row);
        }
      }
    }
  }
}

void keyPressed() {
  if (aiMode == 1 && !gameOver && !win) {
    boolean didAction = deductiveReasoning();
    if(!didAction){
      calculateProbability();
      double probability = 100;
      Tile tile = tiles[0][0];
      for(int i = 0; i < columns; i++){
        for(int j = 0; j < rows; j++){
          if(!tiles[i][j].getRevealed() && !tiles[i][j].getFlag() && !tileBucket.contains(tiles[i][j])){
            tile = tiles[i][j];
          }
        }
      }
      for(int i = 0; i < columns; i++){
        for(int j = 0; j < rows; j++){
          if(tiles[i][j].getProbability() < probability){
            probability = tiles[i][j].getProbability();
            tile = tiles[i][j];
          }
        }
      }
      tile.reveal();
    }
  }
}

void revealEvent(int c, int r) {
  tiles[c][r].reveal();

  // Only create the mines after the first tile is revealed
  // This guarantees the player does not lose on the first turn
  if (firstClick) {

    // Create all the mines
    createMines(c, r);

    // Calculate the number of mines around the tile
    calcTileNum();

    firstClick = false;
  }
  calculating = false;
}

void flagEvent(int c, int r) {
  if (!tiles[c][r].getFlag()) {
    tiles[c][r].setFlag(true);
    flagsLeft--;
  } else {
    tiles[c][r].setFlag(false);
    flagsLeft++;
  }
  calculating = false;
}

void deductiveReasoningProbability(){
  int total = 0;
  boolean foundTile = false;
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      if(tiles[i][j].getRevealed()){
        total++;
      }
    }
  }
  int localTilesLeft = totalTiles - total;
  double generalProbability = (double)flagsLeft / localTilesLeft * 100;
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      tiles[i][j].setProbability(generalProbability);
    }
  }
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      int covTiles = tiles[i][j].getCoveredTiles();
      int tileNumber = tiles[i][j].getTileNum();
      if (covTiles == tileNumber && covTiles != 0) {
        for (int dx = -1; dx <= 1; dx++) {
          for (int dy = -1; dy <= 1; dy++) {
            int c = i + dx;
            int r = j + dy;
            if (c >= 0 && r >= 0 && c < columns && r < rows) {
              if (!tiles[c][r].getRevealed() && !tiles[c][r].getFlag()) {
                tiles[c][r].setProbability(100);
                foundTile = true;
              }
            }
          }
        }
      }
      int knownMines = tiles[i][j].getKnownMines();
      if (knownMines == tileNumber && knownMines != 0 && tiles[i][j].getRevealed()) {
        for (int dx = -1; dx <= 1; dx++) {
          for (int dy = -1; dy <= 1; dy++) {
            int c = i + dx;
            int r = j + dy;
            if (c >= 0 && r >= 0 && c < columns && r < rows) {
              if (!tiles[c][r].getRevealed() && !tiles[c][r].getFlag()) {
                tiles[c][r].setProbability(0);
                foundTile = true;
              }
            }
          }
        }
      }
    }
  }
  if(!foundTile){
    //calculateProbability();
  }
}

boolean deductiveReasoning() {
  boolean didAction = false;
  if (firstClick) {
    int c = (int)random(0, columns);
    int r = (int)random(0, rows);
    revealEvent(c, r);
    if(aiMode == 1){
      return true;
    }
    else{
      didAction = true;
    }
  }
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      int covTiles = tiles[i][j].getCoveredTiles();
      int tileNumber = tiles[i][j].getTileNum();
      if (covTiles == tileNumber && covTiles != 0) {
        for (int dx = -1; dx <= 1; dx++) {
          for (int dy = -1; dy <= 1; dy++) {
            int c = i + dx;
            int r = j + dy;
            if (c >= 0 && r >= 0 && c < columns && r < rows) {
              if (!tiles[c][r].getRevealed() && !tiles[c][r].getFlag()) {
                flagEvent(c, r);
                if(aiMode == 1){
                  return true;
                }
                else{
                  didAction = true;
                }
              }
            }
          }
        }
      }
      int knownMines = tiles[i][j].getKnownMines();
      if (knownMines == tileNumber && knownMines != 0 && tiles[i][j].getRevealed()) {
        for (int dx = -1; dx <= 1; dx++) {
          for (int dy = -1; dy <= 1; dy++) {
            int c = i + dx;
            int r = j + dy;
            if (c >= 0 && r >= 0 && c < columns && r < rows) {
              if (!tiles[c][r].getRevealed() && !tiles[c][r].getFlag()) {
                revealEvent(c, r);
                if(aiMode == 1){
                  return true;
                }
                else{
                  didAction = true;
                }
              }
            }
          }
        }
      }
    }
  }
  return didAction;
}

void calculateProbability(){
  println(tileBucket.size());
  ArrayList<int[]> masterList = createAllPossibilities();
  int total = 0;
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      if(tiles[i][j].getRevealed()){
        total++;
      }
    }
  }
  int localTilesLeft = totalTiles - total;
  double generalProbability = (double)flagsLeft / localTilesLeft * 100;
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      tiles[i][j].setProbability(generalProbability);
      tiles[i][j].setInstance(0);
    }
  }
  if(tileBucket.size() <= 20){
    total = 0;
    int mines = 0;
    int totalValid = 0;
    boolean valid = false;
    for(int i = 0; i < masterList.size(); i ++){
      valid = true;
      int[] list = masterList.get(i);
      for(int j = 0; j < list.length; j ++){
        Tile tile = tileBucket.get(j);
        tile.setMineInstance(list[j]);
        if(list[j] == 1){
          mines++;
        }
      }
      if(mines > flagsLeft){
        valid = false;
      }
      mines = 0;
      for (int x = 0; x < columns; x++) {
        for (int y = 0; y < rows; y++) {
          if(tiles[x][y].getRevealed() && tiles[x][y].getTileNum() != 0){
            for (int dx = -1; dx <= 1; dx++) {
              for (int dy = -1; dy <= 1; dy++) {
                int c = x + dx;
                int r = y + dy;
                if (c >= 0 && r >= 0 && c < columns && r < rows && (tiles[c][r].getMineInstance() == 1 || tiles[c][r].getFlag())) {
                  total++;
                }
              }
            }
            if(total != tiles[x][y].getTileNum()){
              valid = false;
            }
            total = 0;
          }
        }
      }
      if(valid){
        totalValid++;
        for(int j = 0; j < list.length; j ++){
          Tile tile = tileBucket.get(j);
          if(tile.getMineInstance() == 1){
            tile.addInstance();
          }
        }
      }
    }
    for(int i = 0; i < tileBucket.size(); i ++){
      double probability = (double)tileBucket.get(i).getInstance() / totalValid * 100;
      tileBucket.get(i).setProbability(probability);
    }
    totalValid = 0;
  }
  else{
    fill(0);
    textSize(15);
    text("Too many possible tiles",width - 100, height - 50);
  }
}

void createBucket(){
  tileBucket.clear();
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      if (tiles[i][j].getRevealed() && tiles[i][j].getTileNum() != 0) {
        for (int dx = -1; dx <= 1; dx++) {
          for (int dy = -1; dy <= 1; dy++) {
            int c = i+dx;
            int r = j+dy;
            if (c >= 0 && c < columns && r >= 0 && r < rows && !tileBucket.contains(tiles[c][r]) && !tiles[c][r].getRevealed() && !tiles[c][r].getFlag()) {
              tileBucket.add(tiles[c][r]);
            }
          }
        }
      }
    }
  }
}

ArrayList<int[]> createAllPossibilities(){
  createBucket();
  int num = tileBucket.size();
  int[] bucketList = new int[num];
  ArrayList<int[]> list = new ArrayList<int[]>();
  if(num > 0){
    bucketList[0] = -1;
    int maximum = (int)pow(2, num);
    for(int i = 0; i < maximum; i++){
      bucketList[0] += 1;
      for(int j = 0; j < num; j++){
        if(bucketList[j] > 1){
          bucketList[j] = 0;
          bucketList[j + 1] += 1;
        }
      }
      int[] temp = new int[num];
      temp = bucketList.clone();
      list.add(temp);
    }
  }
  else{
    println("fail");
  }
  return list;
}

// This function creates all the tiles and adds them to the array
void createTiles() {
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {

      // Instantiate all the tile objects
      tiles[i][j] = new Tile(i, j);
    }
  }
}


// This function assigns all the mines to the tiles at random
// Parameter "c" is the column of the tile of the first click
// Parameter "r" is the row of the tile of the first click
void createMines(int c, int r) {

  int minesLeft = numOfMines;
  int emptySpaces;
  if (numOfMines <= 20) {
    emptySpaces = 1;
  } else {
    emptySpaces = 2;
  }

  while (minesLeft > 0) {

    // Selects tiles at random until all the mines are created
    int i = int(random(0, columns));
    int j = int(random(0, rows));

    // Only create a mine if the tile does not already have a mine and is not
    // within a tile of the initial click

    if (!tiles[i][j].getMine() && (abs(c-i) > emptySpaces || abs(r-j) > emptySpaces)) {
      //println(abs(c-i));
      tiles[i][j].setMine(true);
      minesLeft -= 1;
    }
  }
}

// This function calculates how many mines are adjacent to each tile
// Any way to remove all these for-loops?
void calcTileNum() {

  int total = 0;

  // For each tile...
  for (int x = 0; x < columns; x++) {
    for (int y = 0; y < rows; y++) {

      // Check the tiles surrounding it
      for (int i = -1; i < 2; i++) {

        // Skip checking a tile for mines if the selected tile is outside of the map
        if (x == 0 && i == -1 || x == columns - 1 && i == 1) {
          continue;
        }

        for (int j = -1; j < 2; j++) {

          // Skip checking a tile for mines if the selected tile is outside of the map
          if (y == 0 && j == -1 || y == rows - 1 && j == 1) {
            continue;
          }

          // Skip checking a tile for mines if it is the middle tile
          // (the one being checked by the outer for loops)
          else if (i == 0 && j == 0) {
            continue;
          }

          // If the tile has a mine, add one to the accumulator
          else {
            if (tiles[x + i][y + j].getMine()) {
              total++;
            }
          }
        }
      }

      // Once the inner loops are done, the we know the number of mines in the
      // surrounding tiles
      tiles[x][y].setTileNum(total);
      total = 0;
    }
  }
}

void calcCoveredTiles() {

  int total = 0;
  int totall = 0;

  // For each tile...
  for (int x = 0; x < columns; x++) {
    for (int y = 0; y < rows; y++) {

      // Check the tiles surrounding it
      for (int i = -1; i < 2; i++) {

        // Skip checking a tile for mines if the selected tile is outside of the map
        if (x == 0 && i == -1 || x == columns - 1 && i == 1) {
          continue;
        }

        for (int j = -1; j < 2; j++) {

          // Skip checking a tile for mines if the selected tile is outside of the map
          if (y == 0 && j == -1 || y == rows - 1 && j == 1) {
            continue;
          } else {
            if (!tiles[x + i][y + j].getRevealed()) {
              total++;
            }
            if (tiles[x + i][y + j].getFlag()) {
              totall++;
            }
          }
        }
      }
      tiles[x][y].setCoveredTiles(total);
      total = 0;
      tiles[x][y].setKnownMines(totall);
      totall = 0;
    }
  }
}
// Restarts the game by instantiating all tiles again and reseting all variables
void restart() {
  tiles = new Tile[columns][rows];
  createTiles();
  firstClick = true;
  gameOver = false;
  win = false;
  timer = 0;
  flagsLeft = numOfMines;
}


// This function reveals the tiles adjacent to an empty tile
// Parameters "x" and "y" is the column and row of the tile
void revealEmptyTiles(int x, int y) {
  int xPos;
  int yPos;
  for (int i = -1; i < 2; i++) {
    for (int j = -1; j < 2; j++) {
      xPos = constrain(x + i, 0, columns - 1);
      yPos = constrain(y + j, 0, rows - 1);
      tiles[xPos][yPos].reveal();
    }
  }
}

// Using the coordinates "x" and "y", draw a flag
void drawFlag(float x, float y) {
  strokeWeight(0);
  noStroke();
  fill(0);
  rect(x + 10, y + 28, 20, 5);
  rect(x + 13, y + 26, 14, 2);
  rect(x + 18, y + 10, 4, 20);
  fill(255, 0, 0);
  triangle(x + 8, y + 14, x + 22, y + 8, x + 22, y + 20);
}

// Using the coordinates "x" and "y", draw a clock
void drawClock(float x, float y) {
  stroke(0);
  strokeWeight(2);
  noFill();
  ellipse(x, y, 30, 30);
  line(x, y - 5, x, y);
  line(x + 10, y, x, y);
}

// Using the coordinates "x" and "y", draw a restart button
void drawRestart(float x, float y) {
  stroke(0);
  strokeWeight(2);
  fill(80, 180, 255);
  rect(x - 25, y - 25, 50, 50);
  noFill();
  strokeWeight(3);
  ellipse(x, y, 30, 30);
  triangle(x - 2, y - 15, x + 2, y - 18, x + 2, y - 12);
  stroke(80, 180, 255);
  strokeWeight(8);
  line(x - 9, y - 15, x - 4, y - 8);
}

void drawAIButton(float x, float y) {
  stroke(0);
  strokeWeight(1);
  fill(255, 0, 0);
  rect(x, y, 194, 50);
  fill(0, 0, 200);
  if (aiMode == 0) {
    strokeWeight(10);
    rect(x + 45, y + 75, 100, 50);
    strokeWeight(2);
    rect(x + 45, y + 150, 100, 50);
    rect(x + 45, y + 225, 100, 50);
  } else if (aiMode == 1) {
    strokeWeight(2);
    rect(x + 45, y + 75, 100, 50);
    strokeWeight(10);
    rect(x + 45, y + 150, 100, 50);
    strokeWeight(2);
    rect(x + 45, y + 225, 100, 50);
  } else {
    strokeWeight(2);
    rect(x + 45, y + 75, 100, 50);
    rect(x + 45, y + 150, 100, 50);
    strokeWeight(10);
    rect(x + 45, y + 225, 100, 50);
  }
  fill(255);
  textSize(30);
  text("AI", x + 95, y + 22);
  text("Off", x + 95, y + 97);
  text("Step", x + 95, y + 172);
  text("Fast", x + 95, y + 247);
}

// Parameter "column" is the column of the tile (starting at column 0)
// Parameter "row" is the row of the tile (starting at row 0)
// Parameter "tileNum" is the number of mines around the tile
// Parameter "revealed" is whether the tile has been revealed by the player
// Parameter "mine" is whether the tile contains a mine
// Parameter "flag" is whether the tile is flagged
class Tile {

  private int column, row, tileNum, x, y;
  private boolean revealed, mine, flag; 
  // AI
  private int coveredTiles, knownMines, totalInstance, mineThisInstance;
  private double probability;
  Tile (int c, int r) { 
    column = c;
    row = r;
    // These variables scale the column and row, making it easier to
    // draw things
    x = column * 40;
    y = row * 40 + 100;
    tileNum = 0;
    revealed = false;
    mine = false;
    flag = false;
    coveredTiles = 0;
    knownMines = 0;
    totalInstance = 0;
    mineThisInstance = 0;
    probability = 100;
  }

  void displayTile() {
    if (!revealed) {
      strokeWeight(2);
      stroke(0);
      fill(150);
      rect(x, y, 40, 40);
      fill(200);
      noStroke();
      quad(x, y, x+40, y, x+35, y+5, x+5, y+5);
      quad(x, y, x, y+40, x+5, y+35, x+5, y+5);
      fill(100);
      quad(x+40, y+40, x+40, y, x+35, y+5, x+35, y+35);
      quad(x+40, y+40, x, y+40, x+5, y+35, x+35, y+35);
      
    } else {
      stroke(50);
      strokeWeight(1);
      fill(230);
      rect(x, y, 40, 40);
    }
  }
  
  void displayProbability(){
    if(!flag && !revealed){
      noStroke();
      if(probability <= 0.001){
        fill(0, 230, 0);
      }
      else if(probability >= 99.999){
        fill(255, 0, 0);
      }
      else{
        fill(230, 230, 0);
      }
      rect(x + 5, y + 5, 30, 30);
      fill(0);
      textSize(12);
      text((int)probability, x + 20, y + 20);
    }
  }

  void displayMine() {
    if (mine && revealed) {
      noStroke();
      fill(0);
      ellipse(x + 20, y + 20, 20, 20);
      strokeWeight(2);
      stroke(0);
      line(x + 20, y + 7, x + 20, y + 33);
      line(x + 7, y + 20, x + 33, y + 20);
      strokeWeight(1);
      line(x + 10, y + 10, x + 30, y + 30);
      line(x + 10, y + 30, x + 30, y + 10);
      noStroke();
      fill(255);
      rect(x + 16, y + 16, 4, 4);
    }
  }

  void displayAllMines() {
    if (mine) {
      noStroke();
      fill(0);
      ellipse(x + 20, y + 20, 20, 20);
      strokeWeight(2);
      stroke(0);
      line(x + 20, y + 7, x + 20, y + 33);
      line(x + 7, y + 20, x + 33, y + 20);
      strokeWeight(1);
      line(x + 10, y + 10, x + 30, y + 30);
      line(x + 10, y + 30, x + 30, y + 10);
      noStroke();
      fill(255);
      rect(x + 16, y + 16, 4, 4);
    }
  }

  void displayFlag() {
    if (flag && !revealed) {
      strokeWeight(0);
      noStroke();
      fill(0);
      rect(x + 10, y + 28, 20, 5);
      rect(x + 13, y + 26, 14, 2);
      rect(x + 18, y + 10, 4, 20);
      fill(255, 0, 0);
      triangle(x + 8, y + 14, x + 22, y + 8, x + 22, y + 20);
    }
  }

  void displayCross() {
    stroke(200, 0, 0);
    strokeWeight(4);
    line(x + 5, y + 5, x + 35, y + 35);
    line(x + 5, y + 35, x + 35, y + 5);
  }

  void displayNum() {
    if (!mine && revealed ) {
      textSize(30);
      if (tileNum == 1) {
        fill(30, 30, 255);
      } else if (tileNum == 2) {
        fill(30, 150, 30);
      } else if (tileNum == 3) {
        fill(255, 0, 0);
      } else if (tileNum == 4) {
        fill(0, 0, 150);
      } else if (tileNum == 5) {
        fill(150, 0, 0);
      } else if (tileNum == 6) {
        fill(0, 150, 150);
      } else if (tileNum == 7) {
        fill(0, 0, 0);
      } else if (tileNum == 8) {
        fill(150, 150, 150);
      }
      if (tileNum != 0) {
        text(tileNum, x + 20, y + 18);
      }
    }
  }

  int getC() {
    return column;
  }

  int getR() {
    return row;
  }

  void setMine(boolean newMine) {
    mine = newMine;
  }

  boolean getMine() {
    return mine;
  }

  void setFlag(boolean newFlag) {
    flag = newFlag;
  }

  boolean getFlag() {
    return flag;
  }

  void reveal() {
    revealed = true;
  }

  boolean getRevealed() {
    return revealed;
  }

  void setTileNum(int newTileNum) {
    tileNum = newTileNum;
  }

  int getTileNum() {
    return tileNum;
  }

  void setCoveredTiles(int newCoveredTiles) {
    coveredTiles = newCoveredTiles;
  }

  int getCoveredTiles() {
    return coveredTiles;
  }

  void setKnownMines(int newKnowMines) {
    knownMines = newKnowMines;
  }

  int getKnownMines() {
    return knownMines;
  }
  
  void setInstance(int newInstance){
    totalInstance = newInstance;
  }
  
  void addInstance(){
    totalInstance++;
  }
  
  int getInstance(){
    return totalInstance;
  }
  
  void setProbability(double newProbability){
    probability = newProbability;
  }
  
  double getProbability(){
    return probability;
  }
  
  void setMineInstance(int newMineThisInstance){
    mineThisInstance = newMineThisInstance;
  }
  
  int getMineInstance(){
    return mineThisInstance;
  }

  String toString() {
    return "column: " + (column+1) + " row: " + (row+1);
  }
}
