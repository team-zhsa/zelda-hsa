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
	treasure_manager:appear_heart_container_if_boss_dead(map)
	treasure_manager:disappear_pickable(map, "heart_container")
  -- You can initialize the movement and sprites of various
  -- map entities here.
end)

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.

function chest_pendant:on_opened()
	audio_manager:play_music("cutscenes/victory", function()
		audio_manager:stop_music()
	end)
end
-- BOSS
function sensor_boss:on_activated()
	 if is_boss_active == false then
    is_boss_active = true
    enemy_manager:launch_boss_if_not_dead(map)
  end
end
