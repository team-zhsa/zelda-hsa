-- Lua script of map inside/caves/goron_1f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local auto_npc = map:get_entities("auto_npc")

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
	local movement = sol.movement.create("random_path")
		movement:start(goron)
end

function goron_rock:on_interaction()
	if not game:get_value("quest_rock") or game:get_value("quest_rock", 0) then
		game:set_value("quest_rock", 0)
		game:start_dialog("maps.caves.goron.rock_ask", function(answer)
			if answer == 1 then
			game:start_dialog("maps.caves.goron.rock_yes")
			game:set_value("quest_rock", 1)
			elseif answer == 2 then
			game:start_dialog("maps.caves.goron.rock_no")
			end
		end)
	end
end

for npc in map:get_entities("goron") do
	function npc:on_interaction()
		local rand = math.random(1,4)
		if rand == 1 then
			print("rand 1")
			game:start_dialog("maps.caves.goron.generic_1")
		elseif rand == 2 then
			print("rand 2")
			game:start_dialog("maps.caves.goron.generic_2")
		elseif rand == 3 then
			print("rand 3")
			game:start_dialog("maps.caves.goron.generic_3")
		elseif rand == 4 then
			print("rand 4")
			game:start_dialog("maps.caves.goron.generic_4")
		end
	end
end