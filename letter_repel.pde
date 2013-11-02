import geomerative.*;
import org.apache.batik.svggen.font.table.*;
import org.apache.batik.svggen.font.*;
import controlP5.*;

ControlP5 cp5;

int sValue = 15;
int dValue = 1;
int hotRadius = width;
float force = .1;
String[] shapes = {
  "d.svg", 
  "i.svg", 
  "s.svg",
  "p.svg",
  "l.svg",
  "a.svg",
  "c.svg",
  "e.svg"
};
int progress = 0;
int lastTime = 0;
int timeDelay = 3000;
ArrayList<PVector> dots;

PVector centerPoint;
RShape s;
RShape sprime;

void placeShape() {
  s = RG.loadShape(shapes[progress]);
  s.scale(0.5);
  s.translate((width/2) - (s.width/4), (height/2) - (s.height/4));
  if (progress < (shapes.length - 1)) {
    progress ++;
  } 
  else {
    progress = 0;
  }
}

void setup() {
  RG.init(this);
  RG.ignoreStyles(true);
  placeShape();
  noStroke();
  size(1280, 720); 
  smooth();
  background(#333333);
  
  frameRate(30);

  centerPoint = new PVector(width/2, height/2);
  dots = new ArrayList<PVector>();

  cp5 = new ControlP5(this);
  cp5.addSlider("sValue")
    .setPosition(50, 25)
      .setRange(10, 100);
  cp5.addSlider("dValue")
    .setPosition(200, 25)
      .setRange(1, 5);
  cp5.addSlider("hotRadius")
    .setPosition(350, 25)
      .setRange(0, width)
        .setValue(0); 
  cp5.addSlider("force")
    .setPosition(500, 25)
      .setRange(0, 1);

  findPoints(sValue, dValue);
}

void findPoints(int s, int d) {
  dots.clear();
  int box = s*2;
  int xpos = 0;
  int ypos = 0;

  while (ypos < height) {

    PVector curpos = new PVector(xpos + (s*.5), ypos + (s*.5));
    dots.add(curpos);

    if (xpos+box < width) {
      xpos += box;
    } 
    else {
      xpos = 0;
      ypos += box;
    }
  }
}



void makeGrid(int d, RShape shape, int hotR) {

  for (int i = 0; i <= (dots.size()-1); i++) {
    //Cache current value from dots
    PVector current = dots.get(i);
    PVector v;
    // vector offset of current point from center point
    v = PVector.sub(current, centerPoint);
    PVector edgePoint = dots.get(i);
    PVector newPosition = dots.get(i);

    // If the current point is inside of the shape
    if (shape.contains(current.x, current.y)) {

      // Calculate edgepoint
      edgePoint = new PVector(v.x, v.y);
      edgePoint.normalize();
      
      while (shape.contains((edgePoint.x + centerPoint.x), (edgePoint.y + centerPoint.y))) {
        edgePoint.mult(1.1);
        println(edgePoint);
      }
      
      edgePoint.x = edgePoint.x + centerPoint.x;
      edgePoint.y = edgePoint.y + centerPoint.y;
      
      println("EDGEFIND");

      // Distance between current point and edge point
      float offset = dist(current.x, current.y, edgePoint.x, edgePoint.y);
      println(offset);
      float radius = dist(centerPoint.x, centerPoint.y, edgePoint.x, edgePoint.y);
      println(radius);
      float ratio = (radius - offset)*force;
      println(ratio);
      v.normalize();
      v.mult(ratio);
      newPosition = PVector.add(v, current);
    }

    fill(#FFFFFF);
    ellipse(newPosition.x, newPosition.y, d, d);
    dots.set(i, newPosition);
  }
}

void mouseReleased() {
  findPoints(sValue, dValue);
}

void draw() {
  background(#333333);
  fill(#333333);
  s.draw();//, (width/2) - 100, (height/2) - 100, 200, 200);
  makeGrid(dValue, s, hotRadius);

  if (millis()-lastTime > timeDelay) {
    findPoints(sValue, dValue);
    placeShape();
    lastTime = millis();
  }
}

