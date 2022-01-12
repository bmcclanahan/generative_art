class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids
  PVector position;

  Flock(PVector pos) {
    position = pos;
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }

  

  void run() {
    for (Boid b : boids) {
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }
  
  void setStage(int stage){
    for (Boid b : boids) {
      b.setStage(stage);  // Passing the entire list of boids to each boid individually
    }
  }

  void addBoid(Boid b) {
    boids.add(b);
  }

}
