#version 120
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D

#ifdef GL_ES
precision mediump float;
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform sampler2D sol_texture;
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;

void main() {
    FragColor = COMPAT_TEXTURE(sol_texture, sol_vtex_coord.xy);
    FragColor.rgb = floor((FragColor.rgb-0.30) * 1000 / 100);
}
//