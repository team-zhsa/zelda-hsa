local item = ...

function item:on_created()

  self:set_savegame_variable("possession_divine_ore_counter")
  self:set_amount_savegame_variable("amount_divine_ore_counter")
  self:set_assignable(false)

end