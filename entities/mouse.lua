-- Variables
local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local movement

-- Include scripts
require("scripts/multi_events")

-- Event called when the custom entity is initialised.
entity:register_event("on_created", function()

  entity:start_movement()
  sol.timer.start(entity, 50, function()
    local direction = movement:get_direction4()
    entity:get_sprite():set_direction(direction)
    return true
  end)

end)

function entity:start_movement()

  entity:go_random()
  local duration = 500 + math.random(1000)
  sol.timer.start(entity, duration, function()
    entity:stop_movement()
  end)

end

function entity:stop_movement()

  local duration = 500 + math.random(1000)
  entity:get_sprite():set_animation("waiting")
  movement:stop()
  sol.timer.start(entity, duration, function()
    entity:start_movement()
  end)

end

function entity:go_random()

  entity:get_sprite():set_animation("walking")
  movement = sol.movement.create("random")
  movement:set_speed(32)
  movement:start(entity)
  
end


