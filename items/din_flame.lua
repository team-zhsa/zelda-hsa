local item = ...

function item:on_created()

  self:set_savegame_variable("possession_din_flame")
  self:set_assignable(true)

end