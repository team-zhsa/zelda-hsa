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
uniform vec3 character_position; // character position on the map in normalized coords [0,1]
uniform float angle; // azimut angle in radians, control where the camera is horizontally aiming [-inf,inf]
uniform float pitch; // pitch angle, in theory in radians, control where the camera is vertically aiming, positive is down for unknow reasons [-inf, inf]
uniform bool repeat_texture;

COMPAT_VARYING vec4 vertex_position;

// Mode 7 transformation.
vec4 make_mode_7(vec2 uv) {

    // Create a 3D point
    vec3 p = vec3(uv.x*320.0/256.0, uv.y - 1.0, -uv.y);

    mat2 pitch_mat = mat2(cos(pitch), -sin(pitch), sin(pitch), cos(pitch));
    p.yz = pitch_mat * p.yz;
    
    // Projecting back to 2D space
    float conv = 1.0;
    float persp_scale = conv/(p.z);
    vec2 uvm7 = p.xy*persp_scale;

    // Texture scaling if you need
    float scale = max(0.01, character_position.z);
    uvm7 *= scale;

    // Rotations if needed
    float a = /*radians(180.0)*/ + angle;
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
    if (repeat_texture) {
      uvm7 = fract(uvm7);  // Unnecessary if GL_REPEAT is set on the texture.
    }

    if (uvm7.x < 0.0 || uvm7.x > 1.0 ||
        uvm7.y < 0.0 || uvm7.y > 1.0 || p.z < 0.0) {
        // TODO return water/clouds background image
        return vec4(18.0, 18.0, 88.0, p.z < 0.0 ? 0.0 : 255.0)/255.0;
    }

    vec4 mode_7_color = vec4(COMPAT_TEXTURE(mode_7_texture, uvm7).xyz, 1.0);

    // Darkness based on the horizon
    //mode_7_color *= -(uv.y - h - 0.50);

    vec4 col = mode_7_color;

    // Output the color
    return col;
}

void main() {
    FragColor = make_mode_7(vertex_position.xy * vec2(1.0, -1.0));
}
