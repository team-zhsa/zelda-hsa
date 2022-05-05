-- This in map script (moving fog)

local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")

function squirrel_walk()
	for custom_entity in map:get_entities("squirrel") do
		local movement = sol.movement.create("random")
		movement:set_speed(100)
		movement:start(custom_entity)
	end
end

function map:on_started(destination)
	game:show_map_name("east_lost_woods")
  map:set_overlay()
	squirrel_walk()
		for custom_entity in map:get_entities("butterfly") do
		local movement = sol.movement.create("random")
		movement:set_speed(100)
		movement:start(custom_entity)
		movement:set_ignore_obstacles(true)
	end
	map:set_digging_allowed(true)
end

sensor_cutscene:register_event("on_activated", function()
	if game:is_step_last("dungeon_1_completed") then
    map:set_cinematic_mode(true, options)
    hero:freeze()
    hero:set_direction(1)
    audio_manager:play_music("cutscenes/kaepora_gaebora")
    local owl_movement_to_position = sol.movement.create("target")
    owl_movement_to_position:set_target(owl_7_position)
    owl_movement_to_position:set_ignore_obstacles(true)
    owl_movement_to_position:set_ignore_suspend(true)
    owl_movement_to_position:set_speed(60)
    owl_movement_to_position:start(owl_7, function()
      owl_dialog()
    end)
  end
end)

function owl_dialog()
  game:start_dialog("maps.kaepora_gaebora.owl_7", function(answer)
    if answer == 1 then
      owl_dialog()
    elseif answer == 2 then
      game:start_dialog("maps.out.forest.song_learnt", function()
        hero:start_treasure("song_1_forest")
        game:set_step_done("dungeon_2_started")
        local owl_movement_leave = sol.movement.create("target")
        owl_movement_leave:set_target(1328, 328)
        owl_movement_leave:set_ignore_obstacles(true)
        owl_movement_leave:set_ignore_suspend(true)
        owl_movement_leave:set_speed(60)
        owl_movement_leave:start(owl_7, function()
          map:set_cinematic_mode(false, options)
          audio_manager:play_music_fade(map, "outside/east_lost_woods")
          hero:unfreeze()
        end)
      end) 
    end
  end)
end


        
map.overlay_angles = {
  3 * math.pi / 4,
  5 * math.pi / 4,
      math.pi / 4,
  7 * math.pi / 4
}
map.overlay_step = 1

-- Functions

function map:set_overlay()

  map.overlay = sol.surface.create("fogs/forest_fog.png")
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