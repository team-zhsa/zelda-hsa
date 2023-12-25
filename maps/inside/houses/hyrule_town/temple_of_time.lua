-- Lua script of map inside/houses/main_town/temple_of_time.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")
local surface = sol.surface.create(320, 256)
local bloom_surface
local white_surface = sol.surface.create(320, 256)
white_surface:fill_color{255, 255, 255}
function map:on_draw(dst_surface)
	surface:draw(dst_surface)
	bloom_surface = dst_surface
	--bloom_surface:draw(dst_surface)
end

-- Rebuilds the whole surface of the menu.
map:register_event("on_started", function()
	sword:get_sprite():set_shader(nil)
end)

-- Event called at initialization time, as soon as this map is loaded.
cutscene_trigger:register_event("on_interaction", function()
	if game:is_step_done("dungeon_3_completed") then
		map:set_cinematic_mode(true)
		local hero_sprite = hero:get_sprite()
		local sword_sprite = sword:get_sprite()
		hero_sprite:set_animation("grabbing")
		sword:bring_to_front()
		sol.timer.start(map, 200, function()
			hero_sprite:set_animation("pulling")
			sword_sprite:set_shader(sol.shader.create("heavybloom"))
			local sword_movement_2 = sol.movement.create("straight")
			sword_movement_2:set_speed(2)
			sword_movement_2:set_max_distance(2)
			sword_movement_2:set_angle(math.pi/2)
			sword_movement_2:set_ignore_obstacles(true)
			sword_movement_2:start(sword, function()
				surface:fade_in(50)
				white_surface:draw(surface)
				sol.timer.start(map, 100, function()
					hero_sprite:set_animation("stopped")
					local sword_movement_3 = sol.movement.create("straight")
					sword_movement_3:set_speed(5)
					sword_movement_3:set_max_distance(16)
					sword_movement_3:set_angle(math.pi/2)
					sword_movement_3:set_ignore_obstacles(true)
					sword_movement_3:start(sword, function()
						bloom_surface:set_shader(sol.shader.create("grayscale"))
						surface:fade_out()
						local sword_movement_4 = sol.movement.create("straight")
						sword_movement_4:set_speed(5)
						sword_movement_4:set_max_distance(8)
						sword_movement_4:set_angle(math.pi/2)
						sword_movement_4:set_ignore_obstacles(true)
						sword_movement_4:start(sword, function()
							bloom_surface:set_shader(sol.shader.create("heavybloom"))
							surface:fade_in()
							sol.timer.start(map, 100, function()
								sword_sprite:set_shader(sol.shader.create("flickering_transparent"))
								surface:fade_out()
								sol.timer.start(map, 2000, function()
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
			sword:remove()
			hero:start_treasure("sword", 2)
		end)
	end
end)