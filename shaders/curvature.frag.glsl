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

// Curvature shader from the bsnes project
// https://gitorious.org/bsnes/xml-shaders
// Adapted for Solarus by Christopho.

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
vec2 sol_texture_size = sol_input_size;

// Tweak this parameter for more / less distortion
#define distortion 1.2

vec2 radialDistortion(vec2 coord) {
  coord *= sol_texture_size / sol_input_size;
  vec2 cc = coord - vec2(0.5);
  float dist = dot(cc, cc) * distortion;
  return (coord + cc * (1.0 + dist) * dist) * sol_input_size / sol_texture_size;
}

float corner(vec2 coord) {
    if (coord.x < 0.0 || coord.y < 0.0 || coord.x > 1.0 || coord.y > 1.0)
        return 0.0;
    return 1.0;
}

void main() {
  vec2 xy = radialDistortion(sol_vtex_coord.xy);
  vec4 sample = COMPAT_TEXTURE(sol_texture, xy);
  sample *= vec4(vec3(corner(xy)), 1.0);
  FragColor = sample;
}
