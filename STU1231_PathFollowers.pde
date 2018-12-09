//--Path Following 2D with gradient viz using FX2D renderer. Image lumiance is used to multiply against the desired parameters -
//--Flock, Separate and Wander are all active by default, use keys to disable them

//--***This library depends on 2 external libraries (peasy, toxiclibs) which you can download below***
//--Peasy - http://mrfeinberg.com/peasycam/
//--Toxi - https://bitbucket.org/postspectacular/toxiclibs/downloads/

import java.util.List;
import culebra.objects.*;
import culebra.viz.*;
import culebra.data.*;

import toxi.geom.*;
import toxi.color.*;

Creeper creep;
List<Creeper> creeperSet;
PVector loc;
PVector vel;
// ---------------------Behavior Flags-----------------
boolean createTrails = false;
boolean cohFlag = false;
boolean sepFlag = true;
boolean aligFlag = false;
boolean flockFlag = false;
boolean wanderFlag = true;
boolean drawConn = true;
// --------------------OcTree + QTree------------------
QuadTree qtree;
boolean createQTree = false;
boolean showQTree = false;
// -------------------Spawn Stuff----------------------
boolean spawnEdge = false;
// --------------------Path Stuff--------------------
Path tempPath;
ArrayList<Path> pathList;
int pathCount = 5;
boolean drawPaths = true;
float scalarProjectionDist;
float pathRadius = 25.0f;
List<ArrayList<PVector>> cummPathPts;
// -------------------Environ Stuff--------------------
int creepCount = 500;
PImage img0, img1, img2;
boolean showMap = false;
// -------------------Children Stuff--------------------
boolean triggerBabies;
ArrayList<PVector> childSpawners;
ArrayList childSpawnType;
// -----------------------STU1231 Stuff-----------------------
PImage koto, hamamatsu, hokota;//load the image file of the particular location
Path tempKotoPath1;//not sure if I'm going to need all of these temp paths, but just gonna do it anyway...
Path tempKotoPath2;
Path tempKotoPath3;
Path tempKotoPath4;
Path tempKotoPath5;
Path tempKotoPath6;
Path tempKotoPath7;
Path tempKotoPath8;
Path tempKotoPath9;

int timeCount;

// -----------------------Setup-----------------------
public void setup() {
  //size(1400, 800, FX2D);
  //size(4001, 2251, FX2D);
  size(1280, 720, FX2D);
  //smooth();
  background(0);
  timeCount = 0;

  this.img0 = loadImage("LULZ.png");
  this.img1 = loadImage("map_B.jpg");
  this.img2 = loadImage("SI.png");
  this.koto = loadImage("analysis_01.jpg");
  this.hamamatsu = loadImage("analysis_02.jpg");
  this.hokota = loadImage("analysis_03.jpg");

  this.childSpawners = new ArrayList<PVector>();
  this.childSpawnType = new ArrayList();
  this.cummPathPts = new ArrayList<ArrayList<PVector>>();

  this.creeperSet = new ArrayList<Creeper>();
  scalarProjectionDist = 50.0f;
  pathList = new ArrayList<Path>();

  newKotoPath();
  for (int pth = 0; pth < this.pathCount; pth++) {
    //newPath();
  }

  for (int i = 0; i < creepCount; i++) {
    if (this.spawnEdge) {
      this.loc = new PVector(0, random(height), 0);
      this.vel = new PVector(1, 0, 0);
    } else {
      this.loc = new PVector(random(0, width), random(0, height), 0);
      this.vel = new PVector(random(-1.5f, 1.5f), random(-1.5f, 1.5f), 0);
    }
    this.creep = new Creeper(loc, vel, true, false, this);
    this.creeperSet.add(this.creep);
  }
}
// -----------------------Draw-----------------------
public void draw() {
  timeCount++;
  background(0);
  image(koto, 0, 0);
  // -----------------------PATH STUFF-----------------------
  if (this.pathList != null) {
    for (Path pths : pathList) {
      pths.setPathRadius(pathRadius);
      if (drawPaths) {

        stroke(175, 0, 0, 50);
        strokeWeight(pths.getPathRadius() * 2);
        noFill();
        beginShape();
        for (PVector v : pths.getPathPoints()) {
          vertex(v.x, v.y);
        }
        endShape();

        // Draw thin line for center of path
        stroke(255);
        strokeWeight(1);
        noFill();
        beginShape();
        for (PVector v : pths.getPathPoints()) {
          vertex(v.x, v.y);
        }
        endShape();
      }
    }
  }
  // -----------------------------------------------------------------
  // -----------------------CREEPER AGENTS---------------------------
  // -----------------------------------------------------------------
  for (Creeper c : this.creeperSet) {
    c.setMoveAttributes(2.0f, 0.2f, 1.5f);
    if (c.behavior.isSeparateActive() && c.behavior.isInstanceable() && this.sepFlag) {
      c.behavior.creeperSeparate(5.0f, creeperSet);
    }
    c.behavior.multiShapeTrackerMapBabyMaker(this.cummPathPts, 1000, 50, pathRadius, triggerBabies, 2, true, this.childSpawners, this.childSpawnType, this.img1, true, true, false, 0.1f, 1.0f);
    this.childSpawners = c.behavior.getChildStartPositions();
    this.childSpawnType = c.behavior.getChildSpawnType();    

    if (this.aligFlag) {
      c.behavior.creeperAlign(30.0f, 0.045f, creeperSet);
    }
    if (this.cohFlag) {
      c.behavior.creeperCohesion(30.0f, 0.045f, creeperSet);
    }
    if (this.wanderFlag) {
      float change = 100;
      c.behavior.wander2D(true, false, change, 60.0f, 60.0f);
      //c.behavior.superWander2D(change, 10.0f, 20.0f, 6.0f);
    }
    if (this.flockFlag) {
      if (this.createQTree) {
        c.behavior.creeperflock2DTree(80.0f, 0.2f, 0.09f, 0.045f, creeperSet, Data.getQuadtree(), Data.getQTNodes(), this.drawConn);
      } else {
        c.behavior.creeperflock2D(30.0f, 0.14f, 0.09f, 0.045f, creeperSet, this.drawConn);
      }
    }      
    c.bounce(width, height);
    c.move(6, 100);
    if (createTrails) {
      if (!(c instanceof BabyCreeper)) {  
        // --------Draw trails with color and with gradient--------
        float colorA[] = new float[] { 255f, 0f, 0f };
        c.viz.drawTrails(c.getTrailPoints(), false,100, colorA, 255.0f, 1.0f,true);
      } else if (c instanceof BabyCreeper) {
        if (((BabyCreeper)c).getType() == "a") {
          float colorA[] = new float[] { 0.0f, 255.0f, 0.0f };
          c.viz.drawTrails(c.getTrailPoints(), false,100, colorA, 255.0f, 1.0f,true);
        } else {
          float colorA[] = new float[] { 0.0f, 0.0f, 255.0f };
          c.viz.drawTrails(c.getTrailPoints(), false,100, colorA, 255.0f, 1.0f,true);
        }
      }
    }  
    pushStyle();
    stroke(255);
    strokeWeight(4);
    ellipse(c.getLocation().x, c.getLocation().y, 2, 2);
    popStyle();
    
    
    
    if (this.showMap) {
      image(img1, 0, 0);
      tint(255, 120);
    }

    //image(img2, width-290, height-85);
    //image(img0, 0, height-105);
    textSize(20);
    
    //text("Framerate: " + (frameRate), 80, height - 6);
    text("Time Count:" + (timeCount), 10, height -6);
  }

  if (this.childSpawners.size() > 0) {
    newDude();
    this.childSpawners = new ArrayList<PVector>();
    this.childSpawnType = new ArrayList();
  }  
  surface.setSize(width, height);
}
// ---------------------------------------Children Creation-----------------------------------
void newDude() {
  int babyCount = 0;
  for (PVector px : this.childSpawners) {
    PVector speed;
    if (this.spawnEdge) {
      speed = new PVector(1, 0, 0);
    } else {
      speed = new PVector(random(-1, 1), random(-1, 1), 0);
    }
    Creeper a;
    if ((int) this.childSpawnType.get(babyCount) % 2 == 0) {
      a = new BabyCreeper(new PVector(px.x, px.y, px.z), speed, false, "a", false, this);
      this.creeperSet.add(a);
    } else {
      a = new BabyCreeper(new PVector(px.x, px.y, px.z), speed, false, "b", false, this);
      this.creeperSet.add(a);
    }
    babyCount++;
  }
}
// ------------------------Create Paths----------------------------------
public void keyPressed() {
  if (key == 'R')
    setup();
  if (key == 'T')this.createTrails = !this.createTrails;
  if (key == 'D')drawPaths = !drawPaths;
  if (key == 'C')this.cohFlag = !this.cohFlag;
  if (key == 'A')this.aligFlag = !this.aligFlag;
  if (key == 'S')this.sepFlag = !this.sepFlag;
  if (key == 'F')this.flockFlag = !this.flockFlag;
  if (key == 'W')this.wanderFlag = !this.wanderFlag;  
  if (key == '1')this.drawConn = !this.drawConn;
  if (key == 'B') this.triggerBabies = !this.triggerBabies;
  if  (key == 'E') this.spawnEdge = !this.spawnEdge;
  if (key == 'M') this.showMap = !this.showMap;  
}
// ---------------------------------------Create
// StaticPaths---------------------------------
void newPath() {
  ArrayList<PVector>pathPtList = new ArrayList<PVector>();
  this.tempPath = new Path();
  this.tempPath.addPoint(random(30, 300), random(height / 4, height), 0);
  this.tempPath.addPoint(random(101, width / 2), random(0, height), 0);
  this.tempPath.addPoint(random(width / 2, width), random(0, height), 0);
  this.tempPath.addPoint(random(width - 100, width), height / 2, 0);
  pathPtList.addAll(this.tempPath.getPathPoints());
  this.cummPathPts.add(pathPtList);
  this.pathList.add(this.tempPath);
}

// ---------------------------------------Create
// Site Specific(Koto) Paths---------------------------------
void newKotoPath(){
  
  //for path 1
  ArrayList<PVector>pathPtList1 = new ArrayList<PVector>();
  this.tempKotoPath1 = new Path();
  this.tempKotoPath1.addPoint(94, 0, 0);
  this.tempKotoPath1.addPoint(100, 123, 0);
  this.tempKotoPath1.addPoint(90, 196, 0);
  this.tempKotoPath1.addPoint(90, 442, 0);
  this.tempKotoPath1.addPoint(94, 525, 0);
  this.tempKotoPath1.addPoint(120, 607, 0);
  this.tempKotoPath1.addPoint(220, 624, 0);
  this.tempKotoPath1.addPoint(617, 671, 0);
  pathPtList1.addAll(this.tempKotoPath1.getPathPoints());
  this.cummPathPts.add(pathPtList1);
  this.pathList.add(this.tempKotoPath1);
  
  //for path 2
  ArrayList<PVector>pathPtList2 = new ArrayList<PVector>();
  this.tempKotoPath2 = new Path();
  this.tempKotoPath2.addPoint(958, 0, 0);
  this.tempKotoPath2.addPoint(961, 38, 0);
  this.tempKotoPath2.addPoint(980, 149, 0);
  this.tempKotoPath2.addPoint(1002, 215, 0);
  this.tempKotoPath2.addPoint(1009, 316, 0);
  this.tempKotoPath2.addPoint(1049, 490, 0);
  this.tempKotoPath2.addPoint(1098, 720, 0);
  pathPtList2.addAll(this.tempKotoPath2.getPathPoints());
  this.cummPathPts.add(pathPtList2);
  this.pathList.add(this.tempKotoPath2);
  
  //for path 3
  ArrayList<PVector>pathPtList3 = new ArrayList<PVector>();
  this.tempKotoPath3 = new Path();
  this.tempKotoPath3.addPoint(552, 0, 0);
  this.tempKotoPath3.addPoint(564, 131, 0);
  this.tempKotoPath3.addPoint(573, 308, 0);
  this.tempKotoPath3.addPoint(586, 467, 0);
  this.tempKotoPath3.addPoint(614, 671, 0);
  this.tempKotoPath3.addPoint(620, 720, 0);
  pathPtList3.addAll(this.tempKotoPath3.getPathPoints());
  this.cummPathPts.add(pathPtList3);
  this.pathList.add(this.tempKotoPath3);
  
  //for path 4
  ArrayList<PVector>pathPtList4 = new ArrayList<PVector>();
  this.tempKotoPath4 = new Path();
  this.tempKotoPath4.addPoint(624, 687, 9);
  this.tempKotoPath4.addPoint(730, 692, 0);
  this.tempKotoPath4.addPoint(882, 706, 0);
  this.tempKotoPath4.addPoint(998, 720, 0);
  pathPtList4.addAll(this.tempKotoPath4.getPathPoints());
  this.cummPathPts.add(pathPtList4);
  this.pathList.add(this.tempKotoPath4);
  
  //for path 5
  ArrayList<PVector>pathPtList5 = new ArrayList<PVector>();
  this.tempKotoPath5 = new Path();
  this.tempKotoPath5.addPoint(998, 215, 0);
  this.tempKotoPath5.addPoint(1129, 218, 0);
  this.tempKotoPath5.addPoint(1280, 235, 0);
  pathPtList5.addAll(this.tempKotoPath5.getPathPoints());
  this.cummPathPts.add(pathPtList5);
  this.pathList.add(this.tempKotoPath5);
  
  //for path 6
  ArrayList<PVector>pathPtList6 = new ArrayList<PVector>();
  this.tempKotoPath6 = new Path();
  this.tempKotoPath6.addPoint(552, 39, 0);
  this.tempKotoPath6.addPoint(887, 44, 0);
  this.tempKotoPath6.addPoint(960, 34, 0);
  this.tempKotoPath6.addPoint(1146, 14, 0);
  pathPtList6.addAll(this.tempKotoPath6.getPathPoints());
  this.cummPathPts.add(pathPtList6);
  this.pathList.add(this.tempKotoPath6);
  
  //for path 7
  ArrayList<PVector>pathPtList7 = new ArrayList<PVector>();
  this.tempKotoPath7 = new Path();
  this.tempKotoPath7.addPoint(0, 114, 0);
  this.tempKotoPath7.addPoint(99, 121, 0);
  this.tempKotoPath7.addPoint(564, 131, 0);
  this.tempKotoPath7.addPoint(670, 137, 0);
  this.tempKotoPath7.addPoint(976, 149, 0);
  pathPtList7.addAll(this.tempKotoPath7.getPathPoints());
  this.cummPathPts.add(pathPtList7);
  this.pathList.add(this.tempKotoPath7);
  
  //for path 8
  ArrayList<PVector>pathPtList8 = new ArrayList<PVector>();
  this.tempKotoPath8 = new Path();
  this.tempKotoPath8.addPoint(90, 442, 0);
  this.tempKotoPath8.addPoint(586, 468, 0);
  this.tempKotoPath8.addPoint(1046, 489, 0);
  pathPtList8.addAll(this.tempKotoPath8.getPathPoints());
  this.cummPathPts.add(pathPtList8);
  this.pathList.add(this.tempKotoPath8);
  
  //for path 9
  ArrayList<PVector>pathPtList9 = new ArrayList<PVector>();
  this.tempKotoPath9 = new Path();
  this.tempKotoPath9.addPoint(90, 442, 0);
  pathPtList9.addAll(this.tempKotoPath9.getPathPoints());
  this.cummPathPts.add(pathPtList9);
  this.pathList.add(this.tempKotoPath9);
}
