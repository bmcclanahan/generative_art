// The Boid class

class Boid {

  PVector position;
  PVector finalPosition;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  PVector circleColor;
  boolean freeze;
  float attentionRange;
  int stage;
  float sepNeighDist;
  PVector clusterClusterCenter;
  ForceField forceField;
  Float[] musicPowers;
  int frame;

    Boid(float x, float y, PVector circleClr, int imageSize, PVector clusterClusterCtr, ForceField ff, Float [] musicPowersArg) {
    acceleration = new PVector(0, 0);

    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    maxspeed = 2;
    maxforce = 1.0;
    //velocity = new PVector(cos(angle), sin(angle));
    velocity = new PVector(0, 0);
    finalPosition = new PVector(x, y);
    position = new PVector(random(imageSize), random(imageSize));
    r = 2.0;
    circleColor = circleClr;
    freeze = false;
    attentionRange = ((float) (Math.pow(1024.0, 2) + Math.pow(1024.0, 2)));
    stage = 0;
    sepNeighDist = 10;
    clusterClusterCenter = clusterClusterCtr;
    forceField = ff;
    musicPowers = musicPowersArg;
    frame = 0;
  }
  
  void setStage(int stg) {
    stage = stg;
    if(stage == 1){
      sepNeighDist = attentionRange;
    }
  }

  void run(ArrayList<Boid> boids) {
    flock(boids);
    update();
    if(stage < 3){
      borders();
    }
    render();
    frame += 1;
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids) {
    if(stage < 3){ 
      if(stage < 1){ 
        PVector clust = clusterClusterPositionSeek();
        clust.mult(1.0);
        applyForce(clust);
      }
      
      if(stage < 2){
        PVector sep = separate(boids);   // Separation
        PVector ali = align(boids);      // Alignment
        PVector coh = cohesion(boids);   // Cohesion
       
        // Arbitrarily weight these forces
        if(musicPowers[frame] > -300 && stage == 0){
          sep.mult(10.0);
        }
        else {
          sep.mult(1.8);
        }
        ali.mult(1.0);
        if(musicPowers[frame] > -300 && stage == 0){
          coh.mult(0.0);
        }
        else {
          coh.mult(1.0);
        }
        
        
        // Add the force vectors to acceleration
        applyForce(sep);
        applyForce(ali);
        applyForce(coh);
      }
      else if (stage == 2){
        PVector forceFieldForce = forceField.applyTheForce(position);
        forceFieldForce.mult(1.0);
        applyForce(forceFieldForce);
      }
    }
    else {
      PVector finPos = finalPositionSeek();
      finPos.mult(1.0);
      applyForce(finPos);
    } //<>//
  }

  // Method to update position
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    if(stage < 3){
      velocity.limit(maxspeed);
    }
    else {
      velocity.limit(min(maxspeed, PVector.dist(position, finalPosition)));
    }
    position.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }
  
  PVector finalPositionSeek() {
    //println("distance ", PVector.dist(position, finalPosition), position, finalPosition, velocity.mag());
    return seek(finalPosition);
  }
  
  PVector clusterClusterPositionSeek() {
    return seek(clusterClusterCenter);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  void render() {
    // Draw a triangle rotated in the direction of velocity
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up
    fill(circleColor.x, circleColor.y, circleColor.z);
    stroke(circleColor.x, circleColor.y, circleColor.z);
    circle(position.x, position.y, 2);
  }

  // Wraparound
  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = sepNeighDist;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = attentionRange;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = attentionRange;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } 
    else {
      return new PVector(0, 0);
    }
  }
}
