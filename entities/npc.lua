--[[
  Custom NPc : allows to walk through it and still be able to talk to it.
  It was made to implement the fisherman from Link's awakening, allowing the hero to jump on his boat while swimming under him.
  --]]

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
require("scripts/multi_events")

entity:set_can_traverse("custom_entity", false)

entity:register_event("on_interaction", function()
    
  local dialog=entity:get_property("dialog")
  if dialog and sol.language.get_dialog(dialog) then --Safety measures: do not trigger a non-existing dialog 
    game:start_dialog(dialog)
  end
  
end)