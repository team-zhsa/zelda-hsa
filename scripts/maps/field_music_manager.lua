-- This script adds to maps some functions that allow you to change the music between day and night.
--
-- Maps will have the following new functions:
-- field_music_manager:start_field_music().
--
-- Usage:
--
-- local field_music_manager = require("scripts/maps/field_music_manager")
--
-- map:register_event("on_draw", function(map)

  -- Music
  -- field_music_manager:init(map)

--end)

local field_music_manager = {}
local audio_manager = require("scripts/audio_manager")
require("scripts/multi_events")

function field_music_manager:init(map)
	local game = map:get_game()
	function field_music_manager:start_field_music()
    if game:is_step_last("priest_kidnapped") then
      sol.audio.play_music("cutscenes/cutscene_danger")
    else
      if game:get_value("time_of_day") == "day" or game:get_value("time_of_day") == nil then
        sol.audio.play_music("outside/hyrule_field_day")
      elseif game:get_value("time_of_day") == "night" then
        sol.audio.play_music("outside/hyrule_field_night")
      end
    end
	end
	field_music_manager:start_field_music()
end

return field_music_manager