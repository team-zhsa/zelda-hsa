return function(statue_owl_dungeon)
  
  -- Variables
  local game = statue_owl_dungeon:get_game()

-- Include scripts
  require("scripts/multi_events")
  
  statue_owl_dungeon:register_event("on_interaction", function(map, destination)

    local dialog = statue_owl_dungeon:get_property("dialogue_id")
    if game:has_dungeon_beak_of_stone()and dialog then
      local sprite = statue_owl_dungeon:get_sprite()
      sprite:set_animation("full")
      game:start_dialog(dialog, function()
        sprite:set_animation("normal")
     end)
    else
      game:start_dialog("maps.dungeons.owl")
    end
  end)
  
end


