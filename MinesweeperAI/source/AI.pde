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
  ArrayList<int[]> checkTiles(ArrayList<Tile> current, ArrayList<Tile> previous, ArrayList<int[]> previousCombinations, Tile currentTile) {
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
  boolean isValid(Tile tile) {
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
