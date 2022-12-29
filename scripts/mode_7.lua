-- Experimental mode 7 testing code.

local mode_7_manager = {}
local audio_manager = require("scripts/audio_manager")
local world_width, world_height = 16640, 12960
local map_texture
local clouds_texture

-- Determines the coordinates of a destination entity on am outside map that is not loaded.
local function get_dst_xy(dst_map_id, dst_name)
  -- TODO parse the map file to get the location of the map and the coordinates of the entity.
  -- Store that in a cache.
  -- Put it in another script.

  -- temporary
  if dst_map_id == "out/b3_prairie" then
    return 960 + 368, 1536 + 360
  elseif dst_map_id == "out/a3" then
    return 0 + 520, 2880 + 416
  elseif dst_map_id == "out/d1_east_mt_tamaranch" then
    return 2880 + 192, 0 + 536
  elseif dst_map_id == "out/d4_yarna_desert" then
    return 2880 + 192, 2304 + 592
  end
end



-----------------------------
-- INTERPOLATION
-----------------------------

function lerp(a,b,t)
  return a*(1-t)+b*t
end

local function hermite_interp(start_val,end_val,t)
    local mu = t
    local mu2 = (1-math.cos(mu*math.pi))/2
    return lerp(start_val,end_val,mu2)
end

local function interp(points,func)
  local points = points
  return function(t)
    local last = points[1]
    for _,p in ipairs(points) do
      if p[1] > t then
        if p[1] == last[1] then
          return p[2]
        else
          return func(last[2],p[2],(t-last[1])/(p[1]-last[1]))
        end
      end
      last = p
    end
    return last[2]
  end
end

--END INTERP

-- Quintic easing in out function:
-- t = elapsed time
-- b = begin
-- c = end
-- c = change == ending - beginning
-- d = duration (total time)
local function get_easing_function(b, c, d)
  local c = c - b
  return function(t)
    if c == 0 or t >= d then
      return b + c
    end

    t = t / d * 2
    if t < 1 then
      return c / 2 * math.pow(t, 5) + b
    else
      t = t - 2
      return c / 2 * (math.pow(t, 5) + 2) + b
    end
  end
end

-- Start a mode 7 travel sequence.
-- - game: The current game.
-- - src_entity: An entity where to start from in the current map.
-- - dst_map_id: Id of the destination map.
-- - dst_name: Name of the destination entity where to go in the destination map.
function mode_7_manager:teleport(game, src_entity, destination_map_id, destination_name)

  local mode_7 = {}

  assert(game ~= nil)
  assert(sol.main.get_type(game) == "game")
  assert(destination_map_id ~= nil)

  local quest_width, quest_height = sol.video.get_quest_size()
  local hero = game:get_hero()
  local hero_sprite = sol.sprite.create(hero:get_tunic_sprite_id())
  local owl_sprite = sol.sprite.create("npc/owl")
  if map_texture == nil then
    map_texture = sol.surface.create("work/world_map_scale_1.png")
    cloud_texture = sol.surface.create("work/clouds_and_sea.png")
  end
  assert(map_texture ~= nil)
  local previous_shader = sol.video.get_shader()
  local shader = sol.shader.create("mode_7")
  shader:set_uniform("mode_7_texture", map_texture)
  shader:set_uniform("repeat_texture", false)
  map_texture:set_shader(shader)
  local position_on_texture = { 0.5, 1.0, 0.08 }
  mode_7.xy = {}
  local xy = mode_7.xy
  local initial_distance
  local distance_remaining
  local angle = 0.0

  local start_height = 0.0
  local mid_height = 0.1

  --forward decl of all curves
  local xpos_curve
  local ypos_curve
  local height_curve
  local angle_curve
  local pitch_curve
  local fade_curve
  local target_angle

  local function update_shader()
    local t = (initial_distance-distance_remaining)/initial_distance
    local z  = height_curve(t)
    local angle = angle_curve(t)
    local pitch = pitch_curve(t)
    local x = xpos_curve(t)
    local y = ypos_curve(t)    


    position_on_texture[1] = x / world_width
    position_on_texture[2] = y / world_height
    position_on_texture[3] = z
    shader:set_uniform("character_position", position_on_texture)
    shader:set_uniform("angle",angle)
    shader:set_uniform("horizon", 0) --TODO remove
    shader:set_uniform("pitch",pitch)
    --shader:set_uniform("repeat_texture",true)
    --shader:set_uniform("horizon", 2.75 - 1.5 * z)
  end

  function mode_7:on_started()

    local map = game:get_map()
    local map_x, map_y = map:get_location()
    local src_x_in_map, src_y_in_map = src_entity:get_position()
    xy.x, xy.y = map_x + src_x_in_map, map_y + src_y_in_map

    hero_sprite:set_direction(3)
    hero_sprite:set_animation("walking") --TODO find flying animation
    owl_sprite:set_direction(1)
    owl_sprite:set_animation("walking")

    local dst_x, dst_y = get_dst_xy(destination_map_id, dst_name)
    local xy_movement = sol.movement.create("target")
    initial_distance = sol.main.get_distance(xy.x, xy.y, dst_x, dst_y)
    local angle = -math.atan2(dst_x-xy.x,dst_y-xy.y)-3*math.pi
    target_angle = angle

    local a = 0.25*(125/200.0)
    local b = 1-a

    --Init curves
    xpos_curve = interp(
      {
       {a,xy.x},
       {b,dst_x}
      },hermite_interp)
    ypos_curve = interp(
      {
        {a,xy.y},
        {b,dst_y}
      },hermite_interp)
    height_curve = interp(
      {
        {0,start_height},
        {a,mid_height},
        {b,mid_height},
        {1,start_height}
      },hermite_interp)
    angle_curve = interp(
      {
        {0,0},
        {a,angle},
        {b,angle},
        {1,0}
      },hermite_interp)
    pitch_curve = interp(
      {
        {0,math.pi*0.75},
        {0.4,0},
        {0.65,0},
        {1,math.pi*0.75}
      },hermite_interp)
    fade_curve = interp(
      {
        {0,0},
        {0.2,255},
        {0.8,255},
        {1,0}
      },lerp)

    distance_remaining = initial_distance
    xy_movement:set_target(dst_x, dst_y)
    xy_movement:set_speed(125)
    xy_movement:start(xy, function()
      sol.menu.stop(mode_7)
    end)
    function xy_movement:on_position_changed()
      distance_remaining = sol.main.get_distance(xy.x, xy.y, dst_x, dst_y)
      update_shader()
    end
    xy_movement:on_position_changed()

    sol.timer.start(mode_7, 10, function()
      update_shader()
      return true
    end)

    game:set_suspended(true)  -- Because the map continues to run normally.
    game:set_pause_allowed(false)
    audio_manager:play_music("outside/southern_hyrule")
    update_shader()
  end

  function mode_7:on_draw(dst)
    --clear with upper sky color
    dst:fill_color{28,36,109}
    local t = (initial_distance-distance_remaining)/initial_distance
    local cy = 40-pitch_curve(t)*80
    local cx = -angle_curve(t)*300
    local cext = cloud_texture:get_size()
    while cx > 0 do cx = cx-cext end
    cloud_texture:draw(dst,cx,cy) --draw two strip of clouds to fill the sky
    cloud_texture:draw(dst,cx+cext,cy)
    map_texture:draw(dst,0,0) --this draw the actual mode7 plane
    local hfac = 1-height_curve(t)/mid_height -- [0,1] depending on height
    local x, y = quest_width / 2, lerp(quest_height - 100+cy*1.5,quest_height/2-64,hfac)
    local sprite_dir = (math.floor((angle_curve(t) - target_angle + 0.1)*2/math.pi)+1)%4
    local sprite_scale_factor = 0.8
    local sprite_scale = 1+sprite_scale_factor*hfac
    owl_sprite:set_direction(sprite_dir)
    owl_sprite:set_scale(sprite_scale,sprite_scale)
    owl_sprite:draw(dst, x, y) --draw sprites above
    hero_sprite:set_direction(sprite_dir)
    hero_sprite:set_scale(sprite_scale,sprite_scale)
    hero_sprite:draw(dst, x, y + 16)
    local fade = fade_curve(t)
    dst:fill_color{0,0,0,255-fade}
  end

  function mode_7:on_finished()
    --sol.video.set_shader(previous_shader)
    hero:set_enabled(true)
    game:set_suspended(false)
    game:set_pause_allowed(true)
    hero:teleport(destination_map_id, destination_name, "immediate")
  end

  sol.menu.start(game, mode_7, false)
end

return mode_7_manager
