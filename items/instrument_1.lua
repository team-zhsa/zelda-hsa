local item = ...

function item:on_created()

  self:set_savegame_variable("possession_pendant_1")
  self:set_brandish_when_picked(true)

end

function item:on_obtaining(variant, savegame_variable)
end