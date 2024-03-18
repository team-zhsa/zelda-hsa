local map = ...
local game = map:get_game()
local minigame_manager = require("scripts/maps/minigame_manager")
local fog_manager = require("scripts/maps/fog_manager")
-- Events

map:register_event("on_started", function(destination)
	fog_manager:set_overlay("forest")
	map:set_digging_allowed(true)
	game:show_map_name("faron_woods")
	
	if not minigame_manager:is_playing(map, "marathon") then
		npc_marathon:set_enabled(false)
	end
	
end)

npc_marathon:register_event("on_interaction", function()
	if not minigame_manager:is_playing(map, "marathon") then
		game:start_dialog("maps.out.faron_woods.marathon_man.marathon_already_finished")
	else
		minigame_manager:end_minigame(map, "marathon")
		if (game:get_value("marathon_minigame_time")
		< game:get_value("marathon_minigame_time_limit")) then
			-- New record
			game:start_dialog("maps.out.faron_woods.marathon_man.marathon_finished_lower", game:get_value("marathon_minigame_time"), function()

				sol.timer.start(map, 100, function()
					-- Select the treasure
					if not game:get_value("outside_marathon_minigame_piece_of_heart")
					and not game:get_value("outside_marathon_minigame_rupees") then
						game:start_dialog("maps.out.faron_woods.marathon_man.marathon_piece_of_heart", function()
							hero:start_treasure("piece_of_heart", 1, "outside_marathon_minigame_piece_of_heart")
						end)
					elseif not game:get_value("outside_marathon_minigame_rupees") then
						game:start_dialog("maps.out.faron_woods.marathon_man.marathon_rupees", function()
							hero:start_treasure("rupee", 5, "outside_marathon_minigame_rupees")
						end)
					else
						game:start_dialog("maps.out.faron_woods.marathon_man.marathon_rupees", function()
							hero:start_treasure("rupee", 3)
						end)
					end
				end)

			end)
		else game:start_dialog("maps.out.faron_woods.marathon_man.marathon_finished_higher")
		end
	end
end)