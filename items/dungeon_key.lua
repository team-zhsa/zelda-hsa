local item = ...

function item:on_created()
  self:set_savegame_variable("has_dungeon_key")
  self:set_assignable(true)
end