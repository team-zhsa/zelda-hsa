-- Lua script of map dungeons/11/1f.
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

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  separator_manager:manage_map(map)
  map:set_doors_open("door_9_w", false)
  door_manager:open_when_torches_lit(map, "torch_2_door_", "door_8_e")
  door_manager:close_when_torches_unlit(map, "torch_2_door_", "door_8_e")
  door_manager:open_when_switch_activated(map, "switch_9_door", "door_9_w")
  -- You can initialise the movement and sprites of various
  -- map entities here.
end)

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end
