-- Variables
local entity = ...
local game = entity:get_game()
local map = entity:get_map()

-- Include scripts
require("scripts/multi_events")

-- Event called when the custom entity is initialised.
entity:register_event("on_created", function()
    
  local sprite = entity:get_sprite()
  function sprite:on_animation_finished(animation)
    if animation == "walking" then
      sprite:set_animation("stopped")
      local delay = math.random(5000)
      sol.timer.start(entity, delay, function()
        sprite:set_animation("walking")
      end)
    end
  end
  local delay = math.random(5000)
  sol.timer.start(entity, delay, function()
    sprite:set_animation("walking")
  end)

end)
