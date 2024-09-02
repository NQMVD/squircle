import com.krab.lazy.*;

LazyGui gui;

float a, b; // Center coordinates
float size; // Size of shape
float n = 4; // Exponent for squircle (adjust this to change the shape)
PGraphics shadowLayer;
PShader grainShader;
float levels = 8.0;
int octaves = 6;
float brightnessFactor = 0.1;
float alphaFactor = 0.1;

color backgroundColor = color(30, 30, 30);
color squircleFillColor = color(50, 50, 50);
color squircleStrokeColor = color(70, 70, 70);
color shadowColor = color(10, 10, 10, 70);

void settings() {
  size(800, 600, P2D);
  smooth(8); // Enable 8x anti-aliasing
}

void setup() {
  gui = new LazyGui(this);

  size = 300;
  a = width / 2;
  b = height / 2;

  // Enable high-quality rendering
  //((PGraphicsOpenGL)g).textureSampling(3);
  //hint(ENABLE_STROKE_PURE);

  shadowLayer = createGraphics(width, height, P2D);

  grainShader = loadShader("grain.glsl");
  grainShader.set("u_resolution", float(width), float(height));
  grainShader.set("u_levels", levels);
  grainShader.set("u_octaves", octaves);
  grainShader.set("u_brightnessFactor", brightnessFactor);
  grainShader.set("u_alpha", alphaFactor);
}

void draw() {
  n = gui.slider("edgie", 4, 2, 12);
  brightnessFactor = gui.slider("brightness", 0.1, 0, 1);
  alphaFactor = gui.slider("alpha", 0.1, 0, 1);

  grainShader.set("u_brightnessFactor", brightnessFactor);
  grainShader.set("u_alpha", alphaFactor);

  background(backgroundColor);

  //push();
  //  noStroke();
  //  shader(grainShader);
  //    rect(0, 0, width, height);
  //  resetShader();
  //pop();

  // Draw shadow
  if (gui.toggle("shadow")) {
    shadowLayer.beginDraw();
    shadowLayer.clear();
    shadowLayer.fill(shadowColor);
    shadowLayer.noStroke();
    drawSquircle(shadowLayer, a, b + 15); // Increased Y offset to 15
    shadowLayer.endDraw();
    image(shadowLayer, 0, 0);
  }

  // Draw squircle
  fill(squircleFillColor);
  stroke(squircleStrokeColor);
  strokeWeight(2);

  boolean shade = gui.toggle("shade");
  if (shade) {
    String mode = gui.radio("mode", new String[]{"BLEND", "ADD", "SUBTRACT", "DARKEST", "LIGHTEST", "DIFFERENCE", "EXCLUSION", "MULTIPLY", "SCREEN", "REPLACE"});
    if (mode.equals("BLEND")) {
      blendMode(BLEND);
    } else if (mode.equals("ADD")) {
      blendMode(ADD);
    } else if (mode.equals("SUBTRACT")) {
      blendMode(SUBTRACT);
    } else if (mode.equals("DARKEST")) {
      blendMode(DARKEST);
    } else if (mode.equals("LIGHTEST")) {
      blendMode(LIGHTEST);
    } else if (mode.equals("DIFFERENCE")) {
      blendMode(DIFFERENCE);
    } else if (mode.equals("EXCLUSION")) {
      blendMode(EXCLUSION);
    } else if (mode.equals("MULTIPLY")) {
      blendMode(MULTIPLY);
    } else if (mode.equals("SCREEN")) {
      blendMode(SCREEN);
    } else if (mode.equals("REPLACE")) {
      blendMode(REPLACE);
    }

    shader(grainShader);
  }
  drawSquircle(g, a, b);
  if (shade) {
    resetShader();
    blendMode(NORMAL);
  }
}

void drawSquircle(PGraphics pg, float x, float y) {
  pg.pushMatrix();
  pg.translate(x, y);
  pg.beginShape();
  for (float angle = 0; angle < TWO_PI; angle += 0.01) {
    float px = getX(angle);
    float py = getY(angle);
    pg.vertex(px, py);
  }
  pg.endShape(CLOSE);
  pg.popMatrix();
}

void applyNoise(float alpha) {
  grainShader.set("u_alpha", alpha);
  shader(grainShader);
}

float getX(float angle) {
  return size/2 * pow(abs(cos(angle)), 2/n) * sign(cos(angle));
}

float getY(float angle) {
  return size/2 * pow(abs(sin(angle)), 2/n) * sign(sin(angle));
}

float sign(float x) {
  return x >= 0 ? 1 : -1;
}
