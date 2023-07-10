----------------------------------
--
-- A carriable bomb entity that can be thrown and explode after some time.
-- Reset the timer each time the bomb is carried.
--
----------------------------------

-- Global variables.
local bomb = ...
local audio_manager = require("scripts/audio_manager")
local carriable_behavior = require("entities/lib/carriable")
carriable_behavior.apply(bomb, {is_offensive = false})

local map = bomb:get_map()
local sprite = bomb:get_sprite()
local exploding_timer, blinking_timer

-- Configuration variables.
local countdown_duration = tonumber(bomb:get_property("countdown_duration")) or 2000
local blinking_duration = 1000

-- Make the bomb explode.
local function explode()

  local x, y, layer = bomb:get_position()
  map:create_custom_entity({
    model = "explosion",
    direction = 0,
    x = x,
    y = y - 5,
    layer = layer,
    width = 16,
    height = 16,
    properties = {
      {key = "explosive_type_1", value = "crystal"},
      {key = "explosive_type_2", value = "destructible"},
      {key = "explosive_type_3", value = "door"},
      {key = "explosive_type_4", value = "enemy"},
      {key = "explosive_type_5", value = "sensor"}
    }
  })
  bomb:remove()
  audio_manager:play_sound("explosion")
end

-- Start the countdown before explosion.
local function start_countdown()

  exploding_timer = sol.timer.start(bomb, countdown_duration, function()
    explode()
  end)
  blinking_timer = sol.timer.start(bomb, math.max(0, countdown_duration - blinking_duration), function()
    blinking_timer = nil
    sprite:set_animation("stopped_explosion_soon")
  end)
end

-- Stop the exploding timer on carrying.
bomb:register_event("on_carrying", function(bomb)
  exploding_timer:stop()
  if blinking_timer then
    blinking_timer:stop()
  end
end)

-- Restart the bomb timer before exploding on thrown.
bomb:register_event("on_thrown", function(bomb, direction)

  start_countdown()
end)

-- Setup traversable rules and start the bomb timer before exploding.
bomb:register_event("on_created", function(bomb)

  start_countdown()
  audio_manager:play_sound("bomb")
end)
