local item = ...

function item:on_created()

  self:set_savegame_variable("possession_golden_leaf_counter")
  self:set_amount_savegame_variable("amount_golden_leaf_counter")
  self:set_assignable(false)
end