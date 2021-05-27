-- Trading sequence for Seas Map
local item = ...
local game = item:get_game()

function item:on_created()
	self:set_assignable(true)
  self:set_savegame_variable("possession_trading_1")
  self:set_sound_when_brandished("common/big_item")

end

function item:on_obtained(variant, savegame_variable)
  if variant == 7 then
    hero:start_treasure("seas_map")
  end
end