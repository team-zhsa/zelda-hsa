----------------------------------
--
-- A carriable entity that can be thrown and bounce like a ball.
-- Randomly change the entity direction at each bounce among all "stopped" ones.
--
----------------------------------

local dice = ...
local dice_sprite = dice:get_sprite()
local carriable_behavior = require("entities/lib/carriable")
carriable_behavior.apply(dice, {})

-- Set the stopped animation on bounce and randomly change the direction among all available ones.
dice:register_event("on_bounce", function(dice, num_bounce)
  dice_sprite:set_animation("stopped")
  dice:set_direction(math.random(0, dice:get_sprite():get_num_directions()-1))
end)