local item = ...

function item:on_created()

  self:set_savegame_variable("possession_photo_counter")
  self:set_amount_savegame_variable("amount_photo_counter")
  self:set_assignable(false)
end