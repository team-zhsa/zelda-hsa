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
uniform int sol_time;
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;

void main() {
    vec3 texel = COMPAT_TEXTURE(sol_texture, sol_vtex_coord).rgb;
    FragColor = vec4(texel.x,texel.y,texel.z, 1.0);
    float lum = dot(texel,vec3(1.0, 1.0, 1.0));

    const vec3 black = vec3(0.0,0.0,0.00)/255.0;
    const vec3 white = vec3(223.0,223.0,223.0)/255.0;
    if(mod(float(sol_time),80.0) > 40.0)
      FragColor.rgb = (lum < 0.5) ? white : black;
    else
      FragColor.rgb = (lum < 0.5) ? black : white;
    FragColor.rgb = FragColor.rgb;
    FragColor.rgb *= pow(lum,0.5);
}