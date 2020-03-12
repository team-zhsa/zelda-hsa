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

//inputs from vertex shader
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec2 plain_tex_coord;

//uniform values
//uniform sampler2D sol_texture;

uniform float distort_factor;
uniform float wave_factor;
uniform float speed;
uniform vec2 camera_pos;

uniform int sol_time;

COMPAT_VARYING vec4 color;

void main(void) {
    float ftime = float(sol_time)*speed+(gl_FragCoord.y+camera_pos.y)*wave_factor;
    float offset = sin(ftime)*distort_factor;
    FragColor = vec4(0.5+0.5*offset, 0.5, 0.0, 1.0);
}