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
uniform vec2 sol_input_size;
COMPAT_VARYING vec4 sol_vcolor;

uniform float step; 

void main() {
    float pixel_size=pow(2.0, step);
    vec2 relative_region_size=pixel_size/sol_input_size;

    vec2 region_xy=vec2(
             floor(sol_vtex_coord.x/relative_region_size.x),
             floor(sol_vtex_coord.y/relative_region_size.y)
    );
    
    vec4 tex_color = COMPAT_TEXTURE(sol_texture, (region_xy*pixel_size)/sol_input_size);
    FragColor = tex_color;
}
