import java.util.Calendar;
class BackgroundTimer{
  private long timeStart;
  private long timeEnd;
  private int timeBetween;
  public BackgroundTimer(){
    
  }
  public void startTimer(){
    Calendar start = Calendar.getInstance(); 
    this.timeStart = start.getTimeInMillis();
  }
  public void endTimer(){
    Calendar end = Calendar.getInstance(); 
    this.timeEnd = end.getTimeInMillis();
  }
  public int getTime(){
    timeBetween = (int)(timeEnd - timeStart);
    return timeBetween;
  }
}
