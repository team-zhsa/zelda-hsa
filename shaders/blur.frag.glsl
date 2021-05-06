#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
precision mediump float;
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform sampler2D sol_texture;
uniform bool sol_vcolor_only;
uniform bool sol_alpha_mult;
uniform int sol_time;
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;

float PHI = 1.61803398874989484820459;  // Φ = Golden Ratio  

float gold_noise(in vec2 xy, in float seed){
  return fract(tan(distance(xy*PHI, xy)*seed)*xy.x);
}

vec4 sample_tex(vec2 coord) {
  const float eps = 1e-4;
  const float eeps = 1-eps;
  return COMPAT_TEXTURE(sol_texture, clamp(coord, vec2(eps,eps), vec2(eeps,eeps)));
}

void main() {
  vec4 tex_color = vec4(0,0,0,1);//COMPAT_TEXTURE(sol_texture, sol_vtex_coord);
  const int ksize = 3;
  float time = float(sol_time*0.001);
  const float kwidth = 0.1;//+0.001*sin(time);
  const float kfac = 2.0 / ((2*ksize+1)*(2*ksize+1));
  /*for(int i = -ksize; i < ksize+1; i++) {
    for(int j = -ksize; j < ksize+1; j++) {
      vec2 bcoord = sol_vtex_coord + vec2(i*kwidth, j*kwidth);
      tex_color += COMPAT_TEXTURE(sol_texture, bcoord)*kfac*exp(-length(bcoord));
    }
  }*/
  vec2 seed = gl_FragCoord.xy;
  const float acc_fac = 20.0 / 255.0;
  const int count = 8;
  for(int i = 0; i < count; i++) {
     vec2 pol =  + vec2(gold_noise(seed, i+time), gold_noise(seed, i+0.25+time)*2*3.1415);
     //vec2 pol = vec2(float(i)/count, i*20);
     float rad = sqrt(pol.x);
     vec2 bcoord = sol_vtex_coord + vec2(rad*cos(pol.y), rad*sin(pol.y))*kwidth;
     tex_color += sample_tex(bcoord)*acc_fac/count;
  }
  FragColor = tex_color;
}
