-- initialise door behavior specific to this quest.

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
      local sprite_id = sprite:get_animation_set()
      if sprite_id:match("key") then
        audio_manager:play_sound("common/door_unlocked")
      elseif sprite_id:match("normal") then
        audio_manager:play_sound("common/door_open")
      end
      sol.timer.start(game, 50, function()
        sound_is_playing = false
      end)
    end
    -- Closing animation  
    if sprite:get_animation() == "closing" and sound_is_playing == false then
      sound_is_playing = true
      audio_manager:play_sound("common/door_close")
      sol.timer.start(game, 50, function()
        sound_is_playing = false
      end)
    end
  end)
end)
