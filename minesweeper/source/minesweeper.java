import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class minesweeper extends PApplet {

// Minesweeper AI by Ben Liu
// May 15, 2020

////////////////////////////////////////////////////////////////////////////////////////////
// You can change this!

// Number of bombs in the game
int numOfMines = 10;
// Number of tiles in the game
int columns = 9;
int rows = 9;

// Regular minesweeper rules:
// Easy:   9x9,   10 mines
// Medium: 16x16, 40 mines
// Expert: 30x16, 99 mines
////////////////////////////////////////////////////////////////////////////////////////////

// 2D array of all tile objects
Tile[][] tiles;
// Arraylist of the tiles used in the probability calculations
ArrayList<Tile> tileBucket = new ArrayList<Tile>();

// Global variables
int totalTiles = columns * rows;
int timer = 0;
int flagsLeft = numOfMines;
int tilesLeft;
int aiMode = 0;
boolean firstClick = true;
boolean gameOver = false;
boolean win = false;

// Variables for testing win rate
int wins = 0;
int totalGames = 0;
boolean restarted = true;

public void settings() {
  // Calculates and sets the size of the window
  final int SIZEX = columns * 40 + 201;
  final int SIZEY = rows * 40 + 101;
  size(SIZEX, SIZEY);
}
public void setup() {
  // Declare the tile object array
  tiles = new Tile[columns][rows];
  // Create all the tiles
  createTiles();
  
  textAlign(CENTER, CENTER);
}

// This is the "main" method
public void draw() {
  background(220);
  stroke(0);
  strokeWeight(4);
  line(0, 96, width, 96);
  line(width - 198, 100, width - 198, height);

  // Display the icons
  drawFlag(0, 20);
  drawClock(100, 40);
  drawRestart(width * 0.875f, 40);
  drawAIButton(width - 195, 99);

  // Display the text for the timer and the flags left
  fill(0);
  textSize(20);
  // Processing runs at 60 fps on default settings
  // Therefore, each 60 iterations of the void_draw is one second
  text(timer/60, 150, 40);
  text(flagsLeft, 50, 40);
  //float percentage = (float)wins/totalGames*100;
  //textSize(15);
  //text(percentage, width - 150, height - 50);
  //text(totalGames, width - 50, height - 50);

  // Displays all the tiles
  int total = 0;
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      // Display methods
      tiles[i][j].displayTile();
      tiles[i][j].displayFlag();
      tiles[i][j].displayNum();
      if (aiMode == 1) {
        tiles[i][j].displayProbability();
      }
      if (!gameOver && !win && (aiMode == 1 || aiMode == 2)) {
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
  if (!gameOver && !win) {
    if (aiMode == 1 && !firstClick) {
      // Display tile probability in "step" mode
      findProbability();
    } else if (aiMode == 2) {
      // Run the probability calculations in "fast" mode
      boolean didAction = deductiveReasoning();
      if (!didAction && timer > 10) {
        calculateProbability();
        double probability = 100;
        double minimum = 100;
        Tile tile = tiles[0][0];
        for (int i = 0; i < columns; i++) {
          for (int j = 0; j < rows; j++) {
            probability = tiles[i][j].getProbability();
            // Flag a tile if it 100% has a mine
            if (probability > 99.999f) {
              flagEvent(i, j);
              return;
            // Else find the tile with the lowest probabilty and reveal it
            } else if (probability < minimum && !tiles[i][j].getRevealed() && !tiles[i][j].getFlag()) {
              minimum = probability;
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
    text("You win!", width * 0.625f, 40);
    //if(restarted){
    //  wins++;
    //  totalGames++;
    //  restarted = false;
    //}
    //restart();
  } else if (gameOver) {
    textSize(30);
    fill(255, 0, 0);
    text("Game over", width * 0.625f, 40);
    //if(restarted){
    //  totalGames++;
    //  restarted = false;
    //}
    //restart();
  } else {
    // Only run the timer if the game is active
    timer++;
  }
}

public void mousePressed() {
  // Restart if the player clicks the restart button
  if (mouseX >= width * 0.875f - 25 && mouseX <= width * 0.875f + 25 && mouseY >= 15 && mouseY <= 65) {
    restart();
  }
  // Switch modes
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

public void keyPressed() {
  // Reveal or flag a tile whenever a keyboard button is pressed in "step" mode
  if (aiMode == 1 && !gameOver && !win) {
    if (firstClick) {
      int c = (int)random(0, columns);
      int r = (int)random(0, rows);
      revealEvent(c, r);
    } else {
      double probability;
      double minimum = 100;
      Tile tile = tiles[0][0];
      for (int i = 0; i < columns; i++) {
        for (int j = 0; j < rows; j++) {
          probability = tiles[i][j].getProbability();
          if (probability > 99.999f) {
            flagEvent(i, j);
            return;
          } else if (probability < minimum && !tiles[i][j].getRevealed() && !tiles[i][j].getFlag()) {
            minimum = probability;
            tile = tiles[i][j];
          }
        }
      }
      tile.reveal();
    }
  }
}

/**
*method revealEvent - Reveals a certain tile. If it is the first click, then create the mines
*@param c the column of the tile
*@param r the row of the tile
*/
public void revealEvent(int c, int r) {
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
  if (!tiles[c][r].getFlag()) {
    tiles[c][r].setFlag(true);
    flagsLeft--;
  } else {
    tiles[c][r].setFlag(false);
    flagsLeft++;
  }
}

/**
*method findProbability - finds the probabilty of tiles in "step" mode
*It won't accurately show probabilities when it uses deductive reasoning
*to save on processing power
*/
public void findProbability() {
  // Find the number of tiles left unrevealed
  int total = 0;
  boolean foundTile = false;
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      if (tiles[i][j].getRevealed()) {
        total++;
      }
    }
  }
  int localTilesLeft = totalTiles - total;
  // Calculate and the set the probability of unknown tiles
  double generalProbability = (double)flagsLeft / localTilesLeft * 100;
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      tiles[i][j].setProbability(generalProbability);
    }
  }
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      // Find tiles that must have mines
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
      // Find tiles that must be safe
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
  // Only calculate the probability of other tiles if deductive reasoning isn't used
  if (!foundTile) {
    calculateProbability();
  }
}
/**
*method deductiveReasoning - Uses deductive reasoning to flag/reveal tiles.
*Pretty much the same as the findProababilty method, but takes action instead
*@return whether the method flagged/revealed a tile
*/
public boolean deductiveReasoning() {
  boolean didAction = false;
  if (firstClick) {
    int c = (int)random(0, columns);
    int r = (int)random(0, rows);
    revealEvent(c, r);
    if (aiMode == 1) {
      return true;
    } else {
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
                if (aiMode == 1) {
                  return true;
                } else {
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
                if (aiMode == 1) {
                  return true;
                } else {
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

/**
*method calculateProbabilty - calculates the probability of unrevealed tiles that border revealed tiles
*/
public void calculateProbability() {
  createBucket();
  // If the array "tileBucket" is too long, the program will freeze
  // the computational power to calculate many tiles is too much
  if (tileBucket.size() <= 20) {
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
    double generalProbability = (double)flagsLeft / localTilesLeft * 100;
    // Reset values
    for (int i = 0; i < columns; i++) {
      for (int j = 0; j < rows; j++) {
        tiles[i][j].setProbability(generalProbability);
        tiles[i][j].setMineInstance(0);
        tiles[i][j].setInstance(0);
      }
    }
    // The master list contains all possible combinations of mine / not mine
    ArrayList<int[]> masterList = createAllPossibilities();
    total = 0;
    int mines = 0;
    int totalValid = 0;
    boolean valid;
    for (int i = 0; i < masterList.size(); i ++) {
      valid = true;
      mines = 0;
      // Set the tiles to either have or not have a mine for this instance
      int[] list = masterList.get(i);
      for (int j = 0; j < list.length; j ++) {
        Tile tile = tileBucket.get(j);
        tile.setMineInstance(list[j]);
        if (list[j] == 1) {
          mines++;
        }
      }
      // Checks to see if the combination is valid
      if (mines > flagsLeft) {
        valid = false;
      }
      for (int x = 0; x < columns; x++) {
        for (int y = 0; y < rows; y++) {
          if (tiles[x][y].getRevealed() && tiles[x][y].getTileNum() != 0) {
            for (int dx = -1; dx <= 1; dx++) {
              for (int dy = -1; dy <= 1; dy++) {
                int c = x + dx;
                int r = y + dy;
                if (c >= 0 && r >= 0 && c < columns && r < rows && (tiles[c][r].getMineInstance() == 1 || tiles[c][r].getFlag())) {
                  total++;
                }
              }
            }
            if (total != tiles[x][y].getTileNum()) {
              valid = false;
            }
            total = 0;
          }
        }
      }
      // If it is valid, then add it to the tile's probabilty to have a mine
      if (valid) {
        totalValid++;
        for (int j = 0; j < list.length; j ++) {
          Tile tile = tileBucket.get(j);
          if (tile.getMineInstance() == 1) {
            tile.addInstance();
          }
        }
      }
    }
    // Set the probability of the mine
    for (int i = 0; i < tileBucket.size(); i ++) {
      double probability = (double)tileBucket.get(i).getInstance() / totalValid * 100;
      tileBucket.get(i).setProbability(probability);
    }
    totalValid = 0;
  } else {
    fill(0);
    textSize(15);
    text("Too many possible tiles", width - 100, height - 50);
  }
}

/**
*method createBucket - adds all the unrevealed tiles adjacent to revealed tiles to an array
*/
public void createBucket() {
  tileBucket.clear();
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      if (tiles[i][j].getRevealed() && tiles[i][j].getTileNum() != 0 && !tiles[i][j].getFlag()) {
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

/**
*method createAllPossibilities - creates all possibilities of mine/not mine.
*Basically uses binary counting to achieve its task
*@return an arraylist of intlists of possibilities
*/
public ArrayList<int[]> createAllPossibilities() {
  int num = tileBucket.size();
  int[] bucketList = new int[num];
  ArrayList<int[]> list = new ArrayList<int[]>();
  //Binary counting
  if (num > 0) {
    bucketList[0] = -1;
    int maximum = (int)pow(2, num);
    for (int i = 0; i < maximum; i++) {
      bucketList[0] += 1;
      for (int j = 0; j < num; j++) {
        if (bucketList[j] > 1) {
          bucketList[j] = 0;
          bucketList[j + 1] += 1;
        }
      }
      //Add that set of mine/not mine to the arraylist
      int[] temp = new int[num];
      temp = bucketList.clone();
      list.add(temp);
    }
  }
  return list;
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
  int emptySpaces;
  if (numOfMines <= 20) {
    emptySpaces = 1;
  } else {
    emptySpaces = 2;
  }
  while (minesLeft > 0) {
    // Selects tiles at random until all the mines are created
    int i = PApplet.parseInt(random(0, columns));
    int j = PApplet.parseInt(random(0, rows));
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
*method calcCoveredTiles - calculates how many covered tiles and flags are next to each tile
*/
public void calcCoveredTiles() {
  int totalCovered = 0;
  int totalFlags = 0;
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
            if (r >= 0 && r < rows) {
              if (!tiles[c][r].getRevealed()) {
                totalCovered++;
              }
              if (tiles[c][r].getFlag()) {
                totalFlags++;
              }
            }
          }
        }
      }
      tiles[x][y].setCoveredTiles(totalCovered);
      totalCovered = 0;
      tiles[x][y].setKnownMines(totalFlags);
      totalFlags = 0;
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
  timer = 0;
  flagsLeft = numOfMines;
  restarted = true;
}

/**
*method revealEmptyTiles - reveals all adjacent tiles.
*This method is used when a tile of value 0 is revealed
*@param x the column of the tile
*@param y the row of the tile
*/
public void revealEmptyTiles(int x, int y) {
  for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
      int c = x + dx;
      int r = y + dy;
      if (c >= 0 && c < columns && r >= 0 && r < rows){
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
*method drawAIButton - draws all the AI buttons
*@param x the x-coordinate
*@param y the y-coordinate
*/
public void drawAIButton(float x, float y) {
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
  // AI variables
  private int coveredTiles, knownMines, totalInstance, mineThisInstance;
  private double probability;
  
  /**
  *Constructor of objects of class Tile
  */
  Tile (int c, int r) { 
    this.column = c;
    this.row = r;
    // These variables scale the column and row, making it easier to draw things
    this.x = column * 40;
    this.y = row * 40 + 100;
    this.tileNum = 0;
    this.revealed = false;
    this.mine = false;
    this.flag = false;
    this.coveredTiles = 0;
    this.knownMines = 0;
    this.totalInstance = 0;
    this.mineThisInstance = 0;
    this.probability = 100;
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
      if (this.probability <= 0.001f) {
        fill(0, 230, 0);
      } else if (this.probability >= 99.999f) {
        fill(255, 0, 0);
      } else {
        fill(230, 230, 0);
      }
      rect(this.x + 5, this.y + 5, 30, 30);
      fill(0);
      textSize(12);
      text((int)this.probability, this.x + 20, this.y + 20);
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
  
  public int getTileNum() {
    return this.tileNum;
  }
  
  public int getCoveredTiles() {
    return this.coveredTiles;
  }
  
  public int getKnownMines() {
    return this.knownMines;
  }
  
  public int getInstance() {
    return this.totalInstance;
  }
  
  public double getProbability() {
    return this.probability;
  }
  
  public int getMineInstance() {
    return this.mineThisInstance;
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

  public void setTileNum(int newTileNum) {
    this.tileNum = newTileNum;
  }
  
  public void setCoveredTiles(int newCoveredTiles) {
    this.coveredTiles = newCoveredTiles;
  }

  public void setKnownMines(int newKnowMines) {
    this.knownMines = newKnowMines;
  }

  public void setInstance(int newInstance) {
    this.totalInstance = newInstance;
  }

  public void addInstance() {
    this.totalInstance++;
  }

  public void setProbability(double newProbability) {
    this.probability = newProbability;
  }

  public void setMineInstance(int newMineThisInstance) {
    this.mineThisInstance = newMineThisInstance;
  }

  public String toString() {
    return "column: " + (column+1) + " row: " + (row+1);
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "minesweeper" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
