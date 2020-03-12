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
COMPAT_VARYING vec4 sol_vcolor;
uniform vec2 sol_input_size;
uniform float radius;
uniform vec2 position;

vec2 ratio=vec2(1.5, 1.0);

void main() {
  vec3 texel = COMPAT_TEXTURE(sol_texture, sol_vtex_coord).rgb;

  FragColor = vec4(texel.x,texel.y,texel.z, 1.0);
  vec2 xy=sol_vtex_coord.xy;
  vec2 dxy=xy-(position/sol_input_size);
  vec2 r=radius/sol_input_size*ratio;
  if ((dxy.x*dxy.x)/(r.x*r.x)+(dxy.y*dxy.y)/(r.y*r.y)>1.0){
    FragColor.rgb=vec3(0.0);
  }
}
