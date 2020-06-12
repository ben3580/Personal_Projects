// Minesweeper AI by Ben Liu
// June 12, 2020

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

// 2D array of all tile objects
Tile[][] tiles;

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
ArrayList<ArrayList<Tile>> allSections = new ArrayList<ArrayList<Tile>>();

BackgroundTimer time = new BackgroundTimer();

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
boolean displayChanged = true;
boolean aiChanged = true;
boolean inOption = false;
String[] tempInfo = {String.valueOf(columns), String.valueOf(rows), String.valueOf(numOfMines)};
int editing = -1;

// Variables for testing win rate
int wins = 0;
int totalGames = 0;
boolean restarted = true;

void settings() {
  size(sizeX, sizeY);
}

void setup() {
  surface.setResizable(true);
  // Declare the tile object array
  tiles = new Tile[columns][rows];
  allSections.add(section1);
  allSections.add(section2);
  allSections.add(section3);
  allSections.add(section4);
  allSections.add(section5);
  allSections.add(section6);
  allSections.add(section7);
  allSections.add(section8);
  allSections.add(section9);
  // Create all the tiles
  createTiles();
  textAlign(CENTER, CENTER);
}

// This is the "main" method
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
    //float percentage = (float)wins/totalGames*100;
    //textSize(15);
    //text(percentage, width - 150, height - 50);
    //text(totalGames, width - 50, height - 50);
  }
  else{
    drawOptions();
  }
  drawOptionButton(width - 60, 40);
  drawAIButton();

  // Displays all the tiles
  int total = 0;
  Tile tile;
  if (displayChanged) {
    displayChanged = false;
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
        if (!gameOver && !win && (aiMode == 1 || aiMode == 2)) {
          calcCoveredTiles();
        }

        if (tile.getRevealed()) {
          // If the player reveals a tile with a mine, then it's game over
          if (tile.getMine()) {
            gameOver = true;
          }
          // If the player reveals a tile with no mines around it,
          // reveal all the adjacent tiles automatically
          if (tile.getTileNum() == 0 && !tile.getMine() && tile.getZeroRevealed() == false) {
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
  }

  // This determines whether all the tiles without a mine have been revealed
  // (this means the player won)
  tilesLeft = totalTiles - total - numOfMines;
  if (tilesLeft == 0 && !gameOver) {
    win = true;
  }
  
  if (!gameOver && !win) {
    if (aiMode == 1 && aiChanged) {
      time.startTimer();
      // Display tile probability in "step" mode
      calculateProbability();
      delay(1);
      time.endTimer();
      foundIn = time.getTime();
      aiChanged = false;
      displayChanged = true;
    } else if (aiMode == 2) {
      // Run the probability calculations in "fast" mode
      boolean didAction = deductiveReasoning();
      if (!didAction && timer > 10) {
        calculateProbability();
        float probability = 100;
        float minimum = 100;
        boolean revealedTile = false;
        tile = tiles[0][0];
        for (int i = 0; i < columns; i++) {
          for (int j = 0; j < rows; j++) {
            probability = tiles[i][j].getProbability();
            // Flag a tile if it 100% has a mine
            if (probability == 100) {
              flagEvent(i, j);
              // Reveal a tile if it 0% has a mine
            } else if (probability == 0) {
              revealEvent(i, j);
              revealedTile = true;
              // Else find the tile with the lowest probabilty and reveal it
            } else if (probability < minimum && !tiles[i][j].getRevealed() && !tiles[i][j].getFlag()) {
              minimum = probability;
              tile = tiles[i][j];
            }
          }
        }
        if (!revealedTile) {
          tile.reveal();
        }
      }
    }
  }
  
  if(aiMode == 1){
    fill(0);
    textSize(15);
    text("Probabilities found in:", width - 100, height - 60);
    textSize(20);
    text(foundIn + " milliseconds", width - 100, height - 30);
  }

  if (win && !inOption) {
    fill(0, 200, 0);
    textSize(30);
    text("You win!", width - 300, 40);
    if (restarted) {
      //wins++;
      //totalGames++;
      restarted = false;
      if(aiMode == 2){
        time.endTimer();
      }
    }
    if(aiMode == 2){
      fill(0);
      textSize(20);
      text("Done in:", width - 100, height - 60);
      text(time.getTime() + " milliseconds", width - 100, height - 30);
    }
    //restart();
  } else if (gameOver && !inOption) {
    displayChanged = true;
    textSize(30);
    fill(255, 0, 0);
    text("Game over", width - 300, 40);
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

void mousePressed() {
  displayChanged = true;
  aiChanged = true;
  if(inOption && mouseY >= 15 && mouseY <= 65){
    //rect(90, 15, 50, 50);
    //rect(230, 15, 50, 50);
    //rect(370, 15, 50, 50);
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
    if (aiMode == 2) {
      time.startTimer();
    }
  }
  else if(mouseX >= width - 110 && mouseX <= width - 10 && mouseY >= 15 && mouseY <= 65){
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
      // Reveal or flag a tile whenever a keyboard button is pressed in "step" mode
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
    aiMode = 2;
    time.startTimer();
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
  displayChanged = true;
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
  displayChanged = true;
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
 *method deductiveReasoning - Uses deductive reasoning to flag/reveal tiles.
 *@return true if the method flagged/revealed a tile
 */
boolean deductiveReasoning() {
  boolean didAction = false;
  if (firstClick) {
    int c = (int)random(0, columns);
    int r = (int)random(0, rows);
    revealEvent(c, r);
    didAction = true;
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
                didAction = true;
                flagEvent(c, r);
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
                didAction = true;
                revealEvent(c, r);
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
void calculateProbability() {
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
  for (int i = 0; i < 9; i++) {
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
ArrayList<int[]> checkTiles(ArrayList<Tile> current, ArrayList<Tile> previous, ArrayList<int[]> previousCombinations, Tile currentTile) {
  // The master list contains all possible combinations of mine / not mine
  ArrayList<int[]> masterList = createAllPossibilities(current.size());
  int[] list;
  ArrayList<int[]> validList = new ArrayList<int[]>();
  int[] combinedValid;
  int mines = 0;
  boolean valid = true;
  Tile tile;
  int listLength1;
  int listLength2;
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      tiles[i][j].setMineInstance(0);
      tiles[i][j].setInstance(0);
    }
  }
  listLength1 = previousCombinations.size();
  if (listLength1 == 0) {
    for (int i = 0; i < masterList.size(); i++) {
      mines = 0;
      // Set the tiles to either have or not have a mine for this instance
      list = masterList.get(i);
      for (int j = 0; j < list.length; j++) {
        tile = current.get(j);
        tile.setMineInstance(list[j]);
        if (list[j] == 1) {
          mines++;
        }
      }
      // Checks to see if the combination is valid
      valid = isValid(currentTile);
      // If it is valid, then add it to the tile's probabilty to have a mine
      if (valid) {
        validList.add(list);
      }
    }
  } else {
    int mines2 = 0;
    for (int i = 0; i < listLength1; i++) {
      int[] temp = previousCombinations.get(i);
      listLength2 = temp.length;
      mines = 0;
      for (int j = 0; j < listLength2; j++) {
        previous.get(j).setMineInstance(temp[j]);
        if (temp[j] == 1) {
          mines++;
        }
      }
      for (int j = 0; j < masterList.size(); j++) {
        // Set the tiles to either have or not have a mine for this instance
        list = masterList.get(j);
        mines2 = mines;
        for (int k = 0; k < list.length; k++) {
          tile = current.get(k);
          tile.setMineInstance(list[k]);
          if (list[k] == 1) {
            mines2++;
          }
        }
        if (mines2 > flagsLeft) {
          valid = false;
        } else {
          // Checks to see if the combination is valid
          valid = isValid(currentTile);
        }
        // If it is valid, then add it to the tile's probabilty to have a mine
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
boolean isValid(Tile tile) {
  int total = 0;
  for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
      int c = tile.getC() + dx;
      int r = tile.getR() + dy;
      if (c >= 0 && r >= 0 && c < columns && r < rows && (tiles[c][r].getMineInstance() == 1 || tiles[c][r].getFlag())) {
        total++;
      }
    }
  }
  if (total != tile.getTileNum()) {
    return false;
  }
  return true;
}

/**
 *method createAllPossibilities - creates all possibilities of mine/not mine.
 *Basically uses binary counting to achieve its task
 *@return all possible combinations, as an integer array
 */
ArrayList<int[]> createAllPossibilities(int size) {
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
void findUncovered() {
  uncoveredTiles.clear();
  for (int i = 0; i < 9; i++) {
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
              good = true;
              tiles[x][y].neighborCovered.add(tiles[c][r]);
            }
          }
        }
        if (good) {
          listLength = uncoveredTiles.size();
          if (listLength == 0) {
            tiles[x][y].section = sec;
          } else {
            newSection = true;
            ArrayList<Tile> list = tiles[x][y].neighborCovered;
            for (int i = 0; i < listLength && newSection; i++) {
              Tile current = uncoveredTiles.get(i);
              int listLength1 = current.neighborCovered.size();
              for (int j = 0; j < listLength1 && newSection; j++) {
                Tile temp = current.neighborCovered.get(j);
                if (list.contains(temp)) {
                  newSection = false;
                  tiles[x][y].section = current.section;
                }
              }
            }
            if (newSection) {
              sec++;
              tiles[x][y].section = sec;
            }
          }
          uncoveredTiles.add(tiles[x][y]);
        } else {
          tiles[x][y].section = 0;
        }
        good = false;
      }
    }
  }
  listLength = uncoveredTiles.size();
  changeTiles(listLength);
  Tile temp;
  for (int i = 0; i < listLength; i++) {
    temp = uncoveredTiles.get(i);
    if (temp.section > 0 && temp.section < 10 && !allSections.get(temp.section - 1).contains(temp)) {
      allSections.get(temp.section - 1).add(temp);
    }
  }
}

void changeTiles(int listLength) {
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
      aSection = a.section;
      for (int j = i; j < listLength && !needsToChange; j++) {
        b = uncoveredTiles.get(j);
        bSection = b.section;
        if (aSection != bSection) {
          ArrayList<Tile> list = a.neighborCovered;
          int listLength1 = b.neighborCovered.size();
          for (int k = 0; k < listLength1 && !needsToChange; k++) {
            Tile temp = b.neighborCovered.get(k);
            if (list.contains(temp)) {
              if (aSection < bSection) {
                smaller = aSection;
                larger = bSection;
              } else {
                smaller = bSection;
                larger = aSection;
              }
              needsToChange = true;
            }
          }
        }
      }
    }
    if (needsToChange) {
      for (int i = 0; i < listLength; i++) {
        if (uncoveredTiles.get(i).section == larger) {
          uncoveredTiles.get(i).section = smaller;
        }
      }
    }
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
 *method calcCoveredTiles - calculates how many covered tiles and flags are next to each tile
 */
void calcCoveredTiles() {
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
void restart() {
  tiles = new Tile[columns][rows];
  createTiles();
  firstClick = true;
  gameOver = false;
  win = false;
  displayChanged = true;
  aiChanged = true;
  timer = 0;
  totalTiles = columns * rows;
  flagsLeft = numOfMines;
  restarted = true;
  tempInfo[0] = String.valueOf(columns);
  tempInfo[1] = String.valueOf(rows);
  tempInfo[2] = String.valueOf(numOfMines);
}

/**
 *method revealEmptyTiles - reveals all adjacent tiles.
 *This method is used when a tile of value 0 is revealed
 *@param x the column of the tile
 *@param y the row of the tile
 */
void revealEmptyTiles(int x, int y) {
  displayChanged = true;
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
