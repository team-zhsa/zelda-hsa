return function(mario)
  
  -- Variables
  local game = mario:get_game()
  local map = mario:get_map()

-- Include scripts
  require("scripts/multi_events")
  local audio_manager = require("scripts/audio_manager")
  
  mario:register_event("on_interaction", function(map, destination)

    local music_random = math.random(4) 
    audio_manager:play_sound("mario" .. music_random)

  end)
  
end


