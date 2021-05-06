local fog_manager = {}
local map_meta = sol.main.get_metatable("map")
local fog_surface
local black = {0, 0, 0}
require("scripts/multi_events")

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
  
end

return fog_manager