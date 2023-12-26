-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
local audio_manager = require("scripts/audio_manager")
local field_music_manager = require("scripts/maps/field_music_manager")

map:register_event("on_draw", function(map)
  field_music_manager:init(map)
end)

map:register_event("on_started", function(destination)
	map:set_digging_allowed(true)
  game:show_map_name("east_castle")

  if game:is_step_last("master_sword_obtained") then
    map:set_cinematic_mode(true)
    game:get_dialog_box():set_style("empty")
    sol.audio.play_music("cutscenes/cutscene_zelda")
    sol.timer.start(map, 1000, function ()      
      game:start_dialog("maps.out.hyrule_town.zelda_go_to_castle", game:get_player_name(), function()
        game:get_dialog_box():set_style("box")
        game:set_step_done("zelda_kidnapped")
        map:set_cinematic_mode(false)
      end)
    end)
  end

end)