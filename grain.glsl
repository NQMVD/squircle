#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform vec2 u_resolution;
uniform float u_levels;
uniform int u_octaves;
uniform float u_brightnessFactor;
uniform float u_alpha;

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

  float n = noise(st, u_octaves);
  n = floor(n * u_levels) / u_levels;
  float brightness = n * u_brightnessFactor;

  gl_FragColor = vec4(vec3(brightness), u_alpha);
}
