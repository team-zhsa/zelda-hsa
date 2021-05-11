local item = ...
local game = item:get_game()

function item:on_created()

  item:set_savegame_variable("possession_pegasus_shoes")
  item:set_assignable(true)
  game:set_ability("run", 1)
end

function item:on_using()

  local hero = game:get_hero()
  hero:start_running()
  item:set_finished()
end

function item:on_variant_changed(variant)

  if variant > 1 then
    -- Allow to run with the action command
    -- when the boots are not broken.
    game:set_ability("run", 1)
  else
    game:set_ability("run", 0)
  end
end

