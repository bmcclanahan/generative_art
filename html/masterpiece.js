let increment = 0.05
let rows, columns
let basePixels = 10
let frameRateDisplay
let timeOffset = 0.1

function setup () {
  createCanvas(windowWidth, windowHeight)
  background(0, 0, 0)
  rows = floor(height / basePixels)
  columns = floor(width / basePixels)
}


function draw () {
  let yOffset = 0
  for (let y = 0; y < rows; y++) {
    let xOffset = 0
    for (let x = 0; x < columns; x++) {
      let randomGrey = map(simplex3(xOffset, yOffset, timeOffset), -1, 1, 0, 1) * 255
      xOffset += increment
      noStroke()
      fill(randomGrey)
      rect(
        x * basePixels,
        y * basePixels,
        basePixels,
        basePixels
      )


    }
    timeOffset += increment * .001
    yOffset += increment
 }
}
