-- Initialize door behavior specific to this quest.

-- Variables
local door_meta = sol.main.get_metatable("door")

-- Include scripts
local sound_is_playing = false
local audio_manager = require("scripts/audio_manager")
require("scripts/multi_events")

door_meta:register_event("on_created", function(door)
  
  local sprite = door:get_sprite()
  local game = door:get_game()
  sprite:register_event("on_animation_changed", function(sprite, animation)
    -- Opening animation  
    if sprite:get_animation() == "opening" and sound_is_playing == false then
      sound_is_playing = true
      audio_manager:play_sound("common/door/mecanical_open")
      sol.timer.start(game, 50, function()
        sound_is_playing = false
      end)
    end
    -- Closing animation  
    if sprite:get_animation() == "closing" and sound_is_playing == false then
      sound_is_playing = true
      audio_manager:play_sound("common/door/stone_slam")
      sol.timer.start(game, 50, function()
        sound_is_playing = false
      end)
    end
  end)
end)
