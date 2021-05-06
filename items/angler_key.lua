local item = ...

function item:on_created()

  self:set_savegame_variable("possession_angler_key")
  self:set_sound_when_brandished("common/big_item")

end

