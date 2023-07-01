local water_level_manager = {}

function water_level_manager:switch_water_level(map)

	if game:get_value("dungeon_"..game:get_dungeon_index().."_water_level") == "up" then
		water_level_manager:lower_water_level(map)
	elseif game:get_value("dungeon_"..game:get_dungeon_index().."_water_level") == "down" then
		water_level_manager:raise_water_level(map)
	end
end

function water_level_manager:lower_water_level(map)
	local water_tile_dynamic_id = "water_dynamic_"
	local water_animation_step_index = 2
  local water_delay = 500
	sol.timer.start(map, water_delay, function()
		local current_tile_id = water_tile_dynamic_id.."0_"..(water_animation_step_index).."_"
		local next_tile_id = water_tile_dynamic_id.."0_"..(water_animation_step_index - 1).."_"
		for tile in map:get_entities(current_tile_id) do
			if tile ~= nil then
				tile:set_enabled(false)
				print("disable curr tile"..current_tile_id)
			end
		end
		for tile in map:get_entities(next_tile_id) do
			if tile ~= nil then
				tile:set_enabled(true)
				print("enable next tile"..next_tile_id)
			end
		end
		water_animation_step_index = water_animation_step_index - 1
		if water_animation_step_index == -1 then
			return false
		end
		game:set_value("dungeon_6_water_level", "down")
		return true
	end)
end

function water_level_manager:raise_water_level(map)
	local water_tile_dynamic_id = "water_dynamic_"
	local water_animation_step_index = -1
  local water_delay = 500
	sol.timer.start(map, water_delay, function()
		local current_tile_id = water_tile_dynamic_id.."0_"..(water_animation_step_index).."_"
		local next_tile_id = water_tile_dynamic_id.."0_"..(water_animation_step_index + 1).."_"
		for tile in map:get_entities(current_tile_id) do
			if tile ~= nil then
				tile:set_enabled(false)
				print("disable curr tile"..current_tile_id)
			end
		end
		for tile in map:get_entities(next_tile_id) do
			if tile ~= nil then
				tile:set_enabled(true)
				print("enable next tile"..next_tile_id)
			end
		end
		water_animation_step_index = water_animation_step_index + 1
		if water_animation_step_index == 2 then
			return false
		end
		game:set_value("dungeon_6_water_level", "up")
		return true
	end)
end

return water_level_manager