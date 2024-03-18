local fog_manager = {}
local map_meta = sol.main.get_metatable("map")
local fog_surface
local black = {0, 0, 0}
require("scripts/multi_events")

fog_manager.overlay_angles = {
  3 * math.pi / 4,
  5 * math.pi / 4,
      math.pi / 4,
  7 * math.pi / 4
}
fog_manager.overlay_step = 1

-- Functions
function fog_manager:set_overlay(overlay)

  fog_manager.overlay = sol.surface.create("fogs/"..overlay..".png")
  fog_manager.overlay:set_opacity(96)
  fog_manager.overlay_offset_x = 0  -- Used to keep continuity when getting lost.
  fog_manager.overlay_offset_y = 0
  fog_manager.overlay_m = sol.movement.create("straight")
  fog_manager.restart_overlay_movement()

end

function fog_manager:restart_overlay_movement()

  fog_manager.overlay_m:set_speed(16) 
  fog_manager.overlay_m:set_max_distance(100)
  fog_manager.overlay_m:set_angle(fog_manager.overlay_angles[fog_manager.overlay_step])
  fog_manager.overlay_step = fog_manager.overlay_step + 1
  if fog_manager.overlay_step > #fog_manager.overlay_angles then
    fog_manager.overlay_step = 1
  end
  fog_manager.overlay_m:start(fog_manager.overlay, function()
    fog_manager:restart_overlay_movement()
  end)

end

map_meta:register_event("on_draw", function(map, destination_surface)

  -- Make the overlay scroll with the camera, but slightly faster to make
  -- a depth effect.
  local camera_x, camera_y = map:get_camera():get_position()
  local overlay_width, overlay_height = fog_manager.overlay:get_size()
  local screen_width, screen_height = destination_surface:get_size()
  local x, y = camera_x + fog_manager.overlay_offset_x, camera_y + fog_manager.overlay_offset_y
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
      fog_manager.overlay:draw(destination_surface, dst_x, dst_y)
      dst_x = dst_x + overlay_width
    end
    dst_y = dst_y + overlay_height
  end

end)


--[[
function fog_manager:init(map)

  local screen_width = 320
  local screen_height = 240
  fog_surface = sol.surface.create(screen_width, screen_height)
  local hero = map:get_entity("hero")
  local hero_x, hero_y = hero:get_center_position()
  local camera_x, camera_y = map:get_camera():get_bounding_box()
  local x = 320-- - hero_x + camera_x
  local y = 240-- - hero_y + camera_y
  local dark_surface = sol.surface.create("fogs/desert_fog.png")
  dark_surface:draw_region(
    x, y, screen_width, screen_height, fog_surface)
  map:register_event("on_draw", function(map, dst_surface)
      fog_surface:draw(dst_surface, 0, 0)
    end)
  
end--]]

return fog_manager