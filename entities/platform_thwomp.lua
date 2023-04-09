--A generic platform, used by the Spiked Thwomp script to allows the hero to step safely on it

-- Variables
local entity = ...
local game = entity:get_game()
local hero = game:get_hero()
--local movement
-- Include scripts
--require("scripts/multi_events")

-- Event called when the custom entity is initialised.
--function entity:on_created()
entity:register_event("on_created", function()
  entity:set_traversable_by(false)
  entity:set_traversable_by("enemy", true)
  entity:set_visible(false)
end)

local function move_hero_with_me()

end

local function update_hero_position()
  local x,y,w,h=entity:get_bounding_box()
  local hx, hy, hw ,hh=hero:get_bounding_box()
  if hx<x+w and hx+hw>x and hy<=y+1 and hy+hh>=y-1 then
    local xx= hero:get_position()
    hero:set_position(xx, y-3)
  end
end

function entity:on_position_changed()
  update_hero_position()
end