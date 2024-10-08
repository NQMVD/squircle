import com.krab.lazy.*;

LazyGui gui;

float a, b; // Center coordinates
float size; // Size of shape
float n = 4; // Exponent for squircle (adjust this to change the shape)
PGraphics backgroundLayer;
PGraphics squircleLayer;
PShader grainShader;
float levels = 8.0;
int octaves = 6;
float brightnessFactor = 0.1;
String[] noiseModes = {"multiply", "add", "subtract", "mix", "balanced"};
String currentNoiseMode = "multiply";

color backgroundColor = color(30, 30, 30);
color squircleFillColor = color(50, 50, 50);
color squircleStrokeColor = color(70, 70, 70);

void settings() {
  size(800, 600, P2D);
  smooth(8);
}

void setup() {
  gui = new LazyGui(this);

  size = 300;
  a = width / 2;
  b = height / 2;

  // Enable high-quality rendering
  ((PGraphicsOpenGL)g).textureSampling(3);
  hint(ENABLE_STROKE_PURE);

  backgroundLayer = createGraphics(width, height, P2D);
  squircleLayer = createGraphics(width, height, P2D);

  grainShader = loadShader("grain.glsl");
  grainShader.set("u_resolution", float(width), float(height));

  // Apply noise to background layer
  backgroundLayer.beginDraw();
  backgroundLayer.background(backgroundColor);
  backgroundLayer.endDraw();
  applyNoise(backgroundLayer, 4.0, 8, 0.1, 0); // Subtle background noise
}

void draw() {
  // variables
  n = gui.slider("edgie", 4, 2, 10);
  brightnessFactor = gui.slider("brightness", 0.1, 0, 5);
  currentNoiseMode = gui.radio("Noise Mode", noiseModes);

  // Clear the main canvas
  background(100);

  // Draw Background
  image(backgroundLayer, 0, 0);

  // Draw squircle
  squircleLayer.beginDraw();
  squircleLayer.clear();
  squircleLayer.fill(squircleFillColor);
  squircleLayer.stroke(squircleStrokeColor);
  squircleLayer.strokeWeight(2);
  drawSquircle(squircleLayer, a, b);
  squircleLayer.endDraw();

  // Apply grain if toggled
  if (gui.toggle("shade")) {
    int modeIndex = java.util.Arrays.asList(noiseModes).indexOf(currentNoiseMode);
    applyNoise(squircleLayer, levels, octaves, brightnessFactor, modeIndex);
  }
  
  image(squircleLayer, 0, 0);
}

void applyNoise(PGraphics layer, float levels, int octaves, float brightness, int mode) {
  grainShader.set("u_levels", levels);
  grainShader.set("u_octaves", octaves);
  grainShader.set("u_brightnessFactor", brightness);
  grainShader.set("u_mode", mode);
  
  layer.beginDraw();
  layer.filter(grainShader);
  layer.endDraw();
}

void drawSquircle(PGraphics pg, float x, float y) {
  pg.pushMatrix();
  pg.translate(x, y);
  pg.beginShape();
  for (float angle = 0; angle < TWO_PI; angle += 0.01) {
    pg.vertex(getX(size, n, angle), getY(size, n, angle));
  }
  pg.endShape(CLOSE);
  pg.popMatrix();
}

float getX(float size, float n, float angle) {
  return size/2 * pow(abs(cos(angle)), 2/n) * sign(cos(angle));
}

float getY(float size, float n, float angle) {
  return size/2 * pow(abs(sin(angle)), 2/n) * sign(sin(angle));
}

float sign(float x) {
  return x >= 0 ? 1 : -1;
}
