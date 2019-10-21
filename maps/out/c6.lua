-- Lua script of map outside/c6.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

for teletransporter in map:get_entities() do
  function teletransporter:on_activated()
    hero:teleport("out/c6", "respawn")
  end
end

function map:on_started()
  sol.surface.create("fogs/desert_fog.png")
end

function map:on_draw()
  sol.surface.create("fogs/desert_fog.png")
end