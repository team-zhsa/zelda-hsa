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
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#else
#define COMPAT_VARYING varying
#define COMPAT_ATTRIBUTE attribute
#endif

#ifdef GL_ES
precision mediump float;
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform mat4 sol_mvp_matrix;
uniform mat3 sol_uv_matrix;
COMPAT_ATTRIBUTE vec2 sol_vertex;
COMPAT_ATTRIBUTE vec2 sol_tex_coord;
COMPAT_ATTRIBUTE vec4 sol_color;

COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;

#define ZOOM_SCALE 1.235

void main()
{
    gl_Position = sol_mvp_matrix * vec4(sol_vertex, 0.0, 1.0) * vec4(ZOOM_SCALE, ZOOM_SCALE, 1.0, 1.0);
    sol_vtex_coord = sol_tex_coord;
}
