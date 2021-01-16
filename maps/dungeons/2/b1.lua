-- Lua script of map dungeons/2/b1.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

for npc in map:get_entities("magic_booth") do
	function magic_booth:on_interaction()
		if not game:get_value("dungeon_2_crossing_puzzle") then
			game:start_dialog("maps.dungeons.2.hint.arrows")
		elseif not game:get_value("dungeon_2_holes_puzzle") then
			game:start_dialog("maps.dungeons.2.hint.holes")
		elseif not game:get_value("dungeon_2_cyclop_puzzle") then
			game:start_dialog("maps.dungeons.2.hint.cyclop")
		end
	end
end

function sensor_cross_puzzle:on_activated()
	game:set_value("puzzle_cross_from_south", 1)
	wall_cross_puzzle:set_enabled(false)
	wall_cross_puzzle_4:set_enabled(false)
	sensor_cross_puzzle_4:set_enabled(false)
end

function sensor_cross_puzzle_3:on_activated()
	game:set_value("puzzle_cross_from_east", 1)
	wall_cross_puzzle_2:set_enabled(false)
	wall_cross_puzzle_4:set_enabled(false)
	sensor_cross_puzzle_2:set_enabled(false)
end

function sensor_cross_puzzle_2:on_activated()
	game:set_value("puzzle_cross_from_north", 1)
	wall_cross_puzzle_2:set_enabled(false)
	wall_cross_puzzle_3:set_enabled(false)
	sensor_cross_puzzle_4:set_enabled(false)
end

function sensor_cross_puzzle_4:on_activated()
	game:set_value("puzzle_cross_from_north", 1)
	wall_cross_puzzle:set_enabled(false)
	wall_cross_puzzle_3:set_enabled(false)
	sensor_cross_puzzle:set_enabled(false)
end

local function teleport_sensor(to_sensor, from_sensor)
  local hero_x, hero_y = hero:get_position()
  local to_sensor_x, to_sensor_y = to_sensor:get_position()
  local from_sensor_x, from_sensor_y = from_sensor:get_position()
 
  hero:set_position(hero_x - from_sensor_x + to_sensor_x, hero_y - from_sensor_y + to_sensor_y)
end
 
function sensor_corridor_from_13:on_activated()
  teleport_sensor(sensor_corridor_to_13, self)
end
 
function sensor_corridor_from_25:on_activated()
  teleport_sensor(sensor_corridor_to_25, self)
end