-- Lua script of map out/a2.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local x, y, layer = hero:get_position()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	game:show_map_name("hylia_lake")
  -- You can initialize the movement and sprites of various
  
	map:set_digging_allowed(true)
end
