--[[local light_manager = {}
local map_meta = sol.main.get_metatable("map")
local light_surface
local black = {0, 0, 0}
require("scripts/multi_events")


function light_manager:init(map)

  local screen_width = 320
  local screen_height = 240
  light_surface = sol.surface.create(screen_width, screen_height)
  local hero = map:get_entity("hero")
  local hero_x, hero_y = hero:get_center_position()
  local camera_x, camera_y = map:get_camera():get_bounding_box()
  local x = 320 - hero_x + camera_x
  local y = 240 - hero_y + camera_y
  local dark_surface = sol.surface.create("fogs/dark.png")
  dark_surface:draw_region(
    x, y, screen_width, screen_height, light_surface)
  if x < 0 then
    light_surface:fill_color(black, 0, 0, -x, screen_height)
  end

  if y < 0 then
    light_surface:fill_color(black, 0, 0, screen_width, -y)
  end

  local dark_surface_width, dark_surface_height = dark_surface:get_size()
  if x > dark_surface_width - screen_width then
    light_surface:fill_color(black, dark_surface_width - x, 0,
      x - dark_surface_width + screen_width, screen_height)
  end

  if y > dark_surface_height - screen_height then
    light_surface:fill_color(black, 0, dark_surface_height - y,
      screen_width, y - dark_surface_height + screen_height)
  end
  light_manager:update_light_level(map)
  map:register_event("on_draw", function(map, dst_surface)
      if map:get_light() == 1 then
        return
      end
      light_surface:draw(dst_surface, 0, 0)
    end)
  
end

function light_manager:check_is_light_active(map, torch_prefix)

  for torch in map:get_entities(torch_prefix) do
    if torch.is_lit and torch:is_lit() then
      return true
    end
  end
  return false

end

function light_manager:update_light_level(map)
  local total=0
  local lit=0
  for entity in map:get_entities() do

    if entity:get_type()=="custom_entity" and entity:get_model()=="torch" and entity:is_in_same_region(map:get_hero()) then
      total=total+1
      if entity.is_lit and entity:is_lit() then
        lit=lit+1
      end
    end
  end
  if total~=0 and light_surface~=nil then
--    debug_print ("Torches lit: "..lit.."/"..total, "opacity:"..150*(1-lit/total))
    map:set_light(lit/total)
    light_surface:set_opacity(150*(1-lit/total))
  else 
    map:set_light(1)
  end
end

function map_meta:get_light()

  return self.light or 1
end

function map_meta:set_light(light)

  self.light = light

end

-- Function called by the torch script when a torch state has changed.
function map_meta:torch_changed(torch)

  self.lit_torches = self.lit_torches or {}
  local lit = torch:is_lit()
  if lit then
    self.lit_torches[torch] = true
  else
    self.lit_torches[torch] = nil
  end
  light_manager:update_light_level(self)

end

return light_manager --]] --ALTTD VERSION

-------------------------------------------