local map = ...
local game = map:get_game()
local minigame_manager = require("scripts/maps/minigame_manager")

-- Events

map:register_event("on_started", function(destination)
	--map:set_overlay()
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

--[[ Variables
map.overlay_angles = {
	3 * math.pi / 4,
	5 * math.pi / 4,
			math.pi / 4,
	7 * math.pi / 4
}
map.overlay_step = 1

-- Functions
function map:set_overlay()

	map.overlay = sol.surface.create("fogs/forest.png")
	map.overlay:set_opacity(96)
	map.overlay_offset_x = 0  -- Used to keep continuity when getting lost.
	map.overlay_offset_y = 0
	map.overlay_m = sol.movement.create("straight")
	map.restart_overlay_movement()

end

function map:restart_overlay_movement()

	map.overlay_m:set_speed(16) 
	map.overlay_m:set_max_distance(100)
	map.overlay_m:set_angle(map.overlay_angles[map.overlay_step])
	map.overlay_step = map.overlay_step + 1
	if map.overlay_step > #map.overlay_angles then
		map.overlay_step = 1
	end
	map.overlay_m:start(map.overlay, function()
		map:restart_overlay_movement()
	end)

end

function map:on_draw(destination_surface)

	-- Make the overlay scroll with the camera, but slightly faster to make
	-- a depth effect.
	local camera_x, camera_y = self:get_camera():get_position()
	local overlay_width, overlay_height = map.overlay:get_size()
	local screen_width, screen_height = destination_surface:get_size()
	local x, y = camera_x + map.overlay_offset_x, camera_y + map.overlay_offset_y
	x, y = -math.floor(x * 1.5), -math.floor(y * 1.5)

	-- The overlay's image may be shorter than the screen, so we repeat its
	-- pattern. Furthermore, it also has a movement so let's make sure it
	-- will always fill the whole screen.
	x = x % overlay_width - 2 * overlay_width
	y = y % overlay_height - 2 * overlay_height

	local dst_y = y
	while dst_y < screen_height + overlay_height do
		local dst_x = x
		while dst_x < screen_width + overlay_width do
			-- Repeat the overlay's pattern.
			map.overlay:draw(destination_surface, dst_x, dst_y)
			dst_x = dst_x + overlay_width
		end
		dst_y = dst_y + overlay_height
	end

end
--]]