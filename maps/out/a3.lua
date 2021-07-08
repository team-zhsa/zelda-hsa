-- Lua script of map out/a3.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

function guard_walk()
  local m = sol.movement.create("random_path")
  m:set_speed(50)
	m:start(npc_guard)
end

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
	guard_walk()
	game:show_map_name("kakarico_village")
	map:set_digging_allowed(true)
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
		game:start_dialog("maps.out.kakarico_village.shop_1", function(answer)
			if answer == 1 then
				if game:get_money() >= 300 then
					game:start_dialog("maps.out.kakarico_village.shop_3", function()
						hero:start_treasure("bottle_1", 1)
					end)
				else
					game:start_dialog("_shop.not_enough_money")
				end
			else
				game:start_dialog("maps.out.kakarico_village.shop_4")
			end
		end)
	else
		game:start_dialog("maps.out.kakarico_village.shop_5")
	end
			
end