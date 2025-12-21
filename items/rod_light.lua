local item = ...

function item:on_created()

  self:set_savegame_variable("possession_rod_light")
  self:set_assignable(true)
  self:set_sound_when_brandished("items/get_major_item")

end

