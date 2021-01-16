-- Variables
local trial_manager = {}

-- Include scripts
local audio_manager = require("scripts/audio_manager")
require("scripts/multi_events")

function trial_manager:init_map(map)
  
  teletransporter:set_enabled(false)
  local enemy_prefix = "enemy_group_level_"
  for enemy in map:get_entities(enemy_prefix) do
    enemy:register_event("on_dead", function()
      if map:get_entities_count(enemy_prefix) == 0 then
        trial_manager:teletransporter_appear()
        audio_manager:play_music("gb/23_boss_defeated")
      end
    end)
  end
  
end

function trial_manager:teletransporter_appear()
  
  -- Activate teletransporter next map
  
end

return trial_manager