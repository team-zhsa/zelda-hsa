return function(mudora)
  
  -- Variables
    local hero = mudora:get_map():get_hero()
    local game = mudora:get_game()
    local map = mudora:get_map()
    local name = mudora:get_name()
    
  mudora:register_event("on_interaction", function()
    -- NPCs prefixed by "mudora" need the Book of Mudora in order to be read properly.
    if name:match("^npc_mudora") then
      if game:get_value("possession_book_of_mudora", true) then
        local dialog_id = mudora:get_property("dialog_id")
        if dialog_id ~= nil then
          game:start_dialog(dialog_id)
        end
      else
        game:start_dialog("_cannot_read_without_book_mudora")
      end
    end
  end)

end