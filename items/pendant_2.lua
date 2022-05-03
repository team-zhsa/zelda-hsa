local item = ...

function item:on_created()

  self:set_savegame_variable("possession_pendant_2")
  self:set_brandish_when_picked(true)

end