local item = ...

function item:on_created()

  self:set_savegame_variable("possession_farore_quake")
  self:set_assignable(true)

end