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
  void displayTile() {
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

  void displayProbability() {
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

  void displayAllMines() {
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

  void displayFlag() {
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

  void displayCross() {
    stroke(200, 0, 0);
    strokeWeight(4);
    line(this.x + 5, this.y + 5, this.x + 35, this.y + 35);
    line(this.x + 5, this.y + 35, this.x + 35, this.y + 5);
  }

  void displayNum() {
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
  int getC() {
    return this.column;
  }

  int getR() {
    return this.row;
  }
  
  boolean getMine() {
    return this.mine;
  }
  
  boolean getFlag() {
    return this.flag;
  }

  boolean getRevealed() {
    return this.revealed;
  }
  
  boolean getZeroRevealed(){
    return this.zeroRevealed;
  }
  
  int getTileNum() {
    return this.tileNum;
  }
  
  int getInstance() {
    return this.totalInstance;
  }
  
  float getProbability() {
    return this.probability;
  }
  
  int getMineInstance() {
    return this.mineThisInstance;
  }
  
  int getSection(){
    return this.section;
  }
  
  // Mutators
  void setMine(boolean newMine) {
    this.mine = newMine;
  }

  void setFlag(boolean newFlag) {
    this.flag = newFlag;
  }

  void reveal() {
    this.revealed = true;
  }
  
  void setZeroRevealed(boolean newZeroRevealed){
    this.zeroRevealed = newZeroRevealed;
  }

  void setTileNum(int newTileNum) {
    this.tileNum = newTileNum;
  }

  void setInstance(int newInstance) {
    this.totalInstance = newInstance;
  }

  void addInstance() {
    this.totalInstance++;
  }

  void setProbability(float newProbability) {
    this.probability = newProbability;
  }

  void setMineInstance(int newMineThisInstance) {
    this.mineThisInstance = newMineThisInstance;
  }
  
  void setSection(int newSection){
    this.section = newSection;
  }

  String toString() {
    return "column: " + (column+1) + " row: " + (row+1);
  }
}
