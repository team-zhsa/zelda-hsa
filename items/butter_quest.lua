-- Butter (has several variables)
local item = ...

function item:on_created()

  self:set_savegame_variable("possession_butter")
  self:set_sound_when_brandished("common/sidequest_major_item")

end
