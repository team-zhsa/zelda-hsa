return function(statue_owl_outside)
  
  -- Variables
  local game = statue_owl_outside:get_game()

-- Include scripts
  require("scripts/multi_events")
  
  statue_owl_outside:register_event("on_interaction", function(map, destination)

    local dialog = statue_owl_outside:get_property("dialog")
    local sprite = statue_owl_outside:get_sprite()
    sprite:set_ignore_suspend(true)
    if dialog then
      sprite:set_animation("talking")
      game:start_dialog(dialog, function()
        sprite:set_animation("normal")
      end)
    end
  end)
  
end


