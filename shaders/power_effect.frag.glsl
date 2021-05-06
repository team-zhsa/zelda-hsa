
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

uniform vec4 target_color;

float abs2rel(float color_component){
  return color_component/255.;
}

//checks whether 2 colors are close enough
bool is_close_to(vec4 color, float r, float g, float b, float tolerance)
{
  return abs(color.r-abs2rel(r))<=tolerance && abs(color.g-abs2rel(g))<=tolerance && abs(color.b-abs2rel(b))<=tolerance;
}

//common function used by both opacified and non opacified versions
vec4 compute_color(vec4 color) 
{
  float p=(sin(sol_time/120.)+1)/4;
  //filter out the skin colors
  if (!(
        is_close_to(color,   0.,   0.,   0., 0.000000001) //Editor background
     //|| is_close_to(color, 248., 192., 136., 0.000001) //skin light (walking)
     || is_close_to(color, 240., 160., 104., 0.000001) //skin light
    //é || is_close_to(color, 240., 176., 112., 0.000001) //Hand (walking)
     || is_close_to(color, 224., 144.,  80., 0.000001) //Hand
     //|| is_close_to(color, 216., 136.,  64., 0.000001)  //skin shadow (walking)
     || is_close_to(color, 184., 104.,  32., 0.000001)  //skin shadow
     || is_close_to(color, 248., 248., 248., 0.000001) //Eyes
     || is_close_to(color,  40.,  40.,  40., 0.000001) //Outline
))
  {
        return vec4(mix(color.rgb, target_color.rgb, p),color.a);
  }
  return color;
}


void main() {
    if (!sol_vcolor_only) {
        vec4 tex_color = COMPAT_TEXTURE(sol_texture, sol_vtex_coord);
        FragColor=compute_color(tex_color * sol_vcolor);
        //FragColor =  tex_color * sol_vcolor;
        if (sol_alpha_mult) {
            FragColor.rgb *= sol_vcolor.a; //Premultiply by opacity too
        }
    } else {
        FragColor = compute_color(sol_vcolor);
    }
}
