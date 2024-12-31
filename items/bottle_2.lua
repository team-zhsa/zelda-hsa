local item = ...

function item:on_created()
  self:set_assignable(true)
  self:set_savegame_variable("possession_bottle_2")
  self:set_sound_when_brandished("items/get_sidequest_major_item")
end

local bottle_script = require("items/bottle")
bottle_script(item)
