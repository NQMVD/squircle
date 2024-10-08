#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
varying vec4 vertColor;
varying vec4 vertTexCoord;

uniform vec2 u_resolution;
uniform float u_levels;
uniform int u_octaves;
uniform float u_brightnessFactor;
uniform int u_mode;

float random(vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 st, int octaves) {
  float value = 0.0;
  float amplitude = 0.5;
  vec2 shift = vec2(100.0);
  vec2 temp_st = st;
  
  for (int i = 0; i < octaves; i++) {
    value += random(temp_st) * amplitude;
    temp_st = temp_st * 2.0 + shift;
    amplitude *= 0.5;
  }
  
  return value;
}

void main() {
  vec2 st = gl_FragCoord.xy / u_resolution.xy;
  vec4 color = texture2D(texture, vertTexCoord.st);

  float n = noise(st, u_octaves);
  n = floor(n * u_levels) / u_levels;
  float brightness = n * u_brightnessFactor;

  // vec3 finalColor = color.rgb * brightness;
  vec3 finalColor;
  if (u_mode == 0) {
    finalColor = color.rgb * (1.0 + brightness); // Multiply
  } else if (u_mode == 1) {
    finalColor = color.rgb + vec3(brightness); // Add
  } else if (u_mode == 2) {
    finalColor = color.rgb - vec3(brightness); // Subtract
  } else if (u_mode == 3) {
    finalColor = mix(color.rgb, vec3(brightness), 0.5); // Mix
  } else if (u_mode == 4) {
    float balancedNoise = (n - 0.5) * 2.0 * u_brightnessFactor; // Map to [-1, 1] and apply brightness factor
    finalColor = color.rgb + vec3(balancedNoise);
  } else {
    finalColor = color.rgb; // Default case
  }  
  
  gl_FragColor = vec4(finalColor, color.a);
}
