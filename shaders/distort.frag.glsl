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
uniform sampler2D sol_texture;
uniform sampler2D diffuse;

uniform vec2 distort_factor;

COMPAT_VARYING vec4 color;

void main(void) {
    vec2 offset = (COMPAT_TEXTURE(sol_texture,sol_vtex_coord).xy-vec2(0.5))*distort_factor;
    vec4 diff = COMPAT_TEXTURE(diffuse,sol_vtex_coord+offset);
    FragColor = diff;
}
