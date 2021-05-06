-- Tunic
local item = ...

function item:on_created()

  self:set_savegame_variable("possession_blue_tunic")
	self:set_assignable(true)

end

function item:on_obtained(variant, savegame_variable)

  -- Give the built-in ability "tunic", but only after the treasure sequence is done.
  self:get_game():set_ability("tunic", 3)

end

function item:on_using()
	self:get_game():set_ability("tunic", 3)
	self:get_map():get_hero():unfreeze()
end