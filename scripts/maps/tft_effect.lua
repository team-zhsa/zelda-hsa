local tfteff = {}

local tftshader = sol.shader.create('tft')
local fac = tftshader:get_scaling_factor()

local qw,qh = sol.video.get_quest_size()
local previous = sol.surface.create(qw*fac,qh*fac)

tftshader:set_uniform('previous',previous)

local persistence = 0.75



local big_dst = sol.surface.create(previous:get_size())
local enabled

local main_surface
local function on_main_draw(_,dst)
  main_surface = dst
  if enabled then
    dst:set_shader(tftshader)
    dst:set_scale(fac,fac)
    dst:draw(big_dst)
    big_dst:set_scale(1,1)
    big_dst:draw(previous)
    dst:set_scale(1,1)
    dst:set_shader(nil)
  end
end

function sol.video:on_draw(dst)
  if enabled then
    local bw,bh = big_dst:get_size()
    local dw,dh = dst:get_size()
    big_dst:set_scale(dw/bw,dh/bh)
    big_dst:draw(dst)
  end
end

local inited
local function init()
  if inited then
    return
  end
  sol.main:register_event('on_draw',on_main_draw)
  inited = true
end

local previous_shader
function tfteff:on_map_changed(map)
  if not map then
    previous_shader = sol.video.get_shader()
    sol.video.set_shader(tftshader)
    tftshader:set_uniform('persistence',0.0)
    enabled = false
  else
    sol.video.set_shader(nil)
    tftshader:set_uniform('persistence',persistence)
    enabled = true
  end
  init()
end

function tfteff:on_map_draw(map,dst)
end

function tfteff:clean(map)
  enabled = false
  --sol.video.set_shader(previous_shader)
end

return tfteff