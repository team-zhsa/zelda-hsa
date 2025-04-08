-- Variables
local map = ...
local game = map:get_game()
local is_small_boss_active = false

-- Include scripts
require("scripts/multi_events")
local audio_manager = require("scripts/audio_manager")
local door_manager = require("scripts/maps/door_manager")
local enemy_manager = require("scripts/maps/enemy_manager")
local separator_manager = require("scripts/maps/separator_manager")
local switch_manager = require("scripts/maps/switch_manager")
local treasure_manager = require("scripts/maps/treasure_manager")
local is_boss_active = false
-- Map events


map:register_event("on_started", function()
	separator_manager:manage_map(map)
	if heart_container ~= nil and boss ~= nil then
		treasure_manager:disappear_pickable(map, "heart_container")
		treasure_manager:disappear_pickable(map, "pendant")
	end
	
	for stream in map:get_entities("stream_down") do
			sol.timer.start(map, math.random(4, 15) * 500, function()
				if stream:get_direction() < 4 then
					stream:set_direction(6)
				elseif stream:get_direction() > 4 then
					stream:set_direction(2)
				end
				return true
			end)
	end
end)

-- Boss events
if boss ~= nil then
	function sensor_boss:on_activated()
		sol.audio.play_music("boss/boss_albw")
		sensor_boss:remove()
		hero:save_solid_ground()
	end

	function boss:on_dead()
		treasure_manager:appear_pickable(map, "heart_container")
		treasure_manager:appear_pickable(map, "pendant")
	end
end

if pendant ~= nil then
	function map:on_obtained_treasure(item, variant, savegame_variable)
		if item:get_name() == "pendant_3" then
			enemy_manager:start_completing_sequence(map)
			game:set_step_done("dungeon_3_completed")
		end
	end
end