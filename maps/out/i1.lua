local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")
local door_manager = require("scripts/maps/door_manager")
local enemy_manager = require("scripts/maps/enemy_manager")
local separator_manager = require("scripts/maps/separator_manager")
local switch_manager = require("scripts/maps/switch_manager")
local treasure_manager = require("scripts/maps/treasure_manager")

-- Map events
map:register_event("on_started", function(map, destination)
	game:set_world_snow_mode("outside_world", "snowstorm")
	game:show_map_name("snowpeaks")
	map:set_digging_allowed(true)
end)

function map:on_finished()
	game:set_world_snow_mode("outside_world", nil)
end
