-- Inside - Marine's House

-- Variables
local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")
local effect_manager = require('scripts/maps/effect_manager')
local gb = require('scripts/maps/gb_effect')
local fsa = require('scripts/maps/fsa_effect')
local black_surface

map:register_event("on_started", function()
	if not game:is_step_done("sword_obtained") then
		sol.audio.play_music("cutscenes/raining")
	else sol.audio.play_music("inside/castle")	end
end)

-- Methods - Functions
for npc in map:get_entities("npc_soldier_") do
  npc:register_event("on_interaction", function()
    if not game:is_step_done("ocarina_obtained") then
      game:start_dialog("maps.houses.hyrule_castle.soldiers_impa_waiting")
    elseif game:is_step_done("ocarina_obtained") then
      game:start_dialog("maps.houses.hyrule_castle.soldiers_training")
    end
  end)
end

