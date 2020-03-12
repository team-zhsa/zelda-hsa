-- Variables
local entity = ...
local game = entity:get_game()
local map = entity:get_map()

-- Include scripts
local audio_manager = require("scripts/audio_manager")

entity:add_collision_test("touching", function(entity, other)

  if other:get_type()=="hero" then --hurt the hero ad make it bounce up on contact
    other.vspeed=-4
    if not other:is_invincible() then
      entity:get_game():remove_life(2)
      other:set_invincible(true, 500)
      other:set_blinking(true, 500)
      audio_manager:play_sound("hero/hurt")
    end
  end
end)