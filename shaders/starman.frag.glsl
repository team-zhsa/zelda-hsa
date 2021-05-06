
#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out COMPAT_PRECISION vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

uniform sampler2D sol_texture;
uniform bool sol_vcolor_only;
uniform bool sol_alpha_mult;
uniform int sol_time;
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;
float offset=240;

vec3 rgb2hsv(vec3 rgb_color){
  float r=rgb_color.r;
  float g=rgb_color.g;
  float b=rgb_color.b;
  float cmax=max(r, max(g,b));
  float cmin=min(r, min(g,b));
  float delta=cmax-cmin;
  float hue;
  if(delta==0.) hue=0.;
  if(cmax==r) hue=60.*mod((g-b)/delta+360.0, 360.0);
  if(cmax==g) hue=60.*(b-r)/delta+120.0;
  if(cmax==b) hue=60.*(r-g)/delta+240.0;

float sat=0.;
if (cmax>0.) sat=1.-(cmin/cmax);
  return vec3(hue,  sat,  cmax);
}


vec3 hsv2rgb(float h, float s, float v){
  int t=int(h/60.0)%6;
float f=(h/60.0)-t;
float l=v*(1.-s);
float m=v*(1.-f*s);
float n=v*(1.-(1.-f)*s);
vec3 color;
if (t==0.) color=vec3(v,n,l);
if (t==1.) color=vec3(m,v,l);
if (t==2.) color=vec3(l,v,n);
if (t==3.) color=vec3(l,m,v);
if (t==4.) color=vec3(n,l,v);
if (t==5.) color=vec3(v,l,m);

  return color;
}

vec4 compute_color(vec4 color)
{
        vec3 hsv=rgb2hsv(color.rgb);
        float h=hsv.x;
        h=mod(offset+h+sol_time, 360.0);
        return vec4(hsv2rgb(h, hsv.g, hsv.b) ,color.a);
}


void main() {
    if (!sol_vcolor_only) {
        vec4 tex_color = COMPAT_TEXTURE(sol_texture, sol_vtex_coord);
        FragColor=compute_color(tex_color * sol_vcolor);
        //FragColor =  ;
        if (sol_alpha_mult) {
            FragColor.rgb *= sol_vcolor.a; //Premultiply by opacity too
        }
    } else {
        FragColor = compute_color(sol_vcolor);
    }
}
