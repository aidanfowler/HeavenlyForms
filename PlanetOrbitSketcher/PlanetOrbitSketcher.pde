import java.util.Map;
import processing.pdf.*;
import java.awt.image.BufferedImage;

//Aidan Fowler July 22nd 2018
//Draws path between two planets, allows visualization of relative positioning throughout the years
//set color, which planets you want (order doesn't matter), how many years should be simulated (will simulate years for whichever planet is further away)
Boolean useColor = false;
Boolean savePdf = false;
Boolean recordFrames = true;
Boolean showText = true;
Boolean showPlanetBackgroundRadius = true;
Boolean showPlanetBackgroundRadiusPDF = false;
Boolean showPlanetOutlines = true;
int simulationYears = 5;
String planet1 = "Pluto";
String planet2 = "Neptune";

//following variables should not be adjusted
HashMap<String, Planet> planets = new HashMap<String,Planet>();
color[] colorArray = {#E100E5,#E400D2,#E400D2,#E300BC,#E300A6,#E20090,#E1007A,#E10064,#E0004F,#DF0039,#DF0024,#DE000F,#DD0500,#DD1A00,#DC2F00,#DB4400,#DB5900,#DA6D00,#DA8100,#D99600,#D8AA00,#D8BE00,#D7D200,#C7D600,#B2D600,#9ED500,#89D400,#74D400,#60D300,#4CD200,#37D200,#23D100,#0FD100,#00D003,#00CF17,#00CF2B,#00CE3E,#00CD52,#00CD65,#00CC78,#00CB8B,#00CB9E,#00CAB0,#00C9C3,#00BCC9,#00A9C8,#0095C8,#0082C7,#006EC6,#005BC6,#0048C5,#0035C4,#0022C4,#0010C3,#0200C2,#1400C2,#2700C1,#3900C0,#4B00C0,#5D00BF,#6E00BF};
float rad = 0.0174533;
int loopCount = 0;
int totalLoops = simulationYears * 60;
String outputFileName;
float scaleFrame;
Planet p1;
Planet p2;

PImage previousFrame;

void setup(){
  size(1000,1000);
  smooth();
  background(0);
  strokeWeight(1);
  PFont font;
  if(savePdf){
    if(useColor){
      outputFileName = planet1+planet2+"-"+simulationYears+"-Color-year.pdf";
    }
    else{
      outputFileName = planet1+planet2+"-"+simulationYears+"-year.pdf";
    }
    beginRecord(PDF, outputFileName); 
    font = createFont("MyanmarSangamMN", 14);
    textFont(font);  
  }
  else{
    font = loadFont("MyanmarSangamMN-14.vlw");
    textFont(font,14);
  }
  loadPlanetData();
  populatePlanetVariables();
  
}

void draw(){
  clearPlanets();
  translate(500,500);
  scale(-1,1);
  if(loopCount <= totalLoops){
    if(!useColor){
      stroke(153);
    }
    else{
      stroke(colorArray[loopCount%60]);
    }
    
    //draw planet line (will be saved)
    float planet1x = cos(((loopCount*p1.degreesPerLine) % 360)*rad) * p1.lineRadius;
    float planet1y = sin(((loopCount*p1.degreesPerLine) % 360)*rad) * p1.lineRadius;
    float planet2x = cos(((loopCount*p2.degreesPerLine) % 360)*rad) * p2.lineRadius;
    float planet2y = sin(((loopCount*p2.degreesPerLine) % 360)*rad) * p2.lineRadius;
    line(planet1x,planet1y,planet2x,planet2y);
   
    if(!savePdf){
      if(showText){
         scale(-1,1);
        if(loopCount == 0){
          stroke(153);
          fill(255);
          text(p1.name + " Orbit: " + nfc(p1.daysInYear/365.25,2) +" Earth Years",-475,415);
          text(p2.name + " Orbit: " + nfc(p2.daysInYear/365.25,2) +" Earth Years",-475,440);
        }
        if((loopCount % 60 == 0 || loopCount == totalLoops) && loopCount <= totalLoops-1){
            fill(0);
            strokeWeight(0);
            stroke(0);
            rect(-480, 445, 275,30);
            strokeWeight(1);
            stroke(153);
            fill(255);
            String year = " Year";
            if(loopCount/60 != 0){
              year = " Years";
            }
            text("Simulation Length: " + ((loopCount / 60)+1) +" " +p1.name + year, -475, 465);
        }
        scale(-1,1);
      }
      if(showPlanetOutlines){
        saveFrame("prevScreen-"+loopCount+".png");
        if(loopCount == totalLoops){
          saveFrame("movieFrame-"+loopCount+".png");
        }
      }
      
      //draw background circles where planets orbit
      if(showPlanetBackgroundRadius){
        noFill();
        strokeWeight(2.5);
        stroke(153);
        ellipse(0, 0, scaleFrame * p1.distanceFromSun,scaleFrame * p1.distanceFromSun);
        ellipse(0, 0, scaleFrame * p2.distanceFromSun,scaleFrame * p2.distanceFromSun);
        strokeWeight(1);
      }
      
      //draw circles where the planets are located and a brighter line that connects them
      if(showPlanetOutlines){
        if(!useColor){
          stroke(0, 255, 255);
          line(planet1x,planet1y,planet2x,planet2y);
        }
        fill(255);
        stroke(255);
        ellipse(planet1x, planet1y, p1.drawDiameter,p1.drawDiameter);
        ellipse(planet2x, planet2y, p2.drawDiameter,p2.drawDiameter);
      }
      
      if(recordFrames && loopCount != totalLoops){
        saveFrame("frames/"+loopCount+".png");
      } 
    }
  }
  loopCount++; 
  
  if(loopCount == totalLoops+1){
    if(showPlanetBackgroundRadiusPDF){
      noFill();
      strokeWeight(2.5);
      stroke(153);
      ellipse(0, 0, scaleFrame * p1.distanceFromSun,scaleFrame * p1.distanceFromSun);
      ellipse(0, 0, scaleFrame * p2.distanceFromSun,scaleFrame * p2.distanceFromSun);
      strokeWeight(1);
    }
    if(savePdf){
      endRecord();
    }
  }
}

void clearPlanets(){
  if(loopCount > 0 && showPlanetOutlines && loopCount <= totalLoops+1 && !savePdf){
    previousFrame = loadImage("prevScreen-"+(loopCount-1)+".png");
    image(previousFrame, 0, 0);
    String fileName = sketchPath("prevScreen-"+(loopCount-1)+".png");
    File file = sketchFile(fileName);
    System.gc();
    file.delete();
  }
}

void populatePlanetVariables(){
  p1 = planets.get(planet1);
  p2 = planets.get(planet2);
  if(p1.daysInYear < p2.daysInYear){
    Planet temp = p1;
    p1 = p2;
    p2 = temp;
  }
  p1.degreesPerLine = 6;
  p2.degreesPerLine = 6 * (p1.daysInYear)/(p2.daysInYear);  
  scaleFrame = 950/max(p1.distanceFromSun, p2.distanceFromSun); 
  p1.lineRadius = scaleFrame * p1.distanceFromSun / 2;
  p2.lineRadius = scaleFrame * p2.distanceFromSun / 2;
  if(p1.planetDiameter > p2.planetDiameter){
    p1.drawDiameter = 30;
    p2.drawDiameter = (p2.planetDiameter / p1.planetDiameter) * 30;
  }
  else{
    p2.drawDiameter = (p1.planetDiameter / p1.planetDiameter) * 30;
    p1.drawDiameter = 30;
  }
}

void loadPlanetData(){
  Planet[] planetsArray = new Planet[10];
  planetsArray[0] = new Planet("Sun",0,0,0,#FFFE54);
  planetsArray[1] = new Planet("Mercury",36,87.96,3031,#70130B);
  planetsArray[2] = new Planet("Venus",67.2,224.68,7521,#47992B);
  planetsArray[3] = new Planet("Earth",93,365.25,7926,#8CB1F9);
  planetsArray[4] = new Planet("Mars",141.6,686.98,4222,#E93323);
  planetsArray[5] = new Planet("Jupiter",483.6,11.862*365.25,88729,#ED7B30);
  planetsArray[6] = new Planet("Saturn",886.7,29.456*365.25,74600,#BDBDBD);
  planetsArray[7] = new Planet("Uranus",1784,84.07*365.25,32600,#357BF6);
  planetsArray[8] = new Planet("Neptune",2794.4,164.81*365.25,30200,#69157F);
  planetsArray[9] = new Planet("Pluto",3674.5,247.7*365.25, 1413,#000000);
  for(int i = 0; i<planetsArray.length;i++){
    planets.put(planetsArray[i].name, planetsArray[i]);
  }
}

class Planet{
  String name;
  //millions of miles
  float distanceFromSun;
  //earth days  
  float daysInYear;
  float lineRadius;
  float degreesPerLine; 
  //miles
  float planetDiameter;
  float drawDiameter;
  color planetColor;
  
  Planet(String planet, float distance, float days, float diameter, color pColor){
    distanceFromSun = distance;
    daysInYear = days;
    name = planet;
    planetDiameter = diameter;
    planetColor = pColor;
  }
}
