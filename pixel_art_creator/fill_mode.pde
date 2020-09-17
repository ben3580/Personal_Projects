class FillMode{
  int r;
  int g;
  int b;
  ArrayList<int[]> checked;
  ArrayList<int[]> needToCheck;
  
  FillMode(){
    r = 0;
    g = 0;
    b = 0;
    checked = new ArrayList<int[]>();
    needToCheck = new ArrayList<int[]>();
  }
  
  void setColor(int r, int g, int b){
    this.r = r;
    this.g = g;
    this.b = b;
  }
  
  void findNeighbours(int x, int y){
    int[][] potentialNeigbours = {{0,1},{1,0},{0,-1},{-1,0}};
    for(int i = 0; i < 4; i++){
      int tempx = x + potentialNeigbours[i][0];
      int tempy = y + potentialNeigbours[i][1];
      if(tempx < 0 || tempx > PIXELSX-1 || tempy < 0 || tempy > PIXELSY-1){
        continue;
      }
      else if(!valid(tempx, tempy)){
        continue;
      }
      else{
        boolean flag = false;
        for(int j = 0; j < checked.size(); j++){
          if(checked.get(j)[0] == tempx && checked.get(j)[1] == tempy){
            flag = true;
          }
        }
        if(!flag){
          int[] temp = {tempx, tempy};
          needToCheck.add(temp);
        }
      }
    }
  }
  
  boolean valid(int x, int y){
    return pixelArray[x][y][0] == r && pixelArray[x][y][1] == g && pixelArray[x][y][2] == b;
  }
  
  ArrayList<int[]> fillColor(int x, int y){
    int[] temp = {x,y};
    checked.add(temp);
    for(int i = needToCheck.size()-1; i >= 0; i--){
      if(needToCheck.get(i)[0] == x && needToCheck.get(i)[1] == y){
        needToCheck.remove(i);
      }
    }
    this.findNeighbours(x, y);
    if(needToCheck.size() > 0){
      this.fillColor(needToCheck.get(0)[0], needToCheck.get(0)[1]);
    }
    return checked;
  }
  
  void clearInfo(){
    checked.clear();
    needToCheck.clear();
  }
  
}
