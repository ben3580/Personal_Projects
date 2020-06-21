import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Calendar; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class MineSweeperAI extends PApplet {

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

public void settings() {
  size(sizeX, sizeY);
}

public void setup() {
  // Create all the tiles
  createTiles();
  textAlign(CENTER, CENTER);
}

// This is the "main" method - will loop as long as the program is running
public void draw() {
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

public void mousePressed() {
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

public void keyPressed(){
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
public void revealEvent(int c, int r) {
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
public void flagEvent(int c, int r) {
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
public void createTiles() {
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
public void createMines(int c, int r) {
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
public void calcTileNum() {
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
public void restart() {
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
public void revealEmptyTiles(int x, int y) {
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
public void drawFlag(float x, float y) {
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
public void drawClock(float x, float y) {
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
public void drawRestart(float x, float y) {
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
public void drawOptionButton(float x, float y){
  stroke(0);
  strokeWeight(2);
  fill(150);
  rect(x - 50, y - 25, 100, 50);
  fill(0);
  textSize(25);
  text("Options", x, y-3);
}

public void drawOptions(){
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
public void drawAIButton() {
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
class AI{
  // ArrayLists containing all the sections
  ArrayList<Tile> uncoveredTiles = new ArrayList<Tile>();
  ArrayList<Tile> section1 = new ArrayList<Tile>();
  ArrayList<Tile> section2 = new ArrayList<Tile>();
  ArrayList<Tile> section3 = new ArrayList<Tile>();
  ArrayList<Tile> section4 = new ArrayList<Tile>();
  ArrayList<Tile> section5 = new ArrayList<Tile>();
  ArrayList<Tile> section6 = new ArrayList<Tile>();
  ArrayList<Tile> section7 = new ArrayList<Tile>();
  ArrayList<Tile> section8 = new ArrayList<Tile>();
  ArrayList<Tile> section9 = new ArrayList<Tile>();
  ArrayList<Tile> section10 = new ArrayList<Tile>();
  ArrayList<Tile> section11 = new ArrayList<Tile>();
  ArrayList<Tile> section12 = new ArrayList<Tile>();
  ArrayList<Tile> section13 = new ArrayList<Tile>();
  ArrayList<Tile> section14 = new ArrayList<Tile>();
  ArrayList<Tile> section15 = new ArrayList<Tile>();
  ArrayList<Tile> section16 = new ArrayList<Tile>();
  ArrayList<Tile> section17 = new ArrayList<Tile>();
  ArrayList<Tile> section18 = new ArrayList<Tile>();
  ArrayList<Tile> section19 = new ArrayList<Tile>();
  ArrayList<Tile> section20 = new ArrayList<Tile>();
  ArrayList<ArrayList<Tile>> allSections = new ArrayList<ArrayList<Tile>>();
  AI(){
    allSections.add(section1);
    allSections.add(section2);
    allSections.add(section3);
    allSections.add(section4);
    allSections.add(section5);
    allSections.add(section6);
    allSections.add(section7);
    allSections.add(section8);
    allSections.add(section9);
    allSections.add(section10);
    allSections.add(section11);
    allSections.add(section12);
    allSections.add(section13);
    allSections.add(section14);
    allSections.add(section15);
    allSections.add(section16);
    allSections.add(section17);
    allSections.add(section18);
    allSections.add(section19);
    allSections.add(section20);
  }
  
  /**
   *method calculateProbabilty - calculates the probability of unrevealed tiles that border revealed tiles
   */
  public void calculateProbability() {
    findUncovered();
    // Find the total number of unrevealed tiles
    int total = 0;
    for (int i = 0; i < columns; i++) {
      for (int j = 0; j < rows; j++) {
        if (tiles[i][j].getRevealed()) {
          total++;
        }
      }
    }
    int localTilesLeft = totalTiles - total;
    // Calculate the probability of the unknown tiles
    float generalProbability = (float)flagsLeft / localTilesLeft * 100;
    // Reset values
    for (int i = 0; i < columns; i++) {
      for (int j = 0; j < rows; j++) {
        tiles[i][j].setProbability(generalProbability);
      }
    }
  
    int listLength1;
    int listLength2;
    int listLength3;
    ArrayList<int[]> combinations = new ArrayList<int[]>();
    ArrayList<Tile> previousTiles = new ArrayList<Tile>();
    ArrayList<Tile> currentTiles = new ArrayList<Tile>();
    ArrayList<Tile> temp1 = new ArrayList<Tile>();
    ArrayList<Tile> temp2 = new ArrayList<Tile>();
    Tile current;
    // For each section in the ArrayList...
    for (int i = 0; i < 20; i++) {
      temp1 = allSections.get(i);
      listLength1 = temp1.size();
      previousTiles.clear();
      combinations.clear();
      //Here we find all the possible combinations in one section
      //This algorithm checks a few tiles at a time and saves the possible combinations, which is then used to create the next set of possible combinations
      //This is far faster than checking all the tiles at once
      for (int j = 0; j < listLength1; j++) {
        temp2 = temp1.get(j).neighborCovered;
        listLength2 = temp2.size();
        //Find the uncovered tile to be checked
        current = temp1.get(j);
        //Find the current covered tiles to be checked
        currentTiles.clear();
        for (int k = 0; k < listLength2; k++) {
          if (!previousTiles.contains(temp2.get(k))) {
            currentTiles.add(temp2.get(k));
          }
        }
        //Create all possible combinations up to this point
        combinations = checkTiles(currentTiles, previousTiles, combinations, current);
        for (int x = 0; x < combinations.size(); x++) {
        }
        listLength3 = currentTiles.size();
        for (int k = 0; k < listLength3; k++) {
          previousTiles.add(currentTiles.get(k));
        }
      }
      //When we find all the possible combinations, we set the probabilities of the tile
      for (int j = 0; j < combinations.size(); j++) {
        int[] list = combinations.get(j);
        for (int k = 0; k < list.length; k++) {
          if (list[k] == 1) {
            previousTiles.get(k).addInstance();
          }
        }
      }
      for (int j = 0; j < previousTiles.size(); j++) {
        float probability = (float)previousTiles.get(j).getInstance() / combinations.size() * 100;
        if(combinations.size() == 0){
          probability = 1000;
        }
        previousTiles.get(j).setProbability(probability);
      }
    }
  }
  
  /**
   *method checkTiles - creates the possible combinations for an ArrayList of tiles
   *@param current the "new" section being checked (covered tiles)
   *@param previous the "old" section (covered tiles). The possible combinations are already set for these tiles so we don't have check them again
   *@param previousCombinations the ArrayList that stores the possible combinations of the old section
   *@param currentTile the tile that needs to be checked (uncovered tile)
   *@return all the possible combinations, combining the old and the new section
   */
  public ArrayList<int[]> checkTiles(ArrayList<Tile> current, ArrayList<Tile> previous, ArrayList<int[]> previousCombinations, Tile currentTile) {
    ArrayList<int[]> currentCombinations = createAllPossibilities(current.size()); //All possiblities in "current" list
    int[] list; //A combination in "currentCombinations"
    ArrayList<int[]> validList = new ArrayList<int[]>(); //Combinations that are valid
    int[] combinedValid; //Used to combine the "previous" and "current" combination lists
    int mines = 0;
    boolean valid = true;
    Tile tile;
    int listLength1;
    int listLength2;
    //Reset values
    for (int i = 0; i < columns; i++) {
      for (int j = 0; j < rows; j++) {
        tiles[i][j].setMineInstance(0);
        tiles[i][j].setInstance(0);
      }
    }
    listLength1 = previousCombinations.size();
    // If there is no new tiles to check, then check if the previous tiles are still valid with
    // the new information (the number of mines around this tile)
    if (current.size() == 0) {
      for (int i = 0; i < listLength1; i++) {
        listLength2 = previousCombinations.get(i).length;
        for (int j = 0; j < listLength2; j++) {
          previous.get(j).setMineInstance(previousCombinations.get(i)[j]);
        }
        valid = isValid(currentTile);
        if (valid) {
          validList.add(previousCombinations.get(i));
        }
      }
    }
    // If there are no previous tiles
    else if (listLength1 == 0) {
      for (int i = 0; i < currentCombinations.size(); i++) {
        mines = 0;
        // Set the tiles to either have or not have a mine for this instance
        list = currentCombinations.get(i);
        for (int j = 0; j < list.length; j++) {
          tile = current.get(j);
          tile.setMineInstance(list[j]);
          if (list[j] == 1) {
            mines++;
          }
        }
        // Checks to see if the combination is valid
        valid = isValid(currentTile);
        // If it is valid, then add it to the list of valid combinations
        if (valid) {
          validList.add(list);
        }
      }
    // If there are previous tiles
    } else {
      int mines2 = 0;
      for (int i = 0; i < listLength1; i++) {
        int[] temp = previousCombinations.get(i);
        listLength2 = temp.length;
        mines = 0;
        // Set the mines from the previous combinations
        for (int j = 0; j < listLength2; j++) {
          previous.get(j).setMineInstance(temp[j]);
          if (temp[j] == 1) {
            mines++;
          }
        }
        for (int j = 0; j < currentCombinations.size(); j++) {
          // Set the tiles to either have or not have a mine for the new tiles
          list = currentCombinations.get(j);
          mines2 = mines;
          for (int k = 0; k < list.length; k++) {
            tile = current.get(k);
            tile.setMineInstance(list[k]);
            if (list[k] == 1) {
              mines2++;
            }
          }
          // If the number of mines in this combination exceed the actual number of tiles, it is invalid
          if (mines2 > flagsLeft) {
            valid = false;
          } else {
            // Checks to see if the combination is valid
            valid = isValid(currentTile);
          }
          // If it is valid, then combine it with the previous combination and add it to the valid list
          if (valid) {
            combinedValid = new int[list.length + listLength2];
            for (int k = 0; k < listLength2; k++) {
              combinedValid[k] = previousCombinations.get(i)[k];
            }
            for (int k = listLength2; k < combinedValid.length; k++) {
              combinedValid[k] = list[k - listLength2];
            }
            validList.add(combinedValid);
          }
        }
      }
    }
    if (validList.size() == 0) {
      println("Error");
    }
    return validList;
  }
  
  /**
   *method isValid - checks whether the combination is valid around one tile
   *@param tile the tile that will be checked
   *@return true if the combination is valid
   */
  public boolean isValid(Tile tile) {
    int total = 0;
    int x = tile.getC();
    int y =tile.getR();
    int c, r;
    boolean valid = true;
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        c = x + dx;
        r = y + dy;
        if (c >= 0 && r >= 0 && c < columns && r < rows && (tiles[c][r].getMineInstance() == 1 || tiles[c][r].getFlag())) {
          total++;
        }
      }
    }
    //Checks whether the number of mines in a combination matched the actual number of mines around the tile
    if (total != tile.getTileNum()) {
      valid = false;
    }
    return valid;
  }
  
  /**
   *method createAllPossibilities - creates all possibilities of mine/not mine.
   *Basically uses binary counting to achieve its task
   *@return all possible combinations, as an integer array
   */
  public ArrayList<int[]> createAllPossibilities(int size) {
    int[] combinationList = new int[size];
    ArrayList<int[]> list = new ArrayList<int[]>();
    if (size > 0) {
      //Binary counting
      combinationList[0] = -1;
      int maximum = round(pow(2, size));
      for (int i = 0; i < maximum; i++) {
        combinationList[0] += 1;
        for (int j = 0; j < size; j++) {
          if (combinationList[j] > 1) {
            combinationList[j] = 0;
            combinationList[j + 1] += 1;
          }
        }
        //Add that set of mine/not mine to the arraylist
        int[] temp = new int[size];
        temp = combinationList.clone();
        list.add(temp);
      }
    }
    return list;
  }
  
  /**
   *method findUncovered - finds all the uncovered tiles that border covered tiles and assigns them to a section
   */
  public void findUncovered() {
    // Reset
    uncoveredTiles.clear();
    for (int i = 0; i < 20; i++) {
      allSections.get(i).clear();
    }
    for (int x = 0; x < columns; x++) {
      for (int y = 0; y < rows; y++) {
        tiles[x][y].neighborCovered.clear();
      }
    }
    boolean good = false;
    int sec = 1;
    int listLength = 0;
    boolean newSection;
    for (int x = 0; x < columns; x++) {
      for (int y = 0; y < rows; y++) {
        if (tiles[x][y].getRevealed() && tiles[x][y].getTileNum() != 0) {
          for (int dx = -1; dx <= 1; dx++) {
            for (int dy = -1; dy <= 1; dy++) {
              int c = x+dx;
              int r = y+dy;
              if (c >= 0 && c < columns && r >= 0 && r < rows && !tiles[c][r].getRevealed() && !tiles[c][r].getFlag()) {
                // Mark this uncovered tile as a tile that will be added to the list
                good = true;
                // Add the tile to the uncovered tile's list of adjacent covered tiles
                tiles[x][y].neighborCovered.add(tiles[c][r]);
              }
            }
          }
          // Add the uncovered tile to the list and check which section it should have
          if (good) {
            listLength = uncoveredTiles.size();
            // If the tile is the first in the list
            if (listLength == 0) {
              tiles[x][y].setSection(sec);
            } else {
              newSection = true;
              ArrayList<Tile> list = tiles[x][y].neighborCovered;
              for (int i = 0; i < listLength && newSection; i++) {
                Tile current = uncoveredTiles.get(i);
                int listLength1 = current.neighborCovered.size();
                for (int j = 0; j < listLength1 && newSection; j++) {
                  Tile temp = current.neighborCovered.get(j);
                  // If the tile shares a neighbor with another tile, then assign the section of the other tile
                  if (list.contains(temp)) {
                    newSection = false;
                    tiles[x][y].setSection(current.getSection());
                  }
                }
              }
              // If it found no previous tiles that share a neighbor, then start a new section
              if (newSection) {
                sec++;
                tiles[x][y].setSection(sec);
              }
            }
            uncoveredTiles.add(tiles[x][y]);
          } else {
            // If the tile should not be added to the list, then set the section to 0
            tiles[x][y].setSection(0);
          }
          good = false;
        }
      }
    }
    listLength = uncoveredTiles.size();
    changeTiles(listLength);
    Tile temp;
    int tempSection;
    // Add tiles to the section lists
    for (int i = 0; i < listLength; i++) {
      temp = uncoveredTiles.get(i);
      tempSection = temp.getSection();
      if (tempSection > 0 && tempSection <= 20 && !allSections.get(tempSection - 1).contains(temp)) {
        allSections.get(tempSection - 1).add(temp);
      }
    }
  }
  
  /**
   *method changeTiles - goes through the list and makes sure all the sections are correct
   *If the sections aren't correct, change them
   */
  public void changeTiles(int listLength) {
    Tile a;
    Tile b;
    int aSection;
    int bSection;
    int smaller = 0;
    int larger = 0;
    boolean needsToChange = true;
    while (needsToChange) {
      needsToChange = false;
      for (int i = 0; i < listLength && !needsToChange; i++) {
        a = uncoveredTiles.get(i);
        aSection = a.getSection();
        for (int j = i; j < listLength && !needsToChange; j++) {
          b = uncoveredTiles.get(j);
          bSection = b.getSection();
          // If the sections of the two tiles don't match...
          if (aSection != bSection) {
            ArrayList<Tile> list = a.neighborCovered;
            int listLength1 = b.neighborCovered.size();
            for (int k = 0; k < listLength1 && !needsToChange; k++) {
              Tile temp = b.neighborCovered.get(k);
              // ...And they share a neighbor, then the section is wrong
              if (list.contains(temp)) {
                if (aSection < bSection) {
                  smaller = aSection;
                  larger = bSection;
                } else {
                  smaller = bSection;
                  larger = aSection;
                }
                // Exit the loop
                needsToChange = true;
              }
            }
          }
        }
      }
      // Change the sections
      if (needsToChange) {
        for (int i = 0; i < listLength; i++) {
          if (uncoveredTiles.get(i).getSection() == larger) {
            uncoveredTiles.get(i).setSection(smaller);
          }
        }
      }
    }
  }
}

class BackgroundTimer{
  private long timeStart;
  private long timeEnd;
  private int timeBetween;
  
  /**
  * Constructor 
  */
  public BackgroundTimer(){
    // Nothing needs to be instantiated  
  }
  
  /**
  *method startTimer - sets the starting time, in milliseconds
  */
  public void startTimer(){
    // Returns the current time in milliseconds (epoch time)
    Calendar start = Calendar.getInstance(); 
    this.timeStart = start.getTimeInMillis();
  }
  
  /**
  *method endTimer - sets the ending time, in milliseconds
  */
  public void endTimer(){
    Calendar end = Calendar.getInstance(); 
    this.timeEnd = end.getTimeInMillis();
  }
  
  /**
  *method getTime - returns the time between the start and end time, in milliseconds
  *@return the time between the start and end time, in milliseconds
  */
  public int getTime(){
    timeBetween = (int)(timeEnd - timeStart);
    return timeBetween;
  }
}
class Tile {

  private int column, row, tileNum, x, y;
  private boolean revealed, mine, flag, zeroRevealed; 
  // AI variables
  private int totalInstance, mineThisInstance, section;
  private float probability;
  private ArrayList<Tile> neighborCovered;
  
  /**
  *Constructor of objects of class Tile
  */
  Tile (int c, int r) { 
    this.column = c;
    this.row = r;
    // Variables x and y scale the column and row, making it easier to draw things
    this.x = column * 40;
    this.y = row * 40 + 100;
    this.tileNum = 0;
    neighborCovered = new ArrayList<Tile>();
  }

  // Display methods
  public void displayTile() {
    if (!this.revealed) {
      strokeWeight(2);
      stroke(0);
      fill(150);
      rect(this.x, this.y, 40, 40);
      fill(200);
      noStroke();
      quad(this.x, this.y, this.x+40, this.y, this.x+35, this.y+5, this.x+5, this.y+5);
      quad(this.x, this.y, this.x, this.y+40, this.x+5, this.y+35, this.x+5, this.y+5);
      fill(100);
      quad(this.x+40, this.y+40, this.x+40, this.y, this.x+35, this.y+5, this.x+35, this.y+35);
      quad(this.x+40, this.y+40, this.x, this.y+40, this.x+5, this.y+35, this.x+35, this.y+35);
    } else {
      stroke(50);
      strokeWeight(1);
      fill(230);
      rect(this.x, this.y, 40, 40);
    }
  }

  public void displayProbability() {
    if (!this.flag && !this.revealed) {
      noStroke();
      if (this.probability == 0) {
        fill(0, 230, 0);
      } else if (this.probability == 100) {
        fill(255, 0, 0);
      } else {
        fill(230, 230, 0);
      }
      rect(this.x + 5, this.y + 5, 30, 30);
      fill(0);
      textSize(12);
      text(round(this.probability), this.x + 20, this.y + 20);
    }
  }

  public void displayAllMines() {
    if (this.mine && !this.flag) {
      noStroke();
      fill(0);
      ellipse(this.x + 20, this.y + 20, 20, 20);
      strokeWeight(2);
      stroke(0);
      line(this.x + 20, this.y + 7, this.x + 20, this.y + 33);
      line(this.x + 7, this.y + 20, this.x + 33, this.y + 20);
      strokeWeight(1);
      line(this.x + 10, this.y + 10, this.x + 30, this.y + 30);
      line(this.x + 10, this.y + 30, this.x + 30, this.y + 10);
      noStroke();
      fill(255);
      rect(this.x + 16, this.y + 16, 4, 4);
    }
  }

  public void displayFlag() {
    if (this.flag && !this.revealed) {
      strokeWeight(0);
      noStroke();
      fill(0);
      rect(this.x + 10, this.y + 28, 20, 5);
      rect(this.x + 13, this.y + 26, 14, 2);
      rect(this.x + 18, this.y + 10, 4, 20);
      fill(255, 0, 0);
      triangle(this.x + 8, this.y + 14, this.x + 22, this.y + 8, this.x + 22, this.y + 20);
    }
  }

  public void displayCross() {
    stroke(200, 0, 0);
    strokeWeight(4);
    line(this.x + 5, this.y + 5, this.x + 35, this.y + 35);
    line(this.x + 5, this.y + 35, this.x + 35, this.y + 5);
  }

  public void displayNum() {
    if (!this.mine && this.revealed ) {
      textSize(30);
      if (this.tileNum == 1) {
        fill(30, 30, 255);
      } else if (this.tileNum == 2) {
        fill(30, 150, 30);
      } else if (this.tileNum == 3) {
        fill(255, 0, 0);
      } else if (this.tileNum == 4) {
        fill(0, 0, 150);
      } else if (this.tileNum == 5) {
        fill(150, 0, 0);
      } else if (this.tileNum == 6) {
        fill(0, 150, 150);
      } else if (this.tileNum == 7) {
        fill(0, 0, 0);
      } else if (this.tileNum == 8) {
        fill(150, 150, 150);
      }
      if (this.tileNum != 0) {
        text(this.tileNum, this.x + 20, this.y + 18);
      }
    }
  }

  // Accessors
  public int getC() {
    return this.column;
  }

  public int getR() {
    return this.row;
  }
  
  public boolean getMine() {
    return this.mine;
  }
  
  public boolean getFlag() {
    return this.flag;
  }

  public boolean getRevealed() {
    return this.revealed;
  }
  
  public boolean getZeroRevealed(){
    return this.zeroRevealed;
  }
  
  public int getTileNum() {
    return this.tileNum;
  }
  
  public int getInstance() {
    return this.totalInstance;
  }
  
  public float getProbability() {
    return this.probability;
  }
  
  public int getMineInstance() {
    return this.mineThisInstance;
  }
  
  public int getSection(){
    return this.section;
  }
  
  // Mutators
  public void setMine(boolean newMine) {
    this.mine = newMine;
  }

  public void setFlag(boolean newFlag) {
    this.flag = newFlag;
  }

  public void reveal() {
    this.revealed = true;
  }
  
  public void setZeroRevealed(boolean newZeroRevealed){
    this.zeroRevealed = newZeroRevealed;
  }

  public void setTileNum(int newTileNum) {
    this.tileNum = newTileNum;
  }

  public void setInstance(int newInstance) {
    this.totalInstance = newInstance;
  }

  public void addInstance() {
    this.totalInstance++;
  }

  public void setProbability(float newProbability) {
    this.probability = newProbability;
  }

  public void setMineInstance(int newMineThisInstance) {
    this.mineThisInstance = newMineThisInstance;
  }
  
  public void setSection(int newSection){
    this.section = newSection;
  }

  public String toString() {
    return "column: " + (column+1) + " row: " + (row+1);
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "MineSweeperAI" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
