class ClusterCluster {
  ArrayList<PVector> boids; // An ArrayList for all the boids
  float angle;
  float distance;
  PVector rgb;
  PVector position;
  float rotationIncrement;
  int stage;
  PVector center;

  ClusterCluster(float ang, float dst, PVector clr, PVector ctr) {
    angle = ang;
    distance = dst;
    rgb = clr;
    rotationIncrement = PI / (4 * 360.0);
    stage = 0;
    center = ctr;
    position = new PVector(cos(angle) * distance, sin(angle) * distance);
  }
  void updateAngle() {
    angle += rotationIncrement;
    computePosition();
  }

  void run() {
    updateAngle();
    render();
  }
  
  void render() {
    if(stage < 2){
      fill(rgb.x, rgb.y, rgb.z);
      circle(position.x, position.y, 2);
    }
  }
  
  void computePosition() {
    position.set((cos(angle) * distance) + center.x, (sin(angle) * distance) + center.y, 0.0);
  }
  
  void setStage(int stg){
     stage = stg;
  }

}
