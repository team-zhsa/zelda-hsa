local item = ...
local game = item:get_game()

function item:on_created()

  self:set_shadow("small")
  self:set_sound_when_picked("common/get_small_item1")
  self:set_sound_when_brandished("common/get_small_item1")
end

function item:on_obtained()
	game:set_life(game:get_max_life())
end