local item = ...

function item:on_created()
  self:set_savegame_variable("possession_crystal_7")
  self:set_brandish_when_picked(true)
  self:set_sound_when_brandished(nil)
end