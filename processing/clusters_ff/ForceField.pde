class ForceField {
  
  float [][] forces;
  float [][] sigForces;
  int sigForceDim = 204;
  int w;
  int h;
  int rows;
  int cols;
  int resolution;
  float increment = 0.16;
  float xoff = 0;
  float yoff = 0;
  int arrowLength = 10;

  ForceField(int wid, int heigh, int res) {
    w = wid;
    h = heigh;
    resolution = res;
    cols = wid / resolution;
    rows = heigh / resolution;
    forces = new float[rows][cols];
    sigForces = new float[sigForceDim][sigForceDim];
    initPerlin();
    loadSigFF();
  }
  
  void loadSigFF() {
    Table sigFFTable = loadTable("data/sig_ff_3.csv", "header");
      for(TableRow row: sigFFTable.rows()){
        sigForces[row.getInt("col")][row.getInt("row")] = row.getFloat("angle");
      }
  }

  void initPerlin(){
    noiseDetail(8);
    for (int x = 0; x < cols; x++) {
      xoff += increment;   // Increment xoff 
      yoff = 0.0;   // For every xoff, start yoff at 0
      for (int y = 0; y < rows; y++) {
        yoff += increment; // Increment yoff
        forces[x][y] = noise(xoff, yoff) * 2 * PI * 10;
      }
    }
  }
  
  void visualize() {
    float resolution_offset = 5;
    for (int x = 0; x < cols; x++) {
      for (int y = 0; y < rows; y++) {
        pushMatrix();
        translate(x * resolution + resolution_offset, y * resolution + resolution_offset);
        rotate(forces[x][y]);
        line(0, 0, arrowLength, 0);
        line(arrowLength - 2, 2, arrowLength, 0);
        line(arrowLength - 2, -2, arrowLength, 0);
        popMatrix();
      }
    }
    
  }
  
  void visualizeSig() {
    float resolution_offset = 5;
    for (int x = 0; x < sigForceDim; x++) {
      for (int y = 0; y < sigForceDim; y++) {
        if(sigForces[x][y] >= 0){
          pushMatrix();
          translate(x * 5 + resolution_offset, y * 5 + resolution_offset);
          rotate(sigForces[x][y]);
          line(0, 0, arrowLength, 0);
          line(arrowLength - 5, 5, arrowLength, 0);
          line(arrowLength - 5, -5, arrowLength, 0);
          popMatrix();
        }
      }
    }
    
  }
  
  /*PVector applyTheForce(PVector position){
    int posX, posY;
    posX = int(min(position.x / resolution, cols - 1));
    posY = int(min(position.y / resolution, rows - 1));
    return new PVector(cos(forces[posX][posY]), sin(forces[posX][posY]));
  }*/
  
  PVector applyTheForce(PVector position){
    int posX, posY;
    posX = int(position.x / 5);
    posY = int(position.y / 5);
    
    if(posX >=0 && posY >= 0  && posX < sigForceDim && posY < sigForceDim && sigForces[posX][posY] >= 0){
      float angle = sigForces[posX][posY];
      return new PVector(cos(angle), sin(angle));  
    }
    else{
      return new PVector(0, 0);
    }
    
  }

  void run() {

  }
  

}
