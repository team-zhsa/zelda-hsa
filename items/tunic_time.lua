-- Tunic
local item = ...

function item:on_created()

  self:set_savegame_variable("possession_tunic_time")
	self:set_assignable(true)

end

function item:on_obtained(variant, savegame_variable)

  -- Give the built-in ability "tunic", but only after the treasure sequence is done.
  self:get_game():set_ability("tunic", 4)

end

function item:on_using()
	self:get_game():set_ability("tunic", 4)
	self:get_game():set_value("tunic_equipped", 4)
	self:get_map():get_hero():unfreeze()
end