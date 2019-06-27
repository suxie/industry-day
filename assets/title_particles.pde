/*
Particles text effects

Uses particles with a seek behavior to make up a word.
The word is loaded into memory so that each particle can figure out their own position they need to seek.
Inspired by Daniel Shiffman's arrival explantion from The Nature of Code. (natureofcode.com)

Controls:
    - Left-click for a new word.
    - Drag & right-click over particles to interact with them.
    - Press any key to toggle draw styles.

Author:
	Jason Labbe

Site:
	jasonlabbe3d.com
*/


// Global variables
ArrayList<Particle> particles = new ArrayList<Particle>();
//int pixelSteps = 1; // Amount of pixels to skip
int pixelSize = 3;
int pixelInterval = pixelSize + 1;
int percentMissingPixels = 5;
//boolean drawAsPoints = false;
//ArrayList<String> words = new ArrayList<String>();
//int wordIndex = 0;
color bgColor = color(255, 100);
String fontName = "Arial Bold";


class Particle {
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  PVector target = new PVector(0, 0); // <-------------------------------particle target recorded

  float closeEnoughTarget = 50;
  float maxSpeed = 4.0;
  float maxForce = 0.1;
  float particleSize = 5;
  boolean isKilled = false;

  color startColor = color(0);
  color targetColor = color(0);
  float colorWeight = 0;
  float colorBlendRate = 0.025;

  void move() {
    // Check if particle is close enough to its target to slow down
    float proximityMult = 1.0;
    float distance = dist(this.pos.x, this.pos.y, this.target.x, this.target.y);
    if (distance < this.closeEnoughTarget) {
      proximityMult = distance/this.closeEnoughTarget;
    }

    // Add force towards target
    PVector towardsTarget = new PVector(this.target.x, this.target.y);
    towardsTarget.sub(this.pos);
    towardsTarget.normalize();
    towardsTarget.mult(this.maxSpeed*proximityMult);

    PVector steer = new PVector(towardsTarget.x, towardsTarget.y);
    steer.sub(this.vel);
    steer.normalize();
    steer.mult(this.maxForce);
    this.acc.add(steer);

    // Move particle
    this.vel.add(this.acc);
    this.pos.add(this.vel);
    this.acc.mult(0);
  }

  void draw() {
    // Draw particle
    color currentColor = lerpColor(this.startColor, this.targetColor, this.colorWeight);
		
		/*
    if (drawAsPoints) {
      stroke(currentColor);
      point(this.pos.x, this.pos.y);
    } else {
      noStroke();
      fill(currentColor);
      ellipse(this.pos.x, this.pos.y, this.particleSize, this.particleSize);
    }
		*/
		// --------------------------------------- Added Part --------------------------------------- //
			noStroke();
			fill(currentColor);
			rect(this.pos.x, this.pos.y, pixelSize, pixelSize);
		// --------------------------------------- Added Part --------------------------------------- //

    // Blend towards its target color
    if (this.colorWeight < 1.0) {
      this.colorWeight = min(this.colorWeight+this.colorBlendRate, 1.0);
    }
  }

  void kill() {
    if (! this.isKilled) {
      // Set its target outside the scene
      PVector randomPos = generateRandomPos(width/2, height/2, (width+height)/2);
      this.target.x = randomPos.x;
      this.target.y = randomPos.y;

      // Begin blending its color to black
      this.startColor = lerpColor(this.startColor, this.targetColor, this.colorWeight);
      this.targetColor = color(0);
      this.colorWeight = 0;

      this.isKilled = true;
    }
  }
}


// Picks a random position from a point's radius
PVector generateRandomPos(int x, int y, float mag) { // <----------change method to generate in certain position
  PVector randomDir = new PVector(random(0, width), random(0, height));
  
  PVector pos = new PVector(x, y);
  pos.sub(randomDir);
  pos.normalize();
  pos.mult(mag);
  pos.add(x, y);
  
  return pos;
}


// Makes all particles draw the next word
void nextWord(String word) {
  // Draw word in memory
  PGraphics pg = createGraphics(width, height);
  pg.beginDraw();
  pg.fill(0);
  pg.textSize(100);
  pg.textAlign(CENTER);
  PFont font = createFont(fontName, 80);
  pg.textFont(font);
  pg.text(word, width/2, height/2);
  pg.endDraw();
  pg.loadPixels();

  // Next color for all pixels to change to
  color newColor = color(random(0.0, 255.0), random(0.0, 255.0), random(0.0, 255.0));

  int particleCount = particles.size();
  int particleIndex = 0;
	
	// find size of scaled down canvas
		int w = width / pixelInterval;
		int h = height / pixelInterval;

  // Collect coordinates as indexes into an array
  // This is so we can randomly pick them to get a more fluid motion
  ArrayList<Integer> coordsIndexes = new ArrayList<Integer>();
  for (int i = 0; i < w*h; i++) { // add coords of scaled down canvas
    // Get coordinate in scaled down canvas
    int coordIndex = i;
		// Convert scaled down index to its scaled up coordinates
		int x = (int)(coordIndex % w) * pixelInterval;
    int y = (int)(coordIndex / w) * pixelInterval;
		int centercoord = (y+1) * width + (x+1);
		
		// remove random pixels
		float randomNum = random(0, 100);
    
    // Only continue if the pixel is not blank & not a missing pixel
    if (pg.pixels[centercoord] != 0 && randomNum >= percentMissingPixels) {

      Particle newParticle; // <----------------------------------------new particle created
			
			/*
      if (particleIndex < particleCount) {
        // Use a particle that's already on the screen 
        newParticle = particles.get(particleIndex);
        newParticle.isKilled = false;
        particleIndex += 1;
      } else {
			*/
        // Create a new particle
        newParticle = new Particle();
        
        PVector randomPos = generateRandomPos(width/2, height/2, (width+height)/2); // <---uses method to get target pos
        newParticle.pos.x = randomPos.x;
        newParticle.pos.y = randomPos.y;
        
        newParticle.maxSpeed = random(2.0, 5.0);
        newParticle.maxForce = newParticle.maxSpeed*0.025;
        newParticle.particleSize = random(3, 6);
        newParticle.colorBlendRate = random(0.0025, 0.03);
        
        particles.add(newParticle);
      //}
      
      // Blend it from its current color
      newParticle.startColor = lerpColor(newParticle.startColor, newParticle.targetColor, newParticle.colorWeight);
      newParticle.targetColor = newColor;
      newParticle.colorWeight = 0;
      
      // Assign the particle's new target to seek
      newParticle.target.x = x;
      newParticle.target.y = y;
    }
  }

  // Kill off any left over particles
  /*if (particleIndex < particleCount) {
    for (int i = particleIndex; i < particleCount; i++) {
      Particle particle = particles.get(i);
      particle.kill();
    }
  }*/
}


void setup() {
  size(1000, 300);
  background(255);

  nextWord("Future of Safe Autonomy");
}


void draw() {
  // Background & motion blur
  fill(bgColor);
  noStroke();
  rect(0, 0, width*2, height*2);
	//stroke(0);
	//rect(500, 150, 2, 2);
	//noStroke();

  for (int x = particles.size ()-1; x > -1; x--) {
    // Simulate and draw pixels
    Particle particle = particles.get(x);
    particle.move();
    particle.draw();

    // Remove any dead pixels out of bounds
    if (particle.isKilled) {
      if (particle.pos.x < 0 || particle.pos.x > width || particle.pos.y < 0 || particle.pos.y > height) {
        particles.remove(particle);
      }
    }
  }

  // Display control tips
  fill(255-red(bgColor));
  textSize(9);
  //String tipText = "Left-click for a new word.";
  //tipText += "\nDrag right-click over particles to interact with them.";
  //tipText += "\nPress any key to toggle draw styles.";
  //text(tipText, 10, height-40);
}



// Show next word
/*
void mousePressed() {
  if (mouseButton == LEFT) {
    wordIndex += 1;
    if (wordIndex > words.size()-1) { 
      wordIndex = 0;
    }
    nextWord(words.get(wordIndex));
  }
}


// Kill pixels that are in range
void mouseDragged() {
  if (mouseButton == RIGHT) {
    for (Particle particle : particles) {
      if (dist(particle.pos.x, particle.pos.y, mouseX, mouseY) < 50) {
        particle.kill();
      }
    }
  }
}


// Toggle draw modes
void keyPressed() {
  drawAsPoints = (! drawAsPoints);
  if (drawAsPoints) {
    background(0);
    bgColor = color(0, 40);
  } else {
    background(255);
    bgColor = color(255, 100);
  }
}
*/