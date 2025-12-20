local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")
local door_manager = require("scripts/maps/door_manager")
local enemy_manager = require("scripts/maps/enemy_manager")
local separator_manager = require("scripts/maps/separator_manager")
local switch_manager = require("scripts/maps/switch_manager")
local treasure_manager = require("scripts/maps/treasure_manager")

npc_soldier:register_event("on_interaction", function()
  if game:is_step_last("ocarina_obtained") then
    game:start_dialog("maps.houses.castle_town.vase_house.soldier_no_magic_bar")
  elseif not game:is_step_done("world_map_obtained") then
    game:start_dialog("maps.houses.castle_town.vase_house.soldier_gate_closed")
  else game:start_dialog("maps.houses.castle_town.vase_house.soldier_gate_open")
  end
end)
