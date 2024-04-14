-- Lua script of map out/i3n.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
map.seen = false
-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
	game:show_map_name("cordinia_town")
	map:set_digging_allowed(true)
	setup_guard_paths()
	setup_guard_sensors()
end)

function setup_guard_paths()
	for guard in map:get_entities("guard_") do
		local guard_path_step = 1
		local function find_next_target()
			local next_step = "target_"..guard:get_name().."_" .. guard_path_step
			if map:get_entity(next_step) == nil then
				guard_path_step = 1
				find_next_target()
			else
				local movement = sol.movement.create("target")
				movement:set_target(map:get_entity(next_step))
				movement:set_speed(32)
				guard:get_sprite():set_direction(guard:get_direction4_to(map:get_entity(next_step)))
				movement:start(guard, function()
					guard_path_step = guard_path_step + 1
					find_next_target()
				end)
			end
		end
		find_next_target()
	end
end

function setup_guard_sensors()
	for guard in map:get_entities("guard_") do
		for sensor in map:get_entities("sensor_" .. guard:get_name() .. "_") do
			function sensor:on_activated_repeat()
				if map.seen == false then
					if guard:overlaps(sensor)
					and (guard:get_direction4_to(hero) == guard:get_sprite():get_direction()) then
						hero:freeze()
						sol.audio.play_sound("hero/hero_seen")
						map.seen = true
						local target_movement = sol.movement.create("target")
						target_movement:set_target(hero)
						target_movement:set_speed(96)
						target_movement:start(guard, function ()
							hero:teleport("out/i3", "from_caught")
							map.seen = false
							setup_guard_paths()
							setup_guard_sensors()
						end)
						print("VU ! par "..guard:get_name())
					end
				end
			end
		end
	end
	sol.timer.start(map, 100, function()
		setup_guard_sensors()
	end)
end

function catch_hero()


end

if npc_witch ~= nil then
	function npc_witch:on_interaction()
		if game:get_value("possession_magic_powder") == nil and game:get_value("possession_mushroom") == nil then
			game:start_dialog("maps.out.cordinia_town.witch.needs_mushroom")
		end
	end

	function npc_witch:on_interaction_item(item)
		if item:get_name() == "trading_1" then
			if item:get_variant() == 1 then
				game:start_dialog("maps.out.cordinia_town.witch.trading_ask_straw", function(answer)
					if answer == 1 then
						hero:start_treasure("trading_1", 2)
					elseif answer == 2 then
						game:start_dialog("maps.out.cordinia_town.witch.trading_no_straw")
					end
				end)
			end
		end
		if item:get_name() == "mushroom" then
			game:start_dialog("maps.out.cordinia_town.witch.give_mushroom", function(answer)
				if answer == 1 then
					if game:is_step_done("dungeon_4_completed") then
						game:start_dialog("maps.out.cordinia_town.witch.powder_ready", function()
							hero:start_treasure("magic_powder")
						end)
					else
						game:start_dialog("maps.out.cordinia_town.witch.powder_not_ready")
					end
				end
			end)
		end
		hero:unfreeze()
	end
end

