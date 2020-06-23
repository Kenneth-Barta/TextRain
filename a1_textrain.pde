/**
    CSci-4611 Assignment #1 Text Rain
**/


import processing.video.*;

// Global variables for handling video data and the input selection screen
String[] cameras;
Capture cam;
Movie mov;
PImage inputImage;
PImage debug_image;                  // The black and white image to be used for debugging
boolean inputMethodSelected = false;
PFont font;
textDrop[] rain = new textDrop[50];  // An array of drops to be used within the program
String[] letters = new String[0];    // The letters that will saved from a text file
float threshold = 130;               // Current default threshold. Can be changed by using up and down keys
int current_drop = 0;                // Index of the current drop that will be the main index for rain[]
boolean debug = false;               // Boolean to tell whether we are using the debug mode or not

  

void setup() {
  size(1280, 720);  
  font = loadFont("ArialRounded.vlw");
  textFont(font);
  fill(128, 0, 128);
  inputImage = createImage(width, height, RGB);
  debug_image = createImage(width, height, RGB); 
// Read in a text file and separate the characters
  BufferedReader reader = createReader("TextRainChar.txt");
  String letter = null;

  try {
    while ((letter = reader.readLine()) != null) {
      letters = letter.replaceAll("\\p{P}", "").split("");
    }
    reader.close();
  } catch (IOException e) {
    e.printStackTrace();
  }
}


void draw() {
  // When the program first starts, draw a menu of different options for which camera to use for input
  // The input method is selected by pressing a key 0-9 on the keyboard
 
  
  if (!inputMethodSelected) {
    cameras = Capture.list();
    int y = 40;
    text("O: Offline mode, test with TextRainInput.mov movie file instead of live camera feed.", 20, y);
    y += 40; 
    for (int i = 0; i < min(9,cameras.length); i++) {
      text(i+1 + ": " + cameras[i], 20, y);
      y += 40;
    }
    return;
  }

  // This part of the draw loop gets called after the input selection screen, during normal execution of the program.
  
  // STEP 1.  Load an image, either from a movie file or from a live camera feed. Store the result in the inputImage variable
  
  if ((cam != null) && (cam.available())) {
    cam.read();
    inputImage.copy(cam, 0,0,cam.width,cam.height, 0,0,inputImage.width,inputImage.height);

  }
  else if ((mov != null) && (mov.available())) {
    mov.read();
    inputImage.copy(mov, 0,0,mov.width,mov.height, 0,0,inputImage.width,inputImage.height);
  }


  // Fill in your code to implement the rest of TextRain here..
  
  // Create the drops as time goes on within the video
    if(((millis()%4) == 0)) { //Create a new drop every 4 seconds
        rain[current_drop] = new textDrop();
        
        if(current_drop < rain.length-1){ 
          current_drop++;
        }
        else{
        current_drop = 0;
        }
    }
  
  debug_image.loadPixels();
  
  // A threshold view for debugging
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++ ) {
      int loc = x + y*width;
      // Test the brightness against the threshold
      if (brightness(inputImage.pixels[loc]) > threshold) {
        debug_image.pixels[loc]  = color(255);  // White
      }  else {
        debug_image.pixels[loc]  = color(0);    // Black
      }
    }
  } 

  // We changed the pixels in debug_image
  debug_image.updatePixels(); 

  inputImage.filter(GRAY); // Convert image to grayscale
  
  pushMatrix();
  scale(-1,1);
  if(debug) {
    image(debug_image, -width, 0);
  }
  else {
    image(inputImage, -width, 0);
  }
  popMatrix();
  
  
  // Main for loop to iterate through all current text droplets, and make them "rain"
  for(int i = 0; i < rain.length; i++) {   
      if(rain[i] != null) {           // Need to check to make sure the droplets exists
        if(millis()%1 == 0) {     // Every 1 second of world time, increase the drops velocity by some amount.
          rain[i].speed += 3;        
        }
              
        Boolean fall = true;
        for(int nextPix = 1; nextPix < rain[i].speed; nextPix++) { // Check to see if the drop will potentially run into a surface within the next frame due to its speed
          int resting_pix = get(rain[i].x, rain[i].y + nextPix);
              
          if(brightness(resting_pix) < threshold) { 
            fall = false;
            rain[i].y += nextPix;                               // If there is a surface coming up, place the drop on that surface.
            int right_pix = get(rain[i].x + 3, rain[i].y + 3);  // Attempt to see if the letter landed on a sloped surface and "slide" the drop if so.
            int left_pix = get(rain[i].x - 3 , rain[i].y + 3);  // The surface, however has to be extremely steep
            rain[i].speed = 5;                                  // Reset the speed of the drop. When it starts falling again, it will have to regain its velocity

            if(brightness(right_pix) > threshold) { 
              rain[i].x += 3;
              rain[i].y += 3;
            }
            else if(brightness(left_pix) > threshold) { 
              rain[i].x -= 3;
              rain[i].y += 3;
            }
            else {
              fall = false; 
              break;
            }
          }     
        } 
        if(fall || (rain[i].lifetime > 400)) {   // If the drop has been in existence for some time, it might just be held up for a prolonged time. Let it "run" off.
          rain[i].y += rain[i].speed;            // Let the drop fall otherwise
        }
        
        boolean rise = false;
        int count;
        float surface_pixel = brightness(get(rain[i].x, rain[i].y));
        
        for(count = 1; count <= 30; count++) {   
          float prev_pixel = brightness(get(rain[i].x, rain[i].y - count));
          if((surface_pixel < threshold) && (prev_pixel > threshold)) { // Only raise the droplet if there is sufficent room above it. 
            rise = true;                                                // If the droplet is completely smothered, dont rise
            break;
          }
        }
        if(rise) {
          rain[i].y -= count;
        }             
        
        rain[i].lifetime++;
        
        text(rain[i].l, rain[i].x, rain[i].y);
        
        if((rain[i].y >= height - 20))  { 
           rain[i] = null; // When a drop falls out of the picture, delete it
        } 
      }
   }  
}

/* 
** An object class to represent the text rain drops
*/

class textDrop {
 int rand = int(random(letters.length));  // A pseudo random number to select a letter
 String l = letters[rand];                // The letter of the droplet
 int x = int(random(width));              // Where in the picture it will fall from
 int y = 0;                               // Start falling from the top of the screen
 int speed = 5;                           // Initial speed of the drop
 int lifetime = 0;                        // How many frames the drop has been in existence
}

void keyPressed() {
  
  if (!inputMethodSelected) {
    // If we haven't yet selected the input method, then check for 0 to 9 keypresses to select from the input menu
    if ((key >= '0') && (key <= '9')) { 
      int input = key - '0';
      if (input == 0) {
        println("Offline mode selected.");
        mov = new Movie(this, "TextRainInput.mov");
        mov.loop();
        inputMethodSelected = true;
      }
      else if ((input >= 1) && (input <= 9)) {
        println("Camera " + input + " selected.");           
        // The camera can be initialized directly using an element from the array returned by list():
        cam = new Capture(this, cameras[input-1]);
        cam.start();
        inputMethodSelected = true;
      }
    }
    return;
  }


  // This part of the keyPressed routine gets called after the input selection screen during normal execution of the program
  // Fill in your code to handle keypresses here..
  
  if (key == CODED) {
    if (keyCode == UP) {
      // up arrow key pressed
      threshold += 5;
    }
    else if (keyCode == DOWN) {
      // down arrow key pressed
      threshold -= 5;
    }
  }
  else if (key == ' ') {
    // space bar pressed
    if(debug) {
      debug = false;
    }
    else {
      debug = true;
    }
  } 
  
}
