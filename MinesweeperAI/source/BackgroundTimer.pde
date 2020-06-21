import java.util.Calendar;
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
