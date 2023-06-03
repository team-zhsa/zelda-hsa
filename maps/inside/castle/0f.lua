-- Inside - Marine's House

-- Variables
local map = ...
local game = map:get_game()

map:register_event("on_started", function()
	if not game:is_step_done("sword_obtained") then
		audio_manager:play_music("cutscenes/raining")
	else audio_manager:play_music("inside/castle")
		bed:get_sprite():set_animation("empty_open")
	end
end)

-- Methods - Functions
for npc in map:get_entities("npc_soldier_") do
  npc:register_event("on_interaction", function()
    if not game:is_step_done("ocarina_obtained") then
      game:start_dialog("maps.houses.hyrule_castle.soldiers_impa_waiting")
    elseif game:is_step_done("ocarina_obntained") then
      game:start_dialog("maps.houses.hyrule_castle.soldiers_training")
    end
  end)
end

