-- initialise Map behavior specific to this quest.

-- Variables
local map_meta = sol.main.get_metatable("map")

-- Include scripts
require ("scripts/multi_events")
local audio_manager = require("scripts/audio_manager")
local transition_finished_callback

function map_meta:wait_on_next_map_opening_transition_finished(callback)
	assert(type(callback) == 'function')
	transition_finished_callback = callback
end

map_meta:register_event("on_opening_transition_finished", function(map, destination)
		--print("End of built-in transition")

		local game = map:get_game()
		local hero = map:get_hero()
		local ground
		if game:get_value("tp_ground") == "hole" then
			hero:fall_from_ceiling(120, "jump", function()
				hero:play_ground_effect()
			end)
		end

		--call pending callback if any
		if transition_finished_callback then
			transition_finished_callback(map, destination)
			transition_finished_callback = nil
		end

end)

map_meta:register_event("on_started", function(map)
	local game = map:get_game()
	local hero = map:get_hero()
	local map_width, map_height = map:get_size()
	hero.respawn_point_saved=nil
	local ground
	if game:get_value("tp_ground") == "hole" then
		hero:set_visible(false)
	else
		hero:set_visible()
	end

	for enemy in map:get_entities("enemy_before_agahnim_") do
		if not game:is_step_done("castle_completed") then
			enemy:set_enabled(true)
		else enemy:set_enabled(false)
		end
	end

	for enemy in map:get_entities("enemy_after_agahnim_") do
		if game:is_step_done("castle_completed")
		and not game:is_step_done("dungeon_7_completed") then --temporary
			enemy:set_enabled(true)
		else enemy:set_enabled(false)
		end
	end
end)

map_meta:register_event("on_finished", function(map)
	if map:get_hero():is_running() then
		map:get_game().needs_running_restoration = true
	end
end)