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
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;

uniform int sol_time;
uniform float magnitude = .1; // Magnitude of the waving effect ~ [0.01 -> 0.1]
uniform bool separated; // Set this to true to enable image `scanlines` duplication

void main() {
    vec2 offset = vec2(magnitude*sin(float(sol_time)*0.004+gl_FragCoord.y*2.0*magnitude),0.0);
    if(mod(gl_FragCoord.y,2.0) > 0.5 && separated) {
      offset *= vec2(-1.0,1.0);
    }
    vec4 tex_color = COMPAT_TEXTURE(sol_texture, sol_vtex_coord+offset);
    FragColor = tex_color * sol_vcolor;
}
