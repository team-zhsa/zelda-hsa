-- Lua script of map out/a3.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
	random_walk(moving_npc)
	random_walk(moving_npc_1)
	random_walk(moving_npc_2)
	random_walk(moving_npc_3)
	random_walk(moving_npc_4)
	random_walk(moving_npc_5)
	random_walk(moving_npc_6)
	random_walk(moving_npc_7)
	random_walk(moving_npc_8)
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

