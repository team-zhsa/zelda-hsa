local item = ...

function item:on_created()

  self:set_savegame_variable("possession_pendant_3")
  self:set_brandish_when_picked(false)

end