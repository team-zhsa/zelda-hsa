-- Lua script of map inside/castle/rooms.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")
local effect_manager = require('scripts/maps/effect_manager')
local gb = require('scripts/maps/gb_effect')
local fsa = require('scripts/maps/fsa_effect')
local black_surface = sol.surface.create(320,240)
black_surface:fill_color({ 0, 0, 0 })
black_surface:set_opacity(0)

function map:on_started(destination)

	if destination:get_name() == "start_game" then
		effect_manager:set_effect(game, fsa)
		game:set_value("mode", "fsa")
		-- the intro scene is playing
		game:set_hud_enabled(true)
		game:set_pause_allowed(false)
		bed:get_sprite():set_animation("hero_sleeping")
		hero:freeze()
		hero:set_enabled(false)
		npc_zelda:set_enabled(true)
		npc_kid_1:set_enabled(true)
		npc_kid_2:set_enabled(true)
		npc_kid_3:set_enabled(true)
		audio_manager:play_music("cutscenes/raining")
		sol.timer.start(3000, function()
			game:set_step_done("game_started")
			play_intro_dialogue()
		end)
	else
		npc_kid_1:set_enabled(false)
    npc_kid_2:set_enabled(false)
    npc_kid_3:set_enabled(false)
	end
	
	if not game:is_step_done("sword_obtained") then
		sol.audio.play_music("cutscenes/raining")
		npc_zelda:set_enabled(true)
		npc_zelda:get_sprite():set_animation("sleeping")
	else sol.audio.play_music("inside/castle")
		npc_zelda:set_enabled(false)
		bed:get_sprite():set_animation("empty_open")
	end
end

function map:on_draw(dst_surface)
	black_surface:draw(dst_surface)
end

function jump_from_bed()
	map:set_cinematic_mode(false, options)
	hero:set_enabled(true)
	hero:start_jumping(7, 24, true)
	game:set_pause_allowed(true)
	bed:get_sprite():set_animation("empty_open")
	game:set_starting_location("inside/castle/1f", "start_game")
	--sol.audio.play_sound("hero_lands")
end

function fade_out()
	black_surface:fade_in(25, function()
		sol.timer.start(map, 1000, function()
			npc_kid_1:set_enabled(false)
			npc_kid_2:set_enabled(false)
			npc_kid_3:set_enabled(false)
			black_surface:fade_out(25, function()
				jump_from_bed()
			end)
		end)
	end)
end

function play_intro_dialogue()

	-- Defining the movements
	local kid_movement_enter_1 = sol.movement.create("straight")
	kid_movement_enter_1:set_ignore_obstacles(true)
	kid_movement_enter_1:set_ignore_suspend(true)
	kid_movement_enter_1:set_angle(math.pi / 2)
	kid_movement_enter_1:set_speed(104)
	kid_movement_enter_1:set_max_distance(32)

	local kid_movement_enter_2 = sol.movement.create("straight")
	kid_movement_enter_2:set_ignore_obstacles(true)
	kid_movement_enter_2:set_ignore_suspend(true)
	kid_movement_enter_2:set_angle(math.pi / 2)
	kid_movement_enter_2:set_speed(104)
	kid_movement_enter_2:set_max_distance(32)

	local kid_movement_enter_3 = sol.movement.create("straight")
	kid_movement_enter_3:set_ignore_obstacles(true)
	kid_movement_enter_3:set_ignore_suspend(true)
	kid_movement_enter_3:set_angle(math.pi / 2)
	kid_movement_enter_3:set_speed(104)
	kid_movement_enter_3:set_max_distance(32)

	local kid_movement_to_bed = sol.movement.create("target")
	kid_movement_to_bed:set_ignore_obstacles(true)
	kid_movement_to_bed:set_ignore_suspend(true)
	kid_movement_to_bed:set_target(position_bed)
	kid_movement_to_bed:set_speed(128)

	local kid_movement_to_position = sol.movement.create("target")
	kid_movement_to_position:set_ignore_obstacles(true)
	kid_movement_to_position:set_ignore_suspend(true)
	kid_movement_to_position:set_target(position_kid)
	kid_movement_to_position:set_speed(128)

	map:set_cinematic_mode(true, options)
	hero:freeze()

	-- NPC movement to position
	kid_movement_enter_1:start(npc_kid_1)
	kid_movement_enter_2:start(npc_kid_2)
	kid_movement_enter_3:start(npc_kid_3)
	function kid_movement_enter_1:on_finished()
		sol.timer.start(map, 1000, function()
			game:start_dialog("maps.houses.hyrule_castle.waking_up_1", game:get_player_name(), function()
				
				-- NPC movement to bed
				kid_movement_to_bed:start(npc_kid_1, function()
					npc_kid_1:get_sprite():set_direction(2)
					game:start_dialog("maps.houses.hyrule_castle.waking_up_2", function()	sol.timer.start(map, 1000, function()
						bed:get_sprite():set_animation("hero_waking")
						game:start_dialog("maps.houses.hyrule_castle.waking_up_3", function()
						
							-- NPC movement to position
							kid_movement_to_position:start(npc_kid_1, function()
								fade_out()
							end)
						end)
					end) end)
				end)
			end)
		end)
	end
end