-- Lua script of map dungeon_16/1f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()

map:set_doors_open("door_a")
map:set_doors_open("door_b")

  -- You can initialize the movement and sprites of various
  -- map entities here.
local movement = sol.movement.create("random_path")
movement:set_speed(64)
movement:start(tile)
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function door_a_2:on_activated()

map:close_doors("door_a")

end

function door_b:on_activated()

map:close_doors("door_b_2")

end