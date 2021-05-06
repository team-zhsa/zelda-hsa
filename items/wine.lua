local item = ...
local game = item:get_game()
local map = item:get_map()


function item:on_created()

  self:set_savegame_variable("possession_wine")
  item:set_assignable(true)
end

function item:on_using()
	local hero = game:get_hero()
	hero:start_poison(1, 1000, game:get_max_life() - 4)
	hero:unfreeze()
end

function item:on_finished()	
end