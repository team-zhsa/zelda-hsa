-- Lua script of map dungeons/1/b1.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")
local door_manager = require("scripts/maps/door_manager")
local enemy_manager = require("scripts/maps/enemy_manager")
local separator_manager = require("scripts/maps/separator_manager")
local switch_manager = require("scripts/maps/switch_manager")
local treasure_manager = require("scripts/maps/treasure_manager")
local is_boss_active = false

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
	map:set_doors_open("door_group_boss", true)
	separator_manager:manage_map(map)
	if heart_container ~= nil then
		treasure_manager:disappear_pickable(map, "heart_container")
	end
  -- You can initialize the movement and sprites of various
  -- map entities here.
end)

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.

-- Boss events
if boss ~= nil then
	function sensor_boss:on_activated()
		map:close_doors("door_group_boss")
		sol.audio.play_music("boss/boss_albw")
		sensor_boss:remove()
	end

	function boss:on_dead()
		treasure_manager:appear_pickable(map, "heart_container")
		map:open_doors("door_group_boss")
	end
end

if pendant ~= nil then
	function map:on_obtained_treasure(item, variant, savegame_variable)
  	if item:get_name() == "pendant_1" then
			sol.audio.play_music("cutscenes/victory", function()
				sol.audio.stop_music()
				hero:start_victory(function()
					game:set_magic(game:get_max_magic())
					hero:teleport("out/a1", "from_dungeon")
				end)
			end)
  	end
	end
end