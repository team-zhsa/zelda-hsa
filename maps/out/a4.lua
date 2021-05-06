-- Lua script of map out/a5 - b5bis.
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

for teletransporter in map:get_entities("fake_t") do
  function teletransporter:on_activated()
    teletransporter:set_transition("fade")
    teletransporter:set_destination_map("out/a4")
    teletransporter:set_destination_name("return_d")
  end
end