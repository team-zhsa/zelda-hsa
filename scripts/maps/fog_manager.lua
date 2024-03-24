local fog_manager = {}
local fog_menu = {}
local map_meta = sol.main.get_metatable("map")
require("scripts/multi_events")



function fog_manager:set_overlay(map, overlay)
  fog_menu.overlay = sol.surface.create("fogs/"..overlay..".png")
  sol.menu.start(map, fog_menu, false)
  print("fogs/"..overlay..".png")
end

function fog_menu:on_started()
  fog_menu.overlay_angles = {
    3 * math.pi / 4,
    7 * math.pi / 4,
    math.pi / 4,
    5 * math.pi / 4
  }
  fog_menu.overlay_step = 1

  fog_menu.overlay:set_opacity(96)
  fog_menu.overlay_offset_x = 0  -- Used to keep continuity when getting lost.
  fog_menu.overlay_offset_y = 0
  fog_menu.overlay_m = sol.movement.create("straight")
  print("fog menu started")
  fog_menu:restart_overlay_movement()
end

function fog_menu:restart_overlay_movement()
  print("restart")
  fog_menu.overlay_m:set_speed(16) 
  fog_menu.overlay_m:set_max_distance(100)
  fog_menu.overlay_m:set_angle(fog_menu.overlay_angles[fog_menu.overlay_step])
  fog_menu.overlay_step = fog_menu.overlay_step + 1
  if fog_menu.overlay_step > #fog_menu.overlay_angles then
    fog_menu.overlay_step = 1
  end
  fog_menu.overlay_m:start(fog_menu.overlay, function()
    fog_menu:restart_overlay_movement()
  end)
end

function fog_menu:on_draw(dst_surface)
  -- Make the overlay scroll with the camera, but slightly faster to make
  -- a depth effect.
  local camera_x, camera_y = sol.main.get_game():get_map():get_camera():get_position()
  local overlay_width, overlay_height = fog_menu.overlay:get_size()
  local screen_width, screen_height = dst_surface:get_size()
  local x, y = camera_x + fog_menu.overlay_offset_x, camera_y + fog_menu.overlay_offset_y
  x, y = - math.floor(x * 1.5), - math.floor(y * 1.5)

  -- The overlay's image may be shorter than the screen, so we repeat its
  -- pattern. Furthermore, it also has a movement so let's make sure it
  -- will always fill the whole screen.
  x = x % overlay_width - 2 * overlay_width
  y = y % overlay_height - 2 * overlay_height

  local dst_y = y
  while dst_y < screen_height + overlay_height do
    local dst_x = x
    while dst_x < screen_width + overlay_width do
      -- Repeat the overlay's pattern.
      print(dst_x, dst_y)
      fog_menu.overlay:draw(dst_surface, dst_x, dst_y)
      dst_x = dst_x + overlay_width
    end
    dst_y = dst_y + overlay_height
  end
end

map_meta:register_event("on_finished", function()
  sol.menu.stop(fog_menu)
end)

function fog_menu:on_finished()
  if fog_menu.overlay ~= nil then fog_menu.overlay:clear() end
  if fog_menu.overlay_m ~= nil then fog_menu.overlay_m:stop() end
  fog_menu.overlay = nil
  fog_menu.overlay_offset_x, fog_menu.overlay_offset_y = nil, nil
end

--[[
return function(game)
  local fog_menu = {}
  local movement

  function game:display_fog(fog, speed, angle, opacity)
    local fog = fog or nil
    local speed = speed or 1
    local angle = angle or 0
    local opacity = opacity or 16

    self:clear_fog()
	
    fog_menu.fog = fog
    fog_menu.fog_speed = speed
    fog_menu.fog_angle = angle
    fog_menu.fog_opacity = opacity

    sol.menu.start(self:get_map(), fog_menu, false)
  end

  function game:clear_fog()
    if fog_menu.fog_sfc ~= nil then fog_menu.fog_sfc:clear() end
  
    fog_menu.fog = nil
    fog_menu.fog_speed = nil
    fog_menu.fog_angle = nil
    fog_menu.fog_opacity = nil
    if fog_menu.movement ~= nil then fog_menu.movement:stop() end
    fog_menu.fog_sfc = nil
  end

  function fog_menu:on_started()
    self:display_fog()	
  end

  function fog_menu:on_finished()
    game:clear_fog()
  end

  function fog_menu:display_fog()	
    if type(self.fog) == "string" then
      self.fog_sfc = sol.surface.create("fogs/".. self.fog ..".png")
      self.fog_sfc:set_opacity(self.fog_opacity)
	  self.fog_size_x, self.fog_size_y = self.fog_sfc:get_size()
    
	  function restart_overlay_movement()
	    self.movement = sol.movement.create("straight")
	    self.movement:set_speed(self.fog_speed) 
	    self.movement:set_max_distance(((self.fog_size_x + self.fog_size_y) / 1.4) - 4)
	    self.movement:set_angle(self.fog_angle * math.pi / 4)
	    self.movement:start(self.fog_sfc, function()
		  self.fog_sfc:set_xy(self.fog_size_x, self.fog_size_y)
		  restart_overlay_movement()
	    end)
      end
	  restart_overlay_movement()
    end
  end

  function fog_menu:on_draw(dst_surface)
    local scr_x, scr_y = dst_surface:get_size()
	
	
    if self.fog ~= nil then
	  local camera_x, camera_y = game:get_map():get_camera_position()
	  local overlay_width, overlay_height = self.fog_sfc:get_size()
	  local x, y = camera_x, camera_y
	  x, y = -math.floor(x), -math.floor(y)
	  x = x % overlay_width - 2 * overlay_width
	  y = y % overlay_height - 2 * overlay_height
	  
	  local dst_y = y
	  while dst_y < scr_y + overlay_height do
	    local dst_x = x
	    while dst_x < scr_x + overlay_width do
	      self.fog_sfc:draw(dst_surface, dst_x, dst_y)
		  dst_x = dst_x + overlay_width
	    end
	    dst_y = dst_y + overlay_height
	  end
    end
  end
end
end--]]

return fog_manager