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
uniform int sol_time;
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;

float rand(vec3 co){
    return fract(sin(dot(co.xyz ,vec3(12.9898,78.233,102.12042))) * 43758.5453);
}

vec3 dither(vec3 rgb) {
    vec3 c = vec3(gl_FragCoord.xy*0.0001,float(sol_time)*0.00001);
    vec3 add = rgb + vec3(rand(c)*0.6);
    return clamp((add - vec3(1))*400.0,0.0,1.0);
}

void main() {
      vec4 tex_color = COMPAT_TEXTURE(sol_texture, sol_vtex_coord);
      FragColor = tex_color * sol_vcolor;
      //FragColor = vec4(1,0,0,1);
      FragColor.rgb = dither(FragColor.rgb);
}
