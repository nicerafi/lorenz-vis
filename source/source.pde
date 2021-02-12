
// Interactive Lorenz system visualisation //


// Uses peasycam and controlP5 Libraries //
// peasycam - http://mrfeinberg.com/peasycam/ //
// controlP5 - http://www.sojamo.de/libraries/controlP5/ //
import peasy.*;
import controlP5.*;

//Initialise ArrayList which will hold coordinates for each point created from the system.//
ArrayList<PVector> points = new ArrayList<PVector>();
ControlP5 cp5;
PeasyCam cam;

//Created separate values for sliders as their values need to be changed when preset buttons are pressed.//
controlP5.Slider sigma_slider;
controlP5.Slider rho_slider;
controlP5.Slider beta_slider;

// Set our global variables //

// Initialise our x, y and z values for equations to carry on giving values. //
float x = 0.0;
float y = 1.0;
float z = 1.05;
float t = 0;
float t_max = 50; // Max t value the simulation will run for 

// Initial values of sigma, rho and beta, which are constant in the system. //
float sigma = 10;
float rho = 28;
float beta = 8.0/3.0;

// Temp values which are adjusted by the sliders are initially set to their original values. //
float temp_sigma = sigma;
float temp_rho = rho;
float temp_beta = beta;

// Boolean values used for my toggle buttons. //
boolean stop_state = false;
boolean framerate_state = false;


void setup() {
  size(1280, 720, P3D);

  // Initialising our ControlP5 object and setting some values for my buttons and sliders. //
  cp5 = new ControlP5(this);

  // Font acquired from Google Fonts - https://fonts.google.com/specimen/Roboto //
  PFont pfont = createFont("data/Roboto-Bold.ttf", 20); 
  ControlFont font = new ControlFont(pfont, 10);
  cp5.setFont(font);
  cp5.setColorBackground(color(#242e33));
  cp5.setColorForeground(color(#3f515a));

  // Create an array of images which will be used for each button //
  PImage[] buttons = {loadImage("data/pause.png"), loadImage("data/play.png"), loadImage("data/reset.png"), loadImage("data/normal_mode.png"), loadImage("data/quick_mode.png"), loadImage("data/preset_1.png"), loadImage("data/preset_2.png"), loadImage("data/preset_3.png"), loadImage("data/preset_4.png"), loadImage("data/update.png")};

  // Each image has a original resolution of 1000x1000, so I resize all the images to 100x100 //
  for (int i = 0; i < buttons.length; i++) {
    buttons[i].resize(100, 100);
  }

  // Creates playback button //
  cp5.addButton("quick_mode").setPosition(980, 620).setImage(buttons[4]).setSize(100, 100);
  cp5.addButton("normal_mode").setPosition(880, 620).setImage(buttons[3]).setSize(100, 100);
  cp5.addButton("reset").setPosition(1080, 620).setSize(50, 50).setImage(buttons[2]).setSize(100, 100);
  cp5.addToggle("stop_state").setValue(false).setPosition(1180, 620).setSize(100, 100).setImages(buttons[0], buttons[1]);

  // Creates buttons and sliders for values //
  sigma_slider = cp5.addSlider("temp_sigma").setPosition(105, 0).setRange(1, 100).setLabel("Sigma").setSize(150, 20);
  rho_slider = cp5.addSlider("temp_rho").setPosition(105, 40).setRange(1, 100).setLabel("Rho").setSize(150, 20);
  beta_slider = cp5.addSlider("temp_beta").setPosition(105, 80).setRange(1, 100).setLabel("Beta").setSize(150, 20);
  cp5.addButton("update").setPosition(0, 0).setSize(100, 100).setImage(buttons[9]);

  // Creates buttons for our different presets //
  cp5.addButton("preset_1").setPosition(880, 0).setSize(100, 100).setImage(buttons[5]);
  cp5.addButton("preset_2").setPosition(980, 0).setSize(100, 100).setImage(buttons[6]);
  cp5.addButton("preset_3").setPosition(1080, 0).setSize(100, 100).setImage(buttons[7]);
  cp5.addButton("preset_4").setPosition(1180, 0).setSize(100, 100).setImage(buttons[8]);

  // Initialize our camera //
  cam = new PeasyCam(this, 2000);
  cp5.setAutoDraw(false); // Set as false so the buttons will only be drawn in the GUI.

  // Load my desired camera settings //
  camSettings();
}

void draw() {
  background(0);

  // Runs method which starts the Lorenz system of differential equations. //
  Lorenz();

  // Loops and draws a continuous line which connects all points in the ArrayList.//
  scale(5);
  noFill();
  float color_t = 0;
  beginShape();
  for (int i = 0; i < points.size(); i++) {
    colorMode(RGB);
    strokeWeight(0.2);
    stroke(color(map_color(color_t)));
    vertex(points.get(i).x, points.get(i).y, points.get(i).z);
    color_t += 0.005; // Increment color_t for each frame drawn
  }
  endShape();
  gui();// Draw GUI
}

/**
 Draws the GUI for our visualisation
 */
void gui() {  
  cam.beginHUD(); // HUD allows us to draw 2d objects which won't be affected the cameras movement.
  cp5.draw(); 
  info();
  cam.endHUD();
}

/**
 Resets system by setting values of x, y, z and t back to 0 and clears the ArrayList of points.
 Also resets the cameras location.
 */
public void reset() {
  x = 0.0;
  y = 1.0;
  z = 1.05;
  t = 0;
  points.clear();
  cam.reset();
  cam.setDistance(500);
}


/**
 Sets framerate to 500 (if PC can handle it) to speed up the drawing of the system.
 Increases CPU usage!
 */
public void quick_mode() {
  frameRate(500);
}

/**
 Sets framerate back to 60
 */
public void normal_mode() {
  frameRate(60);
}


/**
 Updates the values of our constants and resets and draws the outcome of the system with the users desired constant values.
 */
public void update() {
  sigma = temp_sigma;
  rho = temp_rho;
  beta = temp_beta;
  sigma_slider.setValue(temp_sigma);
  rho_slider.setValue(temp_rho);
  beta_slider.setValue(temp_beta);
  reset();
}

/**
 Similar to update() but as our presets only change the values of Rho we only change that value.
 */
public void preset_update(float new_rho) {
  rho = new_rho;
  sigma = 10.0;
  beta = 8.0/3.0;
  rho_slider.setValue(rho);
  sigma_slider.setValue(sigma);
  beta_slider.setValue(beta);
  reset();
}

/**
 Runs system with preset values of Rho.
 */
public void preset_1() {
  preset_update(28);
}

public void preset_2() {
  preset_update(14);
}

public void preset_3() {
  preset_update(13);
}

public void preset_4() {
  preset_update(15);
}

/**
 Creates and draws our titles and text which show current values of framerate, x, y ,z and t for each frame which is drawn
 */
public void info() {
  //text("PRESETS", 1030, 20);
  //text("SETTINGS", 40, 20);
  //text("PLAYBACK", 780, 680);
  rectMode(CORNER);
  fill(#242e33);
  strokeWeight(2);
  stroke(255);
  rect(0, 580, 200, 720-580);
  fill(-1);
  textSize(20);
  text("INFO", 75, height - 115);
  text("Value of x: "+ nf(x, 0, 3), 15, height - 10 );
  text("Value of y: "+ nf(y, 0, 3), 15, height - 30);
  text("Value of z: "+ nf(z, 0, 3), 15, height - 50);
  text("Value of t: "+ nf(t, 0, 3), 15, height - 70);
  text("Framerate: "+ nf(frameRate, 0, 3), 15, height - 90);
}

/**
 Calculates and returns a colour between two predetermined colours based on the current value of t, which is mapped to be turned into a float between 0 and 1 to be compatible with lerpColor().
 */
int map_color(float t) {
  return lerpColor(#F56200, #FFFFFF, map(t, 0, t_max, 0, 1));
}

/**
 Runs the Lorenz system of differential equations which change the values of x, y, z and t based on the rate of change of these values.
 */
public void Lorenz() {
  //For a accurate representation of what the system will look like we must use a small value of t to get the value of each point//
  float dt = 0.005;
  float dx = (sigma * (y - x))*dt;
  float dy = (x * (rho - z) - y)*dt;
  float dz = (x * y - beta * z)*dt;

  // Checks whether the pause button has been pressed or our current value of t is LEQ then our chosen max value of t. //
  if ((!stop_state) && (t <= t_max)) { 
    // Increment our values of x, y, z and t with the corresponding rate of change and add the coordinates to our ArrayList. //
    x += dx;
    y += dy;
    z += dz;
    t += dt;
    points.add(new PVector(x, y, z));
  }
}

/**
 Changes the cameras default settings to predetermined values which lock the zoom and sets the cameras location when the visualisation is reset or ran.
 */
void camSettings() {
  cam.setDistance(500);
  cam.setSuppressRollRotationMode();
  cam.setMinimumDistance(100);
  cam.setMaximumDistance(1000);
  cam.setResetOnDoubleClick(false);
}

void mousePressed() {
  // As when sliders are pressed the camera also moves I decided to create a rectangle deadzone which deactivates the cameras movement abilities when in the rectangle.
  if (mouseX > 0 && mouseX < 200 && mouseY > 0 && mouseY < 100) {
    cam.setActive(false);
  } else {
    cam.setActive(true);
  }
}

void keyPressed() {
  if (key == 's')
  {
    saveFrame("Screenshot.png"); // Takes screenshot of current frame.
  }
  if (key == 'r')
  {
    cam.reset(); // Reset cameras orientation
    cam.setDistance(500);
  }
}
