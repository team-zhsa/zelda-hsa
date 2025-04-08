local separator_meta = sol.main.get_metatable("separator") 

separator_meta:register_event("on_activated", function(separator)
	local game = separator:get_game()
	local hero = game:get_hero()
	local map = hero:get_map()
	local d = hero:get_direction() * 2
	if game:is_in_inside_world() then
		--hero:walk(d..d..d..d)
	end
end)