-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")
local field_music_manager = require("scripts/maps/field_music_manager")
local num_dialogue = 0

map:register_event("on_draw", function(map)
  field_music_manager:init(map)
end)

map:register_event("on_started", function()
	map:set_digging_allowed(true)
  game:show_map_name("east_castle")
	if game:is_step_done("sword_obtained") then
		for npc in map:get_entities("npc_soldier_") do
			npc:set_enabled(false)
		end
	end
end)

for npc in map:get_entities("npc_soldier_") do
	npc:register_event("on_interaction", function()
    print(num_dialogue)
    if num_dialogue == 0 and (game:get_time_of_day() == "dawn" or game:get_time_of_day() == "day" or game:get_time_of_day() == "sunset") then
      game:start_dialog("maps.out.east_castle.soldiers.soldiers_day")
      num_dialogue = 1
		elseif num_dialogue == 0 and (game:get_time_of_day() == "night" or game:get_time_of_day() == "twillight") then
			game:start_dialog("maps.out.east_castle.soldiers.soldiers_night")
			num_dialogue = 1
		elseif num_dialogue == 1 then
			game:start_dialog("maps.out.east_castle.soldiers.tip_lift")
			num_dialogue = 2
		elseif num_dialogue == 2 then
			game:start_dialog("maps.out.east_castle.soldiers.tip_sword")
			num_dialogue = 3
		elseif num_dialogue == 3 then
			game:start_dialog("maps.out.east_castle.soldiers.tip_speak")
			num_dialogue = 0
		end
	end)
end

function weak_door:on_opened()
	audio_manager:play_sound("common/secret_discover_minor")
end
