-- Variables
local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite = entity:get_sprite()

-- Include scripts
require("scripts/multi_events")

-- Event called when the custom entity is initialised.
entity:register_event("on_created", function()

  entity:set_can_traverse("hero", false)
  local direction4 = math.random(4) - 1
  local m = sol.movement.create("straight")
  m:set_speed(0)
  m:start(entity)
  entity:go(direction4)

end)

entity:register_event("on_movement_finished", function()

  local direction4 = math.random(4) - 1
  entity:go(direction4)

end)

entity:register_event("on_obstacle_reached", function()

  local direction4 = math.random(4) - 1
  entity:go(direction4)

end)

function entity:go(direction4)

  -- Set the sprite.
  sprite:set_direction(direction4)

  -- Set the movement.
  local m = entity:get_movement()
  local max_distance = 40
  m:set_max_distance(max_distance)
  m:set_smooth(true)
  m:set_speed(20)
  m:set_angle(direction4 * math.pi / 2)
  
end