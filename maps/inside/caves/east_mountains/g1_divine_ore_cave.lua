-- Lua script of map inside/caves/east_mountains/divine_rock_cave.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local timer_manager = require("scripts/maps/timer_manager")
-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
	for tile in map:get_entities("tile_floor_") do
		tile:set_visible(false)
	end
	if not game:is_step_done("master_sword_obtained") then
		chest:set_enabled(false) end
end)

switch_floor:register_event("on_activated", function()
	sol.audio.play_sound("common/secret_discover_minor")
	for tile in map:get_entities("tile_floor_") do
		tile:set_visible(true)
	end

  timer_manager:start_timer(map, 5000, "countdown", function() --Timer for 15 seconds
		switch_floor:set_activated(false)
		for tile in map:get_entities("tile_floor_") do
			tile:set_visible(false)
		end
  end)

end)