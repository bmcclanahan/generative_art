// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain

// Floyd Steinberg Dithering
// Edited Video: https://youtu.be/0L2n8Tg2FwI
import java.util.Map;


PImage princess;
int imageSize = 504;
PVector[] colors = new PVector[imageSize * imageSize];
Float [] musicPowers = new Float[1920];
boolean colorsInitialized = false;
float scaler = 2.0;
Table imageTable;
HashMap<Integer, Flock> flocks = new HashMap<Integer, Flock>();
HashMap<Integer, ClusterCluster> clusterClusters = new HashMap<Integer, ClusterCluster>();
int frame = 0;
int stage = 0;
ForceField forceField;
int forceFieldResolution = 2;
int canvasSize = 1024;


int index(int x, int y) {
  return x + y * princess.width;
}

void populateColorArray() {
  princess.loadPixels();
  for (int y = 0; y < princess.height-1; y++) {
    for (int x = 1; x < princess.width-1; x++) {
      color pix = princess.pixels[index(x, y)];
      float oldR = red(pix);
      float oldG = green(pix);
      float oldB = blue(pix);
      int factor = 8;
      //int newR = round(factor * oldR / 255) * (255/factor);
      //int newG = round(factor * oldG / 255) * (255/factor);
      //int newB = round(factor * oldB / 255) * (255/factor);
      int newR = int(oldR);
      int newG = int(oldG);
      int newB = int(oldB);
      princess.pixels[index(x, y)] = color(newR, newG, newB);
      //  println("final position ", x * scaler,y * scaler);
      //}
    }
  }
}

void loadClusterCluster() {
  Table clusterClusterTable = loadTable("data/rgb_cluster_cluster.csv", "header");
  ClusterCluster clusterCluster;
  PVector center = new PVector(512, 512);
  PVector clr;
  for(TableRow row: clusterClusterTable.rows()){
    clr = new PVector(row.getFloat("r"), row.getFloat("g"), row.getFloat("b"));
    clusterCluster = new ClusterCluster(row.getFloat("init_angle") * 2, 450.0, clr, center);
    clusterClusters.put(row.getInt("cluster_cluster"), clusterCluster);
  }
}

void loadMusicPower() {
  Table musicPowerTable = loadTable("data/music_db.csv", "header");
  int index= 0;
  for(TableRow row: musicPowerTable.rows()){
    musicPowers[index] = row.getFloat("db_sum");
    index += 1;
  }
}


void loadTable() {
  imageTable = loadTable("data/rgb_map_clustered_sample.csv", "header");
  PVector position;
  Flock flock;
  for (TableRow row : imageTable.rows()) {
    float x = row.getFloat("x");
    float y = row.getFloat("y");
    int r = row.getInt("r");
    int g = row.getInt("g");
    int b = row.getInt("b");
    int cluster = row.getInt("cluster");
    int clusterCluster = row.getInt("cluster_cluster");
    if(!flocks.containsKey(cluster)){
      position = new PVector(random(imageSize), random(imageSize));
      flocks.put(cluster, new Flock(position));
    }
    flock = flocks.get(cluster);
    flock.addBoid(
      new Boid(x, y, new PVector(r, g, b), imageSize * 2, clusterClusters.get(clusterCluster).position, forceField, musicPowers)
    );
  }
  
  
}

void setup() {
  size(1024, 1024);
  forceField = new ForceField(canvasSize, canvasSize, 32);
  loadClusterCluster();
  loadMusicPower();
  loadTable();
}

void setStage() {
  int lastStage = stage;
  if(frame >= 0 && frame < 700){
    stage = 0; 
  }
  else if(frame < 1000){
    stage = 1;
  }
  else if(frame < 1180){
    stage = 2;
  }
  else if(frame < 1880){
    stage = 3;
  }
  else {
    stage = 4;
  }
  
  if(lastStage != stage){
    println("updating stage ", stage);
    for (Map.Entry clusterCluster : clusterClusters.entrySet()) {
      ((ClusterCluster) clusterCluster.getValue()).setStage(stage);
    }
    for (Map.Entry flock : flocks.entrySet()) {
      ((Flock) flock.getValue()).setStage(stage);
    }
  }
}

void draw() {
  setStage();
  if(stage < 4 )
  {
    background(57);
    frame += 1;
    
    for (Map.Entry clusterCluster : clusterClusters.entrySet()) {
      ((ClusterCluster) clusterCluster.getValue()).run();
    }
    
    for (Map.Entry flock : flocks.entrySet()) {
      ((Flock) flock.getValue()).run();
    }
    
    saveFrame("output/fr_######.png");
    println("saved frame ", frame);
  }
  //forceField.visualizeSig();
};
