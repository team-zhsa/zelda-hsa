/*
 * Copyright (C) 2010-2012 cgwg, Themaister and DOLLS
 * Copyright (C) 2018 Christopho, Solarus - http://www.solarus-games.org
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

// CRT-interlaced shader from the bsnes project.
// Like the standard CRT shader, but detects when the emulator is outputting
// interlaced frames and draws each field at the appropriate location.
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

uniform vec2 sol_input_size;
uniform vec2 sol_output_size;
vec2 sol_texture_size = sol_input_size;

varying float CRTgamma;
varying float monitorgamma;
varying vec2 overscan;
varying vec2 aspect;
varying float d;
varying float R; 
varying float cornersize;
varying float cornersmooth;

varying vec3 stretch;
varying vec2 sinangle;
varying vec2 cosangle;

varying vec2 texCoord;
varying vec2 one;
varying float mod_factor;
varying vec2 ilfac;

#define FIX(c) max(abs(c), 1e-5);

float intersect(vec2 xy)
{
    float A = dot(xy,xy)+d*d;
    float B = 2.0*(R*(dot(xy,sinangle)-d*cosangle.x*cosangle.y)-d*d);
    float C = d*d + 2.0*R*d*cosangle.x*cosangle.y;
    return (-B-sqrt(B*B-4.0*A*C))/(2.0*A);
}

vec2 bkwtrans(vec2 xy)
{
    float c = intersect(xy);
    vec2 point = vec2(c)*xy;
    point -= vec2(-R)*sinangle;
    point /= vec2(R);
    vec2 tang = sinangle/cosangle;
    vec2 poc = point/cosangle;
    float A = dot(tang,tang)+1.0;
    float B = -2.0*dot(poc,tang);
    float C = dot(poc,poc)-1.0;
    float a = (-B+sqrt(B*B-4.0*A*C))/(2.0*A);
    vec2 uv = (point-a*sinangle)/cosangle;
    float r = R*acos(a);
    return uv*r/sin(r/R);
}

vec2 fwtrans(vec2 uv)
{
    float r = FIX(sqrt(dot(uv,uv)));
    uv *= sin(r/R)/r;
    float x = 1.0-cos(r/R);
    float D = d/R + x*cosangle.x*cosangle.y+dot(uv,sinangle);
    return d*(uv*cosangle-x*sinangle)/D;
}

vec3 maxscale()
{
    vec2 c = bkwtrans(-R * sinangle / (1.0 + R/d*cosangle.x*cosangle.y));
    vec2 a = vec2(0.5)*aspect;
    vec2 lo = vec2(fwtrans(vec2(-a.x,c.y)).x,
                 fwtrans(vec2(c.x,-a.y)).y)/aspect;
    vec2 hi = vec2(fwtrans(vec2(+a.x,c.y)).x,
                 fwtrans(vec2(c.x,+a.y)).y)/aspect;
    return vec3((hi+lo)*aspect*0.5,max(hi.x-lo.x,hi.y-lo.y));
}


void main()
{
    // START of parameters

    // gamma of simulated CRT
    CRTgamma = 2.4;
    // gamma of display monitor (typically 2.2 is correct)
    monitorgamma = 2.2;
    // overscan (e.g. 1.02 for 2% overscan)
    overscan = vec2(1.01);
    // aspect ratio
    aspect = vec2(1.0, 0.75);
    // lengths are measured in units of (approximately) the width
    // of the monitor simulated distance from viewer to monitor
    d = 2.0;
    // radius of curvature
    R = 1.5;
    // tilt angle in radians
    // (behavior might be a bit wrong if both components are
    // nonzero)
    const vec2 angle = vec2(0.0,-0.15);
    // size of curved corners
    cornersize = 0.03;
    // border smoothness parameter
    // decrease if borders are too aliased
    cornersmooth = 1000.0;

    // END of parameters

    // Do the standard vertex processing.
    gl_Position = sol_mvp_matrix * vec4(sol_vertex, 0.0, 1.0);

    // Precalculate a bunch of useful values we'll need in the fragment
    // shader.
    sinangle = sin(angle);
    cosangle = cos(angle);
    stretch = maxscale();

    // Texture coords.
    texCoord = sol_tex_coord.xy;

    ilfac = vec2(1.0,floor(sol_input_size.y/200.0));

    // The size of one texel, in texture-coordinates.
    one = ilfac / sol_texture_size;

    // Resulting X pixel-coordinate of the pixel we're drawing.
    mod_factor = texCoord.x * sol_texture_size.x * sol_output_size.x / sol_input_size.x;
}
