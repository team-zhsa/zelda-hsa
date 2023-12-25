-- Lua script of map inside/houses/main_town/temple_of_time.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local surface = sol.surface.create(320, 256)
local bloom_surface
local white_surface = sol.surface.create(320, 256)
white_surface:fill_color{255, 255, 255}
local pendant_1 = sol.sprite.create("entities/items")
local pendant_2 = sol.sprite.create("entities/items")
local pendant_3 = sol.sprite.create("entities/items")
local center_x, center_y
pendant_1:set_animation("pendant_1")
pendant_2:set_animation("pendant_2")
pendant_3:set_animation("pendant_3")

local pendant_surface = sol.surface.create(320, 256)


function map:on_draw(dst_surface)
  local width, height = dst_surface:get_size()
  center_x, center_y = width / 2, height / 2
	surface:draw(dst_surface)
	bloom_surface = dst_surface
	pendant_1:draw(pendant_surface)
	pendant_2:draw(pendant_surface)
	pendant_3:draw(pendant_surface)
	pendant_surface:draw(dst_surface)
end

map:register_event("on_started", function()

	sword:get_sprite():set_shader(nil)
	if game:is_step_done("master_sword_obtained") then
		sword:remove()
		cutscene_trigger:remove()
	end
end)

-- Event called at initialization time, as soon as this map is loaded.
cutscene_trigger:register_event("on_interaction", function()
	if game:is_step_done("dungeon_3_completed") then
		
		local pendant_movement_1 = sol.movement.create("circle")
		pendant_movement_1:set_angular_speed(120)
		pendant_movement_1:set_radius(40)
		pendant_movement_1:set_center(sword)
		pendant_movement_1:set_ignore_obstacles(true)
		pendant_movement_1:set_angle_from_center((0 * math.pi / 3) - (math.pi / 2))
		
		local pendant_movement_2 = sol.movement.create("circle")
		pendant_movement_2:set_angular_speed(120)
		pendant_movement_2:set_radius(40)
		pendant_movement_2:set_center(sword)
		pendant_movement_2:set_ignore_obstacles(true)
		pendant_movement_2:set_angle_from_center((2 * math.pi / 3) - (math.pi / 2))
		
		local pendant_movement_3 = sol.movement.create("circle")
		pendant_movement_3:set_angular_speed(120)
		pendant_movement_3:set_radius(40)
		pendant_movement_3:set_center(sword)
		pendant_movement_3:set_ignore_obstacles(true)
		pendant_movement_3:set_angle_from_center((4 * math.pi / 3) - (math.pi / 2))
		
		local sword_movement_2 = sol.movement.create("straight")
		sword_movement_2:set_speed(2)
		sword_movement_2:set_max_distance(2)
		sword_movement_2:set_angle(math.pi/2)
		sword_movement_2:set_ignore_obstacles(true)
		
		local sword_movement_3 = sol.movement.create("straight")
		sword_movement_3:set_speed(5)
		sword_movement_3:set_max_distance(16)
		sword_movement_3:set_angle(math.pi/2)
		sword_movement_3:set_ignore_obstacles(true)
		
		local sword_movement_4 = sol.movement.create("straight")
		sword_movement_4:set_speed(5)
		sword_movement_4:set_max_distance(24)
		sword_movement_4:set_angle(math.pi/2)
		sword_movement_4:set_ignore_obstacles(true)


	--	map:set_cinematic_mode(true)
		local hero_sprite = hero:get_sprite()
		local sword_sprite = sword:get_sprite()
		hero_sprite:set_animation("grabbing")
		sword:bring_to_front()

--[[ 		pendant_1:set_xy(center_x + 40 * math.cos((0 * math.pi / 3) - (math.pi / 2)),
										 center_y + 40 * math.sin((0 * math.pi / 3) - (math.pi / 2)))
		pendant_2:set_xy(center_x + 40 * math.cos((2 * math.pi / 3) - (math.pi / 2)),
										 center_y + 40 * math.sin((2 * math.pi / 3) - (math.pi / 2)))
		pendant_3:set_xy(center_x + 40 * math.cos((4 * math.pi / 3) - (math.pi / 2)),
										 center_y + 40 * math.sin((4 * math.pi / 3) - (math.pi / 2))) ]]

										 
										 pendant_1:fade_in(40)
										 pendant_2:fade_in(40)
										 pendant_3:fade_in(40)
										 
										 pendant_movement_1:start(pendant_1)
										 pendant_movement_2:start(pendant_2)
										 pendant_movement_3:start(pendant_3)

		sol.timer.start(map, 200, function()
			hero_sprite:set_animation("pulling")
			sword_sprite:set_shader(sol.shader.create("heavybloom"))
			sword_movement_2:start(sword, function()
				surface:fade_in(50)
				white_surface:draw(surface)
				sol.timer.start(map, 100, function()
					hero_sprite:set_animation("stopped")
					sword_movement_3:start(sword, function()
						bloom_surface:set_shader(sol.shader.create("grayscale"))
						surface:fade_out()
						sword_movement_4:start(sword, function()
							bloom_surface:set_shader(sol.shader.create("heavybloom"))
							surface:fade_in()
							sol.timer.start(map, 100, function()
								sword_sprite:set_shader(sol.shader.create("starman"))
								surface:fade_out()
								sol.timer.start(map, 2500, function()
									surface:fade_in()
									sol.timer.start(map, 100, function()
										surface:fade_out()
										sword_sprite:set_shader(sol.shader.create("heavybloom"))
										bloom_surface:set_shader(nil)
									end)
								end)
							end)
						end)
					end)
				end)
			end)
		end)
		sol.audio.play_music("cutscenes/master_sword", function()
			sol.audio.stop_music()
			map:set_cinematic_mode(false)
			surface:fade_in()
			sol.timer.start(map, 100, function()
				cutscene_trigger:remove()
				sword:remove()
				surface:fade_out()
				hero:start_treasure("sword", 2)
				game:set_step_done("master_sword_obtained")
			end)
		end)
	end
end)