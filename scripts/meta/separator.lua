local separator_meta = sol.main.get_metatable("separator") 

separator_meta:register_event("on_activated", function()
	local game = separator:get_game()
  local hero=game:get_hero()
	local d = hero:get_direction() * 2
	hero:walk(hero:get_direction() * 2 .. hero:get_direction() * 2 .. hero:get_direction() * 2 .. hero:get_direction() * 2)
end)