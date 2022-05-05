-- Trading sequence for Seas Map
local item = ...
local game = item:get_game()

function item:on_created()
	self:set_assignable(true)
  self:set_savegame_variable("possession_trading_2")
  self:set_sound_when_brandished("common/big_item")

end

function item:on_obtained(variant, savegame_variable)
  if variant == 6 then
    self:get_game():get_hero():start_treasure("magic_bar", 2)
  end
end