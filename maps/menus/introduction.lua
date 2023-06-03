local map = ...
local game = map:get_game()
local effect_manager = require('scripts/maps/effect_manager')
local gb = require('scripts/maps/gb_effect')
local fsa = require('scripts/maps/fsa_effect')

-- Intro.
local map_width, map_height = map:get_size()
local phase

-- Scrolling backgrounds.
local bg1_img = sol.surface.create("menus/intro/bg1.png")
local bg1_width, bg1_height = bg1_img:get_size()
local bg1_xy = {}
local bg1_movement = sol.movement.create("straight")
bg1_movement:set_angle(3 * math.pi / 4)
bg1_movement:set_speed(32)
bg1_movement:start(bg1_xy)

local bg2_img = sol.surface.create("menus/intro/bg2.png")
local bg2_width, bg2_height = bg2_img:get_size()
local bg2_xy = {}
local bg2_movement = sol.movement.create("straight")
bg2_movement:set_angle(math.pi / 4)
bg2_movement:set_speed(32)
bg2_movement:start(bg2_xy)

function bg1_movement:on_position_changed(x, y)
	if y <= -bg1_height then
		bg1_movement:set_xy(0, 0)
	end
end

function bg2_movement:on_position_changed(x, y)
	if y <= -bg2_height then
		bg2_movement:set_xy(0, 0)
	end
end

-- Frescos.
local frescos = {}
local frescos_background = sol.surface.create("menus/intro/intro.png")
--frescos_background:fill_color({224, 224, 244})
local fresco_index = 0  -- Index of the current fresco.

-- Dialog.
local dialog_background_top = sol.surface.create(224, 20)
dialog_background_top:fill_color({255, 255, 128, 32})

local dialog_background_left = sol.surface.create(36, 48)
dialog_background_left:fill_color({255, 255, 128, 32})

local dialog_background_right = sol.surface.create(20, 48)
dialog_background_right:fill_color({255, 255, 128, 32})

local dialog_background_bottom = sol.surface.create(224, 76)
dialog_background_bottom:fill_color({255, 255, 128, 32})

-- Fade to black
local black_surface = sol.surface.create()

-- Map surface
local map_surface = sol.surface.create("menus/map/scrollable_hyrule_world_map.png")
local scale_delta = 0.05
local scale_max = 8
local scale_timer = 100
local scale_x, scale_y = 0.4, 0.4
			
function map:on_draw(dst_surface)
	local width, height = dst_surface:get_size()
	local center_x, center_y = width / 2, height / 2
	
	if phase == 1 or phase == 6 then
		-- Scrolling backgrounds.
		for y = -bg2_height, map_height + bg2_height, bg2_height do
			for x = -bg2_width, map_width + bg2_width, bg2_width do
				bg2_img:draw(dst_surface, bg2_xy.x + x, bg2_xy.y + y)
			end
		end

		for y = -bg1_height, map_height + bg1_height, bg1_height do
			for x = -bg1_width, map_width + bg1_width, bg1_width do
				bg1_img:draw(dst_surface, bg1_xy.x + x, bg1_xy.y + y)
			end
		end
		
	-- Dialog box background.
	dialog_background_top:set_xy(center_x - 112, center_y - 72)
	dialog_background_top:draw(dst_surface)

	dialog_background_left:set_xy(center_x - 112, center_y - 52)
	dialog_background_left:draw(dst_surface)

	dialog_background_right:set_xy(center_x + 92, center_y - 52)
	dialog_background_right:draw(dst_surface)

	dialog_background_bottom:set_xy(center_x - 112, center_y - 4)
	dialog_background_bottom:draw(dst_surface)

	-- Frescos background.
	frescos_background:draw_region(
		0, 48 * (fresco_index - 1),
		168, 48,
		dst_surface, center_x - 84, 64)
		
	elseif phase == 2 then
		map_surface:draw(dst_surface, center_x - 500, center_y - 400)
	end
	black_surface:draw(dst_surface)
end

function phase_1()
	-- Frescos (part 1).
	phase = 1
	fresco_index = fresco_index + 1
	if fresco_index < 7 then
		frescos_background:fade_in(20)
		game:get_dialog_box():set_style("empty")
		game:start_dialog("scripts.menus.introduction.intro_" .. fresco_index, game:get_player_name(), function()
			frescos_background:fade_out(20, function()
				phase_1()
			end)
		end)
	elseif fresco_index == 7 then
		black_surface:fade_in(40, function()
			phase_2()
		end)
	end
end

function phase_2()
	-- Map zoom.
	phase = 2
	sol.timer.start(map, 500, function()
	map_surface:set_transformation_origin(512, 380)
	map_surface:set_opacity(255)
		black_surface:fade_out(40, function()
			sol.timer.start(game, 40, function()
				scale_x = scale_y + scale_delta
				scale_y = scale_y + scale_delta
				map_surface:set_scale(scale_x, scale_y)
				return scale_x < scale_max
			end)
			sol.timer.start(map, 6000, function()
				black_surface:fade_in(40, function()
					map_surface:clear()
					phase_3()
				end)
			end)
		end)
	end)
end

function phase_3()
	-- Wizard going towards Agahnim.
	phase = 3
	map:get_camera():start_tracking(wizard)
	agahnim:get_sprite():set_opacity(0)
	black_surface:fade_out(40, function()
		map:set_cinematic_mode(true, options)
		local wizard_movement = sol.movement.create("path")
		wizard_movement:set_speed(32)
		wizard_movement:set_ignore_obstacles(true)
		wizard_movement:set_path{6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6}
		wizard_movement:start(wizard, function()
			phase_4()
		end)
	end)
end

function phase_4()
	-- Wizard invoking Agahnim.
	phase = 4
	sol.timer.start(map, 1000, function()
		wizard:get_sprite():set_animation("invoking")
		sol.timer.start(map, 1000, function()
			wizard:get_sprite():set_animation("stopped")
			sol.audio.play_sound("boss_charge")
			agahnim:get_sprite():fade_in(40, function()
				game:start_dialog("scripts.menus.introduction.intro_7", function()
					sol.timer.start(map, 100, function()
						map:set_cinematic_mode(false, options)
						game:set_hud_enabled(false)
						game:set_pause_allowed(false)
						hero:freeze()
						black_surface:fade_in(40, function()
							map:get_camera():start_manual()
							phase_5()
						end)
					end)
				end)
			end)
		end)
	end)
end

function phase_5()
	-- Earthquake
	phase = 5
	map:get_camera():set_position(0, 240)
	black_surface:fade_out(40, function()
		sol.audio.play_sound("enemies/_miniboss/phantom_ganon/laugh")
		map:get_camera():dynamic_shake({count = 500, amplitude = 2, speed = 50, entity=world_map}, function()
			game:start_dialog("scripts.menus.introduction.intro_8", function()
				black_surface:fade_in(40, function()
					fresco_index = 8
					phase_6()
				end)
			end)
		end)
	end)
end

function phase_6()
	-- Frescos (part 2).
	phase = 6
	map:get_camera():set_position(0, 0)
	if black_surface:get_opacity() == 255 then black_surface:fade_out(40) end
	fresco_index = fresco_index + 1
	if fresco_index < 11 then
		frescos_background:fade_in(20)
		game:get_dialog_box():set_style("empty")
		game:start_dialog("scripts.menus.introduction.intro_" .. fresco_index, game:get_player_name(), function()
			frescos_background:fade_out(20, function()
				phase_6()
			end)
		end)
	elseif fresco_index == 11 then
		black_surface:fade_in(40, function()
			-- Restore usual settings.
			game:get_dialog_box():set_style("box")
			game:get_dialog_box():set_position("bottom")
			hero:unfreeze()

			-- Go to the first map.
			hero:teleport("inside/castle/rooms", "start_game")
		end)
	end
end

function map:on_started()
	map:set_joypad_commands()
	effect_manager:set_effect(game, nil)
	game:set_value("mode", "snes")
	game:get_dialog_box():set_style("empty")
	map:get_camera():set_position(0, 0)
	sol.audio.play_music("cutscenes/cutscene_introduction")
	black_surface:fill_color({ 0, 0, 0 })
	black_surface:set_opacity(0)
	map_surface:set_opacity(0)
	map_surface:set_scale(scale_x, scale_y)
	game:set_hud_enabled(false)
	phase_1()
end

function map:on_opening_transition_finished()
	hero:freeze()
end

function map:set_joypad_commands()
	-- Button mapping according commonly used xbox gamepad on PC
	game:set_command_joypad_binding("action", "button 2") -- button 0 = A (xbox/pc)
	game:set_command_joypad_binding("attack", "button 1") -- button 2 = X (xbox/pc)
	game:set_command_joypad_binding("item_1", "button 0") -- button 3 = Y (xbox/pc)
	game:set_command_joypad_binding("item_2", "button 3") -- button 1 = B (xbox/pc)
	game:set_command_joypad_binding("pause", "button 9")  -- button 7 = Menu/Start (xbox/pc)
	game:set_command_joypad_binding("up", "hat 0 up")
	game:set_command_joypad_binding("left", "hat 0 left")
	game:set_command_joypad_binding("right", "hat 0 right")
	game:set_command_joypad_binding("down", "hat 0 down")
end

function map:on_finished()
	game:set_hud_enabled(true)
end
