-- Lua script of map out/a3.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local num_dialogue = 0

function guard_walk()
  local m = sol.movement.create("random_path")
  m:set_speed(50)
	m:start(npc_guard)
end

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function() 
	guard_walk()
	print(num_dialogue)
	game:show_map_name("kakarico_village")
	map:set_digging_allowed(true)
	if game:is_step_done("sahasrahla_lost_woods_map") then
		for npc in map:get_entities("npc_soldier_") do
			npc:set_enabled(false)
		end
	end
end)

for npc in map:get_entities("npc_soldier_") do
	npc:register_event("on_interaction", function()
		print(num_dialogue)
		if num_dialogue == 0 and game:get_time_of_day() == "dawn" or game:get_time_of_day() == "day" or game:get_time_of_day() == "sunset" then
			game:start_dialog("maps.out.kakarico_village.soldiers.soldiers_day")
			num_dialogue = 1
		elseif num_dialogue == 0 and game:get_time_of_day() == "night" or game:get_time_of_day() == "twillight" then
			game:start_dialog("maps.out.kakarico_village.soldiers.soldiers_night")
			num_dialogue = 1
		elseif num_dialogue == 1 then
			game:start_dialog("maps.out.kakarico_village.soldiers.tip_map")
			num_dialogue = 2
		elseif num_dialogue == 2 then
			game:start_dialog("maps.out.kakarico_village.soldiers.tip_shop")
			num_dialogue = 3
		elseif num_dialogue == 3 then
			game:start_dialog("maps.out.kakarico_village.soldiers.tip_speak")
			num_dialogue = 0
		end
	end)
end

function npc_camper:on_interaction()
	if not game:get_value("kakarico_bridge") then
		game:start_dialog("maps.out.kakarico_village.camper_1")
	elseif game:get_value("kakrico_bridge", 1) then
		game:start_dialog("maps.out.kakarico_village.camper_2")
	end
end

function npc_merchant:on_interaction()
	if not game:get_value("possession_bottle_1", 1) then
		game:start_dialog("maps.out.kakarico_village.bottle_merchant.merchant_welcome", function(answer)
			if answer == 1 then
				if game:get_money() >= 300 then
					game:start_dialog("maps.out.kakarico_village.bottle_merchant.merchant_yes", function()
						hero:start_treasure("bottle_1", 1)
					end)
				else
					game:start_dialog("_shop.not_enough_money")
				end
			else
				game:start_dialog("maps.out.kakarico_village.bottle_merchant.merchant_no")
			end
		end)
	else
		game:start_dialog("maps.out.kakarico_village.bottle_merchant.merchant_no_bottle")
	end
end