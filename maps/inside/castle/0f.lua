-- Inside - Marine's House

-- Variables
local map = ...
local game = map:get_game()

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

