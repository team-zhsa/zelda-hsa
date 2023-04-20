local item = ...

function item:on_created()
  self:set_savegame_variable("possession_monster_gut_counter")
  self:set_amount_savegame_variable("amount_monster_gut_counter")
  self:set_max_amount(20)
  self:set_assignable(false)
end
