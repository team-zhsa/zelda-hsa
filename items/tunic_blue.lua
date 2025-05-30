-- Tunic
local item = ...

function item:on_created()
	item:set_sound_when_brandished("items/get_major_item")
  self:set_savegame_variable("possession_tunic_blue")
	self:set_assignable(true)

end

function item:on_obtained(variant, savegame_variable)

  -- Give the built-in ability "tunic", but only after the treasure sequence is done.
  self:get_game():set_ability("tunic", 2)

end

function item:on_using()
	self:get_game():set_ability("tunic", 2)
	self:get_game():set_value("tunic_equipped", 2)
	self:get_map():get_hero():unfreeze()
end