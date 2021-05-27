-- Lua script of map out/i3n.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	game:show_map_name("cordinia_town")
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

if day_npc_witch ~= nil then
	function day_npc_witch:on_interaction()
		if game:get_value("possession_magic_powder") == nil and game:get_value("possession_mushroom") == nil then
			game:start_dialog("maps.out.cordinia.witch.needs_mushroom")
		end
	end

	function day_npc_witch:on_interaction_item(item)
		if item:get_name() == "trading_1" then
			if item:get_variant() == 1 then
				game:start_dialog("maps.out.cordinia.witch.trading_ask_straw", function(answer)
					if answer == 1 then
						hero:start_treasure("trading_1", 2)
					elseif answer == 2 then
						game:start_dialog("maps.out.cordinia.witch.trading_no_straw")
					end
				end)
			end
		end
		if item:get_name() == "mushroom" then
			game:start_dialog("maps.out.cordinia.witch.give_mushroom", function(answer)
				if answer == 1 then
					if game:is_step_done("dungeon_4_completed") then
						game:start_dialog("maps.out.cordinia.witch.powder_ready", function()
							hero:start_treasure("magic_powder")
						end)
					else
						game:start_dialog("maps.out.cordinia.witch.powder_not_ready")
					end
				end
			end)
		end
		hero:unfreeze()
	end
end

