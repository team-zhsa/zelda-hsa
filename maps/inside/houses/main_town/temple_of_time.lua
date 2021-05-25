-- Lua script of map inside/houses/main_town/temple_of_time.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")

map:register_event("on_started", function()
	sword:set_traversable(true)
end)

-- Event called at initialization time, as soon as this map is loaded.
function cutscene_trigger:on_interaction()
	if game:is_step_done("dungeon_3_completed") then
		map:set_cinematic_mode(true)
		local sprite = hero:get_sprite()
		sprite:set_animation("pulling")
		local movement = sol.movement.create("straight")
		sword:bring_to_front()
		movement:set_speed(8)
		movement:set_max_distance(16)
		movement:set_angle(math.pi/2)
		movement:set_ignore_obstacles(true)
		movement:start(sword)
		sol.audio.play_music("cutscenes/master_sword", function()
			sol.audio.stop_music()
			map:set_cinematic_mode(false)
			sword:remove()
		end)
	end
end