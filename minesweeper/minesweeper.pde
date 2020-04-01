// Minesweeper clone by Ben Liu
// March 29, 2020

// 2D array of all tile objects
Tile[][] tiles;

////////////////////////////////////////////////////////////////////////////////////////////
// You can change this!

// Number of bombs in the game
// Make sure the # of mines do not exceed the # of tiles
int numOfMines = 40;

// Number of tiles in the game
// Make sure to resize the window below if you change the # of rows/columns
int columns = 16;
int rows = 16;

// Regular minesweeper rules:
// Easy:   9x9,   10 mines | size(361, 461);
// Medium: 16x16, 40 mines | size(641, 741);
// Expert: 30x16, 99 mines | size(1201, 741);
////////////////////////////////////////////////////////////////////////////////////////////

// Global variables
int totalTiles = columns * rows;
int timer = 0;
int flagsLeft = numOfMines;
int tilesLeft;
boolean firstClick = false;
boolean gameOver = false;
boolean win = false;

void setup(){
  // Declare the tile object array
  tiles = new Tile[columns][rows];
  
////////////////////////////////////////////////////////////////////////////////////////////
  // Resize the window here
  // Each row/column is 40 pixels
  // Then, add 1 to the first number and add 101 to the second number
  // Example: 10 columns, 10 rows -> (401, 501)
  size(641, 741);
////////////////////////////////////////////////////////////////////////////////////////////

  textAlign(CENTER, CENTER);
  
  // Create all the tiles
  createTiles();
  
}

void draw(){
  
  // Display the top of the window
  noStroke();
  fill(220);
  rect(0, 0, width, 96);
  stroke(0);
  strokeWeight(4);
  line(0, 98, width, 98);
  
  // Display the three icons at the top
  drawFlag(0, 20);
  drawClock(100, 40);
  drawRestart(width * 0.875, 40);
  
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
  for(int i = 0; i < columns; i++){
    for(int j = 0; j < rows; j++){
      
      // Display methods
      tiles[i][j].displayTile();
      tiles[i][j].displayMine();
      tiles[i][j].displayFlag();
      tiles[i][j].displayNum();
      
      if (tiles[i][j].getRevealed() == true){
        
        // If the player reveals a tile with a mine, then it's game over
        if (tiles[i][j].getMine() == true){
          gameOver = true;
        }
        
        // If the player reveals a tile with no mines around it,
        // reveal all the adjacent tiles automatically
        if (tiles[i][j].getTileNum() == 0 && tiles[i][j].getMine() == false){
          revealEmptyTiles(i, j);
        }
        
        // Each revealed tile adds the accumulator variable "total"
        total++;
      }
      
      // When it's game over, then
      // 1. Show all the mines
      // 2. Display a X if the player flagged a tile without a mine (incorrect flagging)
      // 3. Show which mine they revealed
      if (gameOver == true){
        tiles[i][j].displayAllMines();
        if (tiles[i][j].getFlag() == true && tiles[i][j].getMine() == false){
          tiles[i][j].displayCross();
        }
        if (tiles[i][j].getRevealed() == true && tiles[i][j].getMine() == true){
          tiles[i][j].displayCross();
        }
      }
      
    }
  }
  
  // This determines whether all the tiles without a mine have been revealed
  // (this means the player won)
  tilesLeft = totalTiles - total - numOfMines;
  if (tilesLeft == 0 && gameOver == false){
    win = true;
  }
  
  if (win == true){
    fill(0, 200, 0);
    text("You win!", width * 0.625, 40);
  }
  else if (gameOver == true){
    fill(255, 0, 0);
    text("Game over", width * 0.625, 40);
  }
  else{
    // Only run the timer if the game is active
    timer++;
  }
}

void mousePressed(){
  
  // Restart if the player clicks the restart button
  if (mouseX >= width * 0.875 - 25 && mouseX <= width * 0.875 + 25 && mouseY >= 15 && mouseY <= 65){
    restart();
  }
  
  if (mouseY >= 100){
    
    // Calculates the tile's column and row from the mouse's position (in pixels)
    int column = mouseX / 40;
    int row = (mouseY - 100) / 40;
    
    if (gameOver == false && win == false){
    
      // Reveals a tile if the player left-clicks on a tile
      if (mouseButton == LEFT){
        if (tiles[column][row].getFlag() == false){
          tiles[column][row].reveal();
          
          // Only create the mines after the first tile is revealed
          // This guarantees the player does not lose on the first turn
          if (firstClick == false){
            
            // Create some empty tiles near the first click
            IntList coordinates = createEmptyTiles(column, row);
            
            // Create all the mines
            createMines(coordinates);
            
            // Calculate the number of mines around the tile
            calcTileNum();
            
            firstClick = true;
          }
          
        }
      }
      
      // Flags/Unflags a tile if the player right-clicks on a tile
      else if (mouseButton == RIGHT){
        if (tiles[column][row].getRevealed() == false){
          if (tiles[column][row].getFlag() == false){
            tiles[column][row].setFlag(true);
            flagsLeft--;
          }
          else{
            tiles[column][row].setFlag(false);
            flagsLeft++;
          }
        }
      }
      
    }
  }
}

// This function creates all the tiles and adds them to the array
void createTiles(){
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      
      // Instantiate all the tile objects
      tiles[i][j] = new Tile(i, j, 0, false, false, false);
      
    }
  }
}


// This function assigns all the mines to the tiles at random
// Parameter "emptyTiles" contains the tiles adjacent to the first tile revealed
// This will ensure no mines are placed on those tiles
void createMines(IntList emptyTiles){
  
  int minesLeft = numOfMines;
  
  while(minesLeft > 0){
    
    // Selects tiles at random until all the mines are created
    int i = int(random(0, columns));
    int j = int(random(0, rows));
    int num = j * columns + i;
    
    // Only create a mine if the tile does not already have a mine and is not
    // in the "emptyTiles" list
    if (tiles[i][j].getMine() == false && emptyTiles.hasValue(num) == false){
      tiles[i][j].setMine(true);
      minesLeft -= 1;
      
    }
  }
}

// This function calculates how many mines are adjacent to each tile
// Any way to remove all these for-loops?
void calcTileNum(){
  
  int total = 0;
  
  // For each tile...
  for (int x = 0; x < columns; x++) {
    for (int y = 0; y < rows; y++) {
      
      // Check the tiles surrounding it
      for (int i = -1; i < 2; i++){
        
        // Skip checking a tile for mines if the selected tile is outside of the map
        if (x == 0 && i == -1 || x == columns - 1 && i == 1){
          continue;
        }
        
        for (int j = -1; j < 2; j++){
          
          // Skip checking a tile for mines if the selected tile is outside of the map
          if (y == 0 && j == -1 || y == rows - 1 && j == 1){
            continue;
          }
          
          // Skip checking a tile for mines if it is the middle tile
          // (the one being checked by the outer for loops)
          else if (i == 0 && j == 0){
            continue;
          }
          
          // If the tile has a mine, add one to the accumulator
          else{
            if (tiles[x + i][y + j].getMine() == true){
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

// Restarts the game by instantiating all tiles again and reseting all variables
void restart(){
  tiles = new Tile[columns][rows];
  createTiles();
  firstClick = false;
  gameOver = false;
  win = false;
  timer = 0;
  flagsLeft = numOfMines;
}


// This function reveals the tiles adjacent to an empty tile
// Parameters "x" and "y" is the column and row of the tile
void revealEmptyTiles(int x, int y){
  int xPos;
  int yPos;
  for (int i = -1; i < 2; i++){
    for (int j = -1; j < 2; j++){
      xPos = constrain(x + i, 0, columns - 1);
      yPos = constrain(y + j, 0, rows - 1);
      tiles[xPos][yPos].reveal();
    }
  }
}

// This function returns a list of empty tiles adjacent to the first click
// This guarantees that the player has somewhere to start
// Parameters "x" and "y" is the column and row of the tile
IntList createEmptyTiles(int x, int y){

  IntList emptyTiles;
  emptyTiles = new IntList();

  for (int i = -1; i < 2; i++){
    for (int j = -1; j < 2; j++){
      int num = (y + j) * columns + (i + x);
      emptyTiles.append(num);
    }
  }
  return emptyTiles;
}

// Using the coordinates "x" and "y", draw a flag
void drawFlag(float x, float y){
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
void drawClock(float x, float y){
  stroke(0);
  strokeWeight(2);
  noFill();
  ellipse(x, y, 30, 30);
  line(x, y - 5, x, y);
  line(x + 10, y, x, y);
}

// Using the coordinates "x" and "y", draw a restart button
void drawRestart(float x, float y){
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

// Parameter "column" is the column of the tile (starting at column 0)
// Parameter "row" is the row of the tile (starting at row 0)
// Parameter "tileNum" is the number of mines around the tile
// Parameter "revealed" is whether the tile has been revealed by the player
// Parameter "mine" is whether the tile contains a mine
// Parameter "flag" is whether the tile is flagged
class Tile {
  
  int column, row, tileNum;
  boolean revealed, mine, flag; 
  
  Tile (int c, int r, int n, boolean rev, boolean m, boolean f) { 
    column = c;
    row = r;
    tileNum = n;
    revealed = rev;
    mine = m;
    flag = f;
  }
  
  void displayTile(){
    
    // These variables scale the column and row, ,making it easier to
    // draw things
    int x = column * 40;
    int y = row * 40 + 100;
    
    if (revealed == false) {
      strokeWeight(1);
      stroke(0);
      fill(150);
      rect(x, y, 40, 40);
      fill(200);
      noStroke();
      quad(x, y, x + 40, y, x + 35, y + 5, x + 5, y + 5);
      quad(x, y, x, y + 40, x + 5, y + 35, x + 5, y + 5);
      fill(100);
      quad(x + 40, y + 40, x + 40, y, x + 35, y + 5, x + 35, y + 35);
      quad(x + 40, y + 40, x, y + 40, x + 5, y + 35, x + 35, y + 35);
    }
    else{
      stroke(50);
      strokeWeight(1);
      fill(220);
      rect(x, y, 40, 40);
    }
  }
  
  void displayMine(){
    int x = column * 40;
    int y = row * 40 + 100;
    if (mine == true && revealed == true) {
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
  
  void displayAllMines(){
    int x = column * 40;
    int y = row * 40 + 100;
    if (mine == true) {
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
  
  void displayFlag(){
    int x = column * 40;
    int y = row * 40 + 100;
    if (flag == true && revealed == false){
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
  
  void displayCross(){
    int x = column * 40;
    int y = row * 40 + 100;
    stroke(200, 0, 0);
    strokeWeight(4);
    line(x + 5, y + 5, x + 35, y + 35);
    line(x + 5, y + 35, x + 35, y + 5);
  }
  
  void displayNum(){
    int x = column * 40;
    int y = row * 40 + 100;
    if (mine == false && revealed == true){
      textSize(30);
      if (tileNum == 1){
        fill(30, 30, 255);
      }
      else if (tileNum == 2){
        fill(30, 150, 30);
      }
      else if (tileNum == 3){
        fill(255, 0, 0);
      }
      else if (tileNum == 4){
        fill(0, 0, 150);
      }
      else if (tileNum == 5){
        fill(150, 0, 0);
      }
      else if (tileNum == 6){
        fill(0, 150, 150);
      }
      else if (tileNum == 7){
        fill(0, 0, 0);
      }
      else if (tileNum == 8){
        fill(150, 150, 150);
      }
      if (tileNum != 0){
        text(tileNum, x + 20, y + 18);
      }
    }
  }
  
  void setMine(boolean newMine){
    mine = newMine;
  }
  
  boolean getMine(){
    return mine;
  }
  
  void setFlag(boolean newFlag){
    flag = newFlag;
  }
  
  boolean getFlag(){
    return flag;
  }
  
  void reveal(){
    revealed = true;
  }
  
  boolean getRevealed(){
    return revealed;
  }
  
  void setTileNum(int newTileNum){
    tileNum = newTileNum;
  }
  
  int getTileNum(){
    return tileNum;
  }
}
