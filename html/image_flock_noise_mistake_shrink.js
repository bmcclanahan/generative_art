let flock, alignSlider, cohesionSlider, separationSlider, sizeSlider;
let img;
//slider increments
//let alignIncrement = cohesionIncrement = sizeIncrement = seperationIncrement = 0.05;

//slider offsets
let alignOffset, cohesionOffset, sizeOffset, seperationOffset;
alignOffset = 0;
cohesionOffset = 1;
sizeOffset = 2;
seperationOffset = 3;

let canvasWidth = 600;
let canvasHeight = 600;

let initHeight = canvasHeight;
let initWidth = canvasWidth;

let targetHeight = 50;

let init = false;
let sizeInit = false;
let sizeTransitionComplete = false;
let sizeTransitionTaget;
let sizeTransitionDirection;
let initPosOffset = -1;

Number.prototype.countDecimals = function () {
    if(Math.floor(this.valueOf()) === this.valueOf()) return 0;
    return this.toString().split(".")[1].length || 0;
}

function preload() {
  img = loadImage('images/brown_girl.png');
}

function createSliderWrapper(name, start, end, startVal, increment){
  label = createDiv(`${name} <br>`);
  slider = createSlider(start, end, startVal, increment);
  slider.parent(label);
  return slider
}

function setup() {

  alignSlider = createSliderWrapper('align', 0, 2, 1, 0.1);
  cohesionSlider = createSliderWrapper('cohesion', 0, 2, 1, 0.1);
  separationSlider = createSliderWrapper('seperation', 0, 2, 1.5, 0.1);
  sizeSlider = createSliderWrapper('size', 10, 100, 50, 5);
  noiseSpeedSlider = createSliderWrapper('noise speed', 0, .20, 0.05, 0.01);
  //perlinSlider = createSliderWrapper('perlinSlider', 0, 10, 1, .01);

  background(img);

  //createCanvas(640, 360);
  createCanvas(canvasWidth, canvasHeight);
  createP("Drag the mouse to generate new boids.");
  flock = new Flock();
  flock.addBoid(new Boid(0, 0));
  // Add an initial set of boids into the system
  //for (let i = 0; i < 10; i++) {
  //  let b = new Boid(width / 2,height / 2);
  //  flock.addBoid(b);
  //}
}

function countDecimals() {
    if(Math.floor(this.valueOf()) === this.valueOf()) return 0;
    return this.toString().split(".")[1].length || 0;
}

function updateSlider(slider, sliderOffset){
  let minVal = parseFloat(slider.elt.min)
  let maxVal = parseFloat(slider.elt.max)
  let scale = maxVal - minVal
  let noiseVal = simplex2(sliderOffset, 0) * scale
  let translatedNoiseVal = noiseVal + minVal
  slider.value(translatedNoiseVal)
}

function updateSliders(){
  offsetScaler = 0.1;
  let noiseSpeed = noiseSpeedSlider.value();
  //alignOffset += alignIncrement * offsetScaler;
  alignOffset += noiseSpeed * offsetScaler;
  updateSlider(alignSlider, alignOffset);

  //cohesionOffset += cohesionIncrement * offsetScaler;
  cohesionOffset += noiseSpeed * offsetScaler;
  updateSlider(cohesionSlider, cohesionOffset);

  //sizeOffset += sizeIncrement * offsetScaler;
  if(!sizeInit || sizeTransitionComplete){
    sizeOffset += noiseSpeed * offsetScaler;
    updateSlider(sizeSlider, sizeOffset);
    sizeInit = true;
  }

  //seperationOffset += seperationIncrement * offsetScaler;
  seperationOffset += noiseSpeed * offsetScaler;
  updateSlider(separationSlider, seperationOffset);
}

function draw() {
  updateSliders();
  flock.run();
}

// Add a new boid into the System
function mouseDragged() {
  if(mouseX <= canvasWidth && mouseY <= canvasHeight && mouseX >= 0 && mouseY  >= 0){
    flock.addBoid(new Boid(mouseX, mouseY));
  }
}

// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Flock object
// Does very little, simply manages the array of all the boids

function Flock() {
  // An array for all the boids
  this.boids = []; // Initialize the array
}

Flock.prototype.run = function() {
  for (let i = 0; i < this.boids.length; i++) {
    this.boids[i].run(this.boids);  // Passing the entire list of boids to each boid individually
  }
}

Flock.prototype.addBoid = function(b) {
  this.boids.push(b);
}

// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Boid class
// Methods for Separation, Cohesion, Alignment added

function Boid(x, y) {
  this.acceleration = createVector(0, 0);
  this.velocity = createVector(random(-1, 1), random(-1, 1));
  this.position = createVector(x, y);
  this.r = 3.0;
  this.maxspeed = 3;    // Maximum speed
  this.maxforce = 0.05; // Maximum steering force
}

Boid.prototype.run = function(boids) {
  if(init) {
    this.flock(boids);
    this.update();
    this.borders();
  }
  this.render();
}

Boid.prototype.applyForce = function(force) {
  // We could add mass here if we want A = F / M
  this.acceleration.add(force);
}

// We accumulate a new acceleration each time based on three rules
Boid.prototype.flock = function(boids) {
  let sep = this.separate(boids);   // Separation
  let ali = this.align(boids);      // Alignment
  let coh = this.cohesion(boids);   // Cohesion
  // Arbitrarily weight these forces
  sep.mult(separationSlider.value());
  ali.mult(alignSlider.value());
  coh.mult(cohesionSlider.value());
  // Add the force vectors to acceleration
  this.applyForce(sep);
  this.applyForce(ali);
  this.applyForce(coh);
}

// Method to update location
Boid.prototype.update = function() {
  // Update velocity
  this.velocity.add(this.acceleration);
  // Limit speed
  this.velocity.limit(this.maxspeed);
  this.position.add(this.velocity);
  // Reset accelertion to 0 each cycle
  this.acceleration.mult(0);
}

// A method that calculates and applies a steering force towards a target
// STEER = DESIRED MINUS VELOCITY
Boid.prototype.seek = function(target) {
  let desired = p5.Vector.sub(target,this.position);  // A vector pointing from the location to the target
  // Normalize desired and scale to maximum speed
  desired.normalize();
  desired.mult(this.maxspeed);
  // Steering = Desired minus Velocity
  let steer = p5.Vector.sub(desired,this.velocity);
  steer.limit(this.maxforce);  // Limit to maximum steering force
  return steer;
}

Boid.prototype.render = function() {
  // Draw a triangle rotated in the direction of velocity
  let theta = this.velocity.heading() + radians(90);
  let image_height = sizeSlider.value();
  let offset;
  fill(127);
  stroke(200);
  push();
  if(init){
    translate(this.position.x, this.position.y);
    rotate(theta);
    offset = 0;
    if(!sizeTransitionComplete){
      initHeight += sizeTransitionDirection
      initWidth += sizeTransitionDirection
      if((sizeTransitionDirection > 0 && initHeight >= sizeTransitionTaget) || (sizeTransitionDirection < 0 && initHeight <= sizeTransitionTaget)){
        sizeTransitionComplete = true;
      }
      image_height = initHeight;
    }

  }
  else {
    initHeight -= 1;
    initWidth -= 1;
    image_height = initHeight;
    initPosOffset += 0.5;
    offset = initPosOffset;
    if(initHeight == targetHeight) {
      init = true
      for (let i = 0; i < 10; i++) {
        let b = new Boid(width / 2,height / 2);
        flock.addBoid(b);
      }
      sizeTransitionTaget = sizeSlider.value();
      sizeTransitionDirection = Math.sign(initHeight - sizeTransitionTaget)
    }
  }
  image(img, Math.floor(offset), Math.floor(offset), image_height, image_height);
  pop();
}

// Wraparound
Boid.prototype.borders = function() {
  if (this.position.x < -this.r)  this.position.x = width + this.r;
  if (this.position.y < -this.r)  this.position.y = height + this.r;
  if (this.position.x > width + this.r) this.position.x = -this.r;
  if (this.position.y > height + this.r) this.position.y = -this.r;
}

// Separation
// Method checks for nearby boids and steers away
Boid.prototype.separate = function(boids) {
  let desiredseparation = 25.0;
  let steer = createVector(0, 0);
  let count = 0;
  // For every boid in the system, check if it's too close
  for (let i = 0; i < boids.length; i++) {
    let d = p5.Vector.dist(this.position,boids[i].position);
    // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
    if ((d > 0) && (d < desiredseparation)) {
      // Calculate vector pointing away from neighbor
      let diff = p5.Vector.sub(this.position, boids[i].position);
      diff.normalize();
      diff.div(d);        // Weight by distance
      steer.add(diff);
      count++;            // Keep track of how many
    }
  }
  // Average -- divide by how many
  if (count > 0) {
    steer.div(count);
  }

  // As long as the vector is greater than 0
  if (steer.mag() > 0) {
    // Implement Reynolds: Steering = Desired - Velocity
    steer.normalize();
    steer.mult(this.maxspeed);
    steer.sub(this.velocity);
    steer.limit(this.maxforce);
  }
  return steer;
}

// Alignment
// For every nearby boid in the system, calculate the average velocity
Boid.prototype.align = function(boids) {
  let neighbordist = 50;
  let sum = createVector(0,0);
  let count = 0;
  for (let i = 0; i < boids.length; i++) {
    let d = p5.Vector.dist(this.position,boids[i].position);
    if ((d > 0) && (d < neighbordist)) {
      sum.add(boids[i].velocity);
      count++;
    }
  }
  if (count > 0) {
    sum.div(count);
    sum.normalize();
    sum.mult(this.maxspeed);
    let steer = p5.Vector.sub(sum, this.velocity);
    steer.limit(this.maxforce);
    return steer;
  } else {
    return createVector(0, 0);
  }
}

// Cohesion
// For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
Boid.prototype.cohesion = function(boids) {
  let neighbordist = 50;
  let sum = createVector(0, 0);   // Start with empty vector to accumulate all locations
  let count = 0;
  for (let i = 0; i < boids.length; i++) {
    let d = p5.Vector.dist(this.position,boids[i].position);
    if ((d > 0) && (d < neighbordist)) {
      sum.add(boids[i].position); // Add location
      count++;
    }
  }
  if (count > 0) {
    sum.div(count);
    return this.seek(sum);  // Steer towards the location
  } else {
    return createVector(0, 0);
  }
}