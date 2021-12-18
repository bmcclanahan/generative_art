var Environment;
var Circle;
var Rectangle

(function () {
  Circle = function (x, y, radius=200, force=3.0) {
    this.position = createVector(x, y);
    this.radius = radius;
    this.force = force;
  }

  Circle.prototype.getForce = function(boid){
    let distance = p5.Vector.dist(this.position, boid.position);
    let diff;
    if(distance <= this.radius){
      diff = p5.Vector.sub(boid.position, this.position);
      //console.log("distnce is ", distance)
    }
    else{
      diff = createVector(0, 0);
    }
    //console.log("da force is ", diff);
    diff.normalize()
    diff.mult(this.force);
    return diff;
  }

  HollowCircle = function (x, y, radius1=200, radius2=150, innerForce=1, outerForce=1) {
    this.position = createVector(x, y);
    this.radius1 = radius1;
    this.radius2 = radius2;
    this.radiusDiff = this.radius1 - this.radius2;
    this.innerForce = innerForce;
    this.outerForce = outerForce;
  }

  HollowCircle.prototype.updateRadiuses = function(radius1, radius2){
    this.radius1 = radius1;
    this.radius2 = radius2;
  }

  HollowCircle.prototype.getForce = function(boid){
    let distance = p5.Vector.dist(this.position, boid.position);
    let diff, outerForceWeight, innerForceWeight;
    if(distance <= this.radius1){
      outerForceWeight = (distance - this.radius2) / this.radiusDiff;
      innerForceWeight = (this.radius1 -  distance) / this.radiusDiff;
      innerForceDir = p5.Vector.sub(boid.position, this.position).normalize();
      outerForceDir =  p5.Vector.sub(this.position, boid.position).normalize();
      innerForceDir.mult(innerForceWeight);
      innerForceDir.mult(this.innerForce);
      outerForceDir.mult(outerForceWeight);
      outerForceDir.mult(this.outerForce);
      innerForceDir.add(outerForceDir)
      return innerForceDir;
      //console.log("distnce is ", distance)
    }
    else{
      return createVector(0, 0);
    }
  }

  Rectangle = function (x, y, width, height, force=1) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.force = force;
  }

  Rectangle.prototype.getForce = function (boid) {
    var condition = boid.position.x >= this.x && boid.position.x <= (this.x + this.width)
    condition = condition && boid.position.y >= this.y && boid.position.y <= (this.y + this.height)
    let force;
    if(condition) {
      force = createVector(0,1);
    }
    else {
      force = createVector(0, 0);
    }
    force.mult(this.force)
    return force
  }


  Environment = function(forceFields) {
    this.forceFields = forceFields;
  }

  Environment.prototype.getForce = function(boid){
    totalForce = createVector(0, 0);
    this.forceFields.forEach(
      x => {
        totalForce.add(x.getForce(boid));
      }
    )
    return totalForce;
  }

  Environment.prototype.addForce = function(force) {
    this.forceFields.push(force);
  }

})();
