-- Lua script of map outside/c6.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local fog = sol.surface.create("fogs/desert_fog.png")


for teletransporter in map:get_entities() do
  function teletransporter:on_activated()
    hero:teleport("out/c6", "respawn")
  end
end

function map:on_draw(dst_surface)
	fog:draw(dst_surface)
	fog:set_opacity(220)
end