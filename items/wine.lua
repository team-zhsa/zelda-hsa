local item = ...

function item:on_created()

  self:set_savegame_variable("possession_drug")
  item:set_assignable(true)
end

function item:on_used()
  game:add_life(8)
  game:add_magic(5)
  if game:get_ability("swim", 1) then
    game:set_ability("swim", 0, function()
      sol.timer.start(15000, function()
        game:set_ability("swim", 1)
      end)        
    end)
  end
end

