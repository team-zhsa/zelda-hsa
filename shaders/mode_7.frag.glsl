/*
 * Copyright (C) 2018 Solarus - http://www.solarus-games.org
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

// Mode 7 shader.
// Shows a texture in a perspective view.
// Inspired from https://www.shadertoy.com/view/ltsGWn

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

uniform vec2 sol_input_size;
uniform vec2 sol_output_size;
uniform int sol_time;

uniform sampler2D mode_7_texture;
uniform sampler2D overlay_texture;
uniform vec3 character_position;
uniform float angle;

COMPAT_VARYING in vec4 vertex_position;

// Alpha-blends c1 onto c2.
vec4 alpha_blend(vec4 c1, vec4 c2) {

    float alpha = c1.a + c2.a * (1.0 - c1.a);
    vec3 rgb = (c1.rgb * c1.a) + (c2.rgb * c2.a) * (1.0 - c1.a) / alpha;
    return vec4(rgb, alpha);
}

// Mode 7 transformation.
vec4 make_mode_7(vec2 uv) {

    // Create a 3D point
//    float h = 0.25;
    float h = 1.5;
    vec3 p = vec3(uv.x, uv.y - h - 1.0, uv.y - h);

    // Projecting back to 2D space
    vec2 uvm7 = p.xy / p.z;

    // Texture scaling if you need
//    float scale = 0.4;
    float scale = max(0.01, character_position.z);
    uvm7 *= scale;

  // Rotations if needed
//    float a = (sol_time / 1000.0) * 0.25;
    float a = radians(180.0) + angle;
    mat2 rotation = mat2(cos(a), -sin(a), sin(a), cos(a));
    uvm7 *= rotation;

    // Initial position
    uvm7 += character_position.xy;

    // Translation
//    float dy = 0.0;
//    float translation_distance = -(sol_time / 1000.0) * 0.03;
//    vec2 translation = vec2(translation_distance * sin(a), -translation_distance * cos(a));
//    uvm7 += translation;

    // Repeat
    uvm7 = fract(uvm7);  // Unnecessary if GL_REPEAT is set on the texture.

    // Read background texture
    vec4 mode_7_color = vec4(COMPAT_TEXTURE(mode_7_texture, uvm7).xyz, 1.0);

    // Darkness based on the horizon
//    mode_7_color *= -(uv.y - h - 0.50);

    vec4 overlay_color = COMPAT_TEXTURE(overlay_texture, sol_vtex_coord.xy);

    // Alpha-blend the overlay texture.
    vec4 col = alpha_blend(overlay_color, mode_7_color);

    // Output the color
    return col;
}

void main() {
    FragColor = make_mode_7(vertex_position.xy);
}
