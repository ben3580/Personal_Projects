// Minesweeper AI by Ben Liu
// June 20, 2020

// Number of tiles in the game
int columns = 30;
int rows = 16;
// Number of mines in the game
int numOfMines = 99;
// Regular minesweeper rules:
// Easy:   9x9,   10 mines
// Medium: 16x16, 40 mines
// Expert: 30x16, 99 mines

// Calculates and sets the size of the window
int sizeX = columns * 40 + 201;
int sizeY = rows * 40 + 101;

// Global variables
int totalTiles = columns * rows;
int timer = 0;
int foundIn = 0;
int flagsLeft = numOfMines;
int tilesLeft;
int aiMode = 0;
boolean firstClick = true;
boolean gameOver = false;
boolean win = false;
boolean aiChanged = true;
boolean inOption = false;
boolean restarted = true;
String[] tempInfo = {String.valueOf(columns), String.valueOf(rows), String.valueOf(numOfMines)};
int editing = -1;
// 2D array of all tile objects
Tile[][] tiles = new Tile[columns][rows];

BackgroundTimer time = new BackgroundTimer();
AI ai = new AI();

void settings() {
  size(sizeX, sizeY);
}

void setup() {
  // Create all the tiles
  createTiles();
  textAlign(CENTER, CENTER);
}

// This is the "main" method - will loop as long as the program is running
void draw() {
  noStroke();
  fill(205);
  rect(0, 0, sizeX, 100);
  rect(sizeX - 200, 100, 200, sizeY - 100);
  stroke(0);
  strokeWeight(4);
  line(0, 98, width, 98);
  line(width - 198, 100, width - 198, height);

  // Display the icons
  if(!inOption){
    drawFlag(0, 20);
    drawClock(100, 40);
    drawRestart(width - 150, 40);
    // Display the text for the timer and the flags left
    fill(0);
    textSize(20);
    // Processing runs at 60 fps on default settings
    // Therefore, each 60 iterations of the void_draw is one second
    text(timer/60, 150, 40);
    text(flagsLeft, 50, 40);
  }
  else{
    drawOptions();
  }
  drawOptionButton(width - 60, 40);
  drawAIButton();

  // Displays all the tiles
  int total = 0;
  Tile tile;
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      tile = tiles[i][j];
      // Display methods
      tile.displayTile();
      tile.displayFlag();
      tile.displayNum();
      if (aiMode == 1) {
        tile.displayProbability();
      }

      if (tile.getRevealed()) {
        // If the player reveals a tile with a mine, then it's game over
        if (tile.getMine()) {
          gameOver = true;
        }
        // If the player reveals a tile with no mines around it,
        // reveal all the adjacent tiles automatically
        if (tile.getTileNum() == 0 && !tile.getMine() && !tile.getZeroRevealed()) {
          revealEmptyTiles(i, j);
          tile.setZeroRevealed(true);
        }
        // Each revealed tile adds the accumulator variable "total"
        total++;
      }

      // When it's game over, then
      // 1. Show all the mines
      // 2. Display a X if the player flagged a tile without a mine (incorrect flagging)
      // 3. Show which mine they revealed with an X
      if (gameOver) {
        tile.displayAllMines();
        if (tile.getFlag()&& !tile.getMine()) {
          tile.displayCross();
        }
        if (tile.getRevealed()&& tile.getMine()) {
          tile.displayCross();
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
  if (aiMode == 1 && aiChanged && !gameOver && !win) {
    time.startTimer();
    // Display tile probability in "step" mode
    ai.calculateProbability();
    delay(1);
    time.endTimer();
    foundIn = time.getTime();
    aiChanged = false;
  } else if (aiMode == 2) {
    // Run the probability calculations in "fast" mode
    if (firstClick) {
      int c = (int)random(0, columns);
      int r = (int)random(0, rows);
      revealEvent(c, r);
      delay(1);
    }
    else{
      ai.calculateProbability();
      float probability = 100;
      float minimum = 100;
      boolean revealedTile = false;
      tile = tiles[0][0];
      for (int i = 0; i < columns; i++) {
        for (int j = 0; j < rows; j++) {
          if( !tiles[i][j].getRevealed() && !tiles[i][j].getFlag() && !gameOver && !win){
            probability = tiles[i][j].getProbability();
            // Flag a tile if it 100% has a mine
            if (probability >= 99) {
              flagEvent(i, j);
              revealedTile = true;
              // Reveal a tile if it 0% has a mine
            } else if (probability <= 1 && !tiles[i][j].getFlag()) {
              revealEvent(i, j);
              revealedTile = true;
              // Else find the tile with the lowest probabilty and reveal it
            } else if (probability < minimum) {
              minimum = probability;
              tile = tiles[i][j];
            }
          }
        }
      }
      if (!revealedTile && !gameOver && !win) {
        tile.reveal();
        delay(1);
      }
    }
  }
  
  // Display how much time it took to find the probabilities
  if(aiMode == 1){
    fill(0);
    textSize(15);
    text("Probabilities found in:", width - 100, height - 60);
    textSize(20);
    text(foundIn + " milliseconds", width - 100, height - 30);
  }
  // Display the win message
  if (win && !inOption) {
    fill(0, 200, 0);
    textSize(30);
    text("You win!", width - 300, 40);
    if (restarted) {
      restarted = false;
      if(aiMode == 2){
        time.endTimer();
      }
    }
    if(aiMode == 2){
    // Display how much time it took to finish the board
      fill(0);
      textSize(20);
      text("Done in:", width - 100, height - 60);
      text(time.getTime() + " milliseconds", width - 100, height - 30);
    }
  // Display the lose message
  } else if (gameOver && !inOption) {
    textSize(30);
    fill(255, 0, 0);
    text("Game over", width - 300, 40);
  } else {
    // Only run the timer if the game is active
    timer++;
  }
}

void mousePressed() {
  aiChanged = true;
  if(inOption && mouseY >= 15 && mouseY <= 65){
    if(mouseX >= 90 && mouseX <= 140){
      editing = 0;
    }
    else if(mouseX >= 230 && mouseX <= 280){
      editing = 1;
    }
    else if(mouseX >= 370 && mouseX <= 420){
      editing = 2;
    }
  }
  // Restart if the player clicks the restart button
  if (mouseX >= width - 175 && mouseX <= width - 125 && mouseY >= 15 && mouseY <= 65 && !inOption) {
    restart();
  }
  else if(mouseX >= width - 110 && mouseX <= width - 10 && mouseY >= 15 && mouseY <= 65){
    //Set the new tiles and mines
    if(inOption){
      inOption = false;
      columns = Integer.parseInt(tempInfo[0]);
      rows = Integer.parseInt(tempInfo[1]);
      if(columns < 9){
        columns = 9;
      }
      if(rows < 9){
        rows = 9;
      }
      numOfMines = Integer.parseInt(tempInfo[2]);
      sizeX = columns * 40 + 201;
      sizeY = rows * 40 + 101;
      surface.setSize(sizeX, sizeY);
      restart();
    }
    else{
      inOption = true;
      editing = -1;
    }
  }
  // Switch modes
  else if (mouseX >= width - 150 && mouseX <= width - 50 && mouseY >= 175 && mouseY <= 225) {
    aiMode = 0;
  } else if (mouseY >= 250 && mouseY <= 300 && mouseX >= width - 200) {
    if(mouseX >= width - 150 && mouseX <= width - 50 && aiMode != 1){
      aiMode = 1;
      return;
    }
    if(mouseX >= width - 90 && mouseX <= width - 10 && aiMode == 1 && !gameOver && !win){
      // Reveal or flag a tile whenever the button is pressed in "step" mode
      int c = 0;
      int r = 0;
      if (firstClick) {
        c = (int)random(0, columns);
        r = (int)random(0, rows);
        revealEvent(c, r);
      } else {
        float probability;
        float minimum = 100;
        for (int i = 0; i < columns; i++) {
          for (int j = 0; j < rows; j++) {
            probability = tiles[i][j].getProbability();
            if (probability == 100) {
              flagEvent(i, j);
              return;
            } else if (probability < minimum && !tiles[i][j].getRevealed() && !tiles[i][j].getFlag()) {
              minimum = probability;
              c = i;
              r = j;
            }
          }
        }
        revealEvent(c, r);
      }
    }
  } else if (mouseX >= width - 150 && mouseX <= width - 50 && mouseY >= 325 && mouseY <= 375) {
    if(aiMode != 2){
      aiMode = 2;
      time.startTimer();
    }
  } else if (mouseY >= 100 && mouseY <= sizeY && mouseX < sizeX - 200) {
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

void keyPressed(){
  //Keyboard input in the options menu
  if(inOption){
    switch(key){
    case '1':
      tempInfo[editing] += "1";
      break;
    case '2':
      tempInfo[editing] += "2";
      break;
    case '3':
      tempInfo[editing] += "3";
      break;
    case '4':
      tempInfo[editing] += "4";
      break;
    case '5':
      tempInfo[editing] += "5";
      break;
    case '6':
      tempInfo[editing] += "6";
      break;
    case '7':
      tempInfo[editing] += "7";
      break;
    case '8':
      tempInfo[editing] += "8";
      break;
    case '9':
      tempInfo[editing] += "9";
      break;
    case '0':
      tempInfo[editing] += "0";
      break;
    case BACKSPACE:
      if(tempInfo[editing].length() > 0){
        tempInfo[editing] = tempInfo[editing].substring(0, tempInfo[editing].length() - 1);
      }
      break;
    }
    if(tempInfo[editing].length() == 0){
      tempInfo[editing] = "0";
    }
    else if(tempInfo[editing].charAt(0) == '0'){
      tempInfo[editing] = tempInfo[editing].substring(1, tempInfo[editing].length());
    }
    int maximum;
    if(editing == 0){
      maximum = 40;
      if(Integer.parseInt(tempInfo[editing]) > maximum){
        tempInfo[editing] = String.valueOf(maximum);
      }
    }
    else if(editing == 1){
      maximum = 20;
      if(Integer.parseInt(tempInfo[editing]) > maximum){
        tempInfo[editing] = String.valueOf(maximum);
      }
    }
    else if(editing == 2){
      maximum = Integer.parseInt(tempInfo[0]) * Integer.parseInt(tempInfo[1]) / 2;
      if(Integer.parseInt(tempInfo[editing]) > maximum){
        tempInfo[editing] = String.valueOf(maximum);
      }
    }
  }
}

/**
 *method revealEvent - Reveals a certain tile. If it is the first click, then create the mines
 *@param c the column of the tile
 *@param r the row of the tile
 */
void revealEvent(int c, int r) {
  aiChanged = true;
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
}

/**
 *method flagEvent - Flags or unflags a certain tile
 *@param c the column of the tile
 *@param r the row of the tile
 */
void flagEvent(int c, int r) {
  aiChanged = true;
  if (!tiles[c][r].getFlag()) {
    tiles[c][r].setFlag(true);
    flagsLeft--;
  } else {
    tiles[c][r].setFlag(false);
    flagsLeft++;
  }
}

/**
 *method createTiles - creates all the tiles and adds them to the array
 */
void createTiles() {
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      // Instantiate all the tile objects
      tiles[i][j] = new Tile(i, j);
    }
  }
}

/**
 *method createMines - assigns mines to tiles at random
 *@param c the column of the tile of the first click
 *@param r the row of the tile of the first click
 */
void createMines(int c, int r) {
  int minesLeft = numOfMines;
  int emptySpaces = 1;
  while (minesLeft > 0) {
    // Selects tiles at random until all the mines are created
    int i = (int)random(0, columns);
    int j = (int)random(0, rows);
    // Only create a mine if the tile does not already have a mine and is not
    // within a tile of the initial click
    if (!tiles[i][j].getMine() && (abs(c-i) > emptySpaces || abs(r-j) > emptySpaces)) {
      tiles[i][j].setMine(true);
      minesLeft--;
    }
  }
}

/**
 *method createTiles - calculates how many mines are adjacent to each tile
 */
void calcTileNum() {
  int total = 0;
  // For each tile...
  for (int x = 0; x < columns; x++) {
    for (int y = 0; y < rows; y++) {
      // Check the tiles surrounding it
      for (int dx = -1; dx <= 1; dx++) {
        int c = x + dx;
        // Skip checking a tile for mines if the selected tile is outside of the map
        if (c >= 0 && c < columns) {
          for (int dy = -1; dy <= 1; dy++) {
            int r = y + dy;
            // Skip checking a tile for mines if the selected tile is outside of the map
            // Skip checking a tile for mines if the selected tile is the tile being checked
            if (r >= 0 && r < rows && (dx != 0 || dy != 0)) {
              // If the tile has a mine, add one to the accumulator
              if (tiles[c][r].getMine()) {
                total++;
              }
            }
          }
        }
      }
      // Once the inner loops are done, the we know the number of mines in the surrounding tiles
      tiles[x][y].setTileNum(total);
      total = 0;
    }
  }
}

/**
 *method restart - restarts the game by instantiating all tiles again and reseting all variables
 */
void restart() {
  tiles = new Tile[columns][rows];
  createTiles();
  firstClick = true;
  gameOver = false;
  win = false;
  aiChanged = true;
  timer = 0;
  totalTiles = columns * rows;
  flagsLeft = numOfMines;
  restarted = true;
  tempInfo[0] = String.valueOf(columns);
  tempInfo[1] = String.valueOf(rows);
  tempInfo[2] = String.valueOf(numOfMines);
  if (aiMode == 2) {
    time.startTimer();
  }
}

/**
 *method revealEmptyTiles - reveals all adjacent tiles.
 *This method is used when a tile of value 0 is revealed
 *@param x the column of the tile
 *@param y the row of the tile
 */
void revealEmptyTiles(int x, int y) {
  aiChanged = true;
  for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
      int c = x + dx;
      int r = y + dy;
      if (c >= 0 && c < columns && r >= 0 && r < rows) {
        tiles[c][r].reveal();
      }
    }
  }
}

/**
 *method drawFlag - draws a flag at the specified coordinates
 *@param x the x-coordinate
 *@param y the y-coordinate
 */
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

/**
 *method drawClock - draws a clock at the specified coordinates
 *@param x the x-coordinate
 *@param y the y-coordinate
 */
void drawClock(float x, float y) {
  stroke(0);
  strokeWeight(2);
  noFill();
  ellipse(x, y, 30, 30);
  line(x, y - 5, x, y);
  line(x + 10, y, x, y);
}

/**
 *method drawRestart - draws a restart button at the specified coordinates
 *@param x the x-coordinate
 *@param y the y-coordinate
 */
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

/**
 *method drawOption - draws a option button at the specified coordinates
 *@param x the x-coordinate
 *@param y the y-coordinate
 */
void drawOptionButton(float x, float y){
  stroke(0);
  strokeWeight(2);
  fill(150);
  rect(x - 50, y - 25, 100, 50);
  fill(0);
  textSize(25);
  text("Options", x, y-3);
}

void drawOptions(){
  stroke(0);
  fill(255);
  if(editing == 0){
    strokeWeight(5);
  }
  else{
    strokeWeight(2);
  }
  rect(90, 15, 50, 50);
  if(editing == 1){
    strokeWeight(5);
  }
  else{
    strokeWeight(2);
  }
  rect(230, 15, 50, 50);
  if(editing == 2){
    strokeWeight(5);
  }
  else{
    strokeWeight(2);
  }
  rect(370, 15, 50, 50);
  fill(0);
  textSize(20);
  text("Columns", 45, 40);
  text(tempInfo[0], 115, 40);
  text("Rows", 200, 40);
  text(tempInfo[1], 255, 40);
  text("Mines", 335, 40);
  text(tempInfo[2], 395, 40);
}

/**
 *method drawAIButton - draws all the AI buttons
 *@param x the x-coordinate
 *@param y the y-coordinate
 */
void drawAIButton() {
  float x = width - 195;
  float y = 99;
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
    rect(x + 10, y + 150, 80, 50);
    if(mouseX >= x + 90 && mouseX <= x + 190 && mouseY >= y + 150 && mouseY <= y + 200){
      strokeWeight(5);
    }
    else{
      strokeWeight(2);
    }
    rect(x + 110, y + 150, 80, 50);
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
  if(aiMode == 1){
    text("Step", x + 50, y + 172);
    text("Next", x + 150, y + 172);
  }
  else{
    text("Step", x + 95, y + 172);
  }
  text("Fast", x + 95, y + 247);
}
