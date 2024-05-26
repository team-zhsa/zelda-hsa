local water_level_manager = {}
local water_tile_dynamic_id = "water_dynamic_"
local water_animation_step_index
local water_delay = 500

function water_level_manager:switch_water_level(map)
  local game = map:get_game()
	if game:get_value("dungeon_"..game:get_dungeon_index().."_water_level") == "high" then
		water_level_manager:lower_water_level(map)
	elseif game:get_value("dungeon_"..game:get_dungeon_index().."_water_level") == "low" then
		water_level_manager:raise_water_level(map)
	end
end

function water_level_manager:check_water_level(map)
	local game = map:get_game()
	if game:get_value("dungeon_"..game:get_dungeon_index().."_water_level") == "high"
	or game:get_value("dungeon_"..game:get_dungeon_index().."_water_level") == nil then
		water_level_manager:set_high_water_level(map)
	elseif game:get_value("dungeon_"..game:get_dungeon_index().."_water_level") == "low" then
		water_level_manager:set_low_water_level(map)
	end
end

function water_level_manager:set_high_water_level(map)
	local game = map:get_game()
	local low_tile_id = water_tile_dynamic_id.."0_0_"
	local intermediate_tile_id = water_tile_dynamic_id.."0_1_"
	local high_tile_id = water_tile_dynamic_id.."0_2_"
	for tile in map:get_entities(low_tile_id) do
		tile:set_enabled(false)
	end
	for tile in map:get_entities(intermediate_tile_id) do
		tile:set_enabled(false)
	end
	for tile in map:get_entities(high_tile_id) do
		tile:set_enabled(true)
	end
	game:set_value("dungeon_"..game:get_dungeon_index().."_water_level", "high")
end

function water_level_manager:set_low_water_level(map)
	local game = map:get_game()
	local low_tile_id = water_tile_dynamic_id.."0_0_"
	local intermediate_tile_id = water_tile_dynamic_id.."0_1_"
	local high_tile_id = water_tile_dynamic_id.."0_2_"
	for tile in map:get_entities(low_tile_id) do
		tile:set_enabled(false)
	end
	for tile in map:get_entities(intermediate_tile_id) do
		tile:set_enabled(false)
	end
	for tile in map:get_entities(high_tile_id) do
		tile:set_enabled(false)
	end
	game:set_value("dungeon_"..game:get_dungeon_index().."_water_level", "low")
end

function water_level_manager:lower_water_level(map)
	water_animation_step_index = 2
  local game = map:get_game()
  local hero = map:get_hero()
  sol.audio.play_sound("environment/water_drain_begin")
  sol.audio.play_sound("environment/water_drain")
	sol.timer.start(map, 10, function()
		hero:freeze()
	end)
	sol.timer.start(map, water_delay, function()
		local current_tile_id = water_tile_dynamic_id.."0_"..(water_animation_step_index).."_"
		local next_tile_id = water_tile_dynamic_id.."0_"..(water_animation_step_index - 1).."_"
		for tile in map:get_entities(current_tile_id) do
			if tile ~= nil then
				tile:set_enabled(false)
				--print("disable curr tile"..current_tile_id)
			end
		end
		for tile in map:get_entities(next_tile_id) do
			if tile ~= nil then
				tile:set_enabled(true)
				--print("enable next tile"..next_tile_id)
			end
		end
		water_animation_step_index = water_animation_step_index - 1
		if water_animation_step_index == -1 then
			hero:unfreeze()
      return false
		end
		game:set_value("dungeon_"..game:get_dungeon_index().."_water_level", "low")
		return true
	end)
end

function water_level_manager:raise_water_level(map)
	water_animation_step_index = -1
  local game = map:get_game()
  local hero = map:get_hero()
  sol.audio.play_sound("environment/water_fill_begin")
  sol.audio.play_sound("environment/water_fill")
	sol.timer.start(map, 10, function()
		hero:freeze()
	end)
	sol.timer.start(map, water_delay, function()
		local current_tile_id = water_tile_dynamic_id.."0_"..(water_animation_step_index).."_"
		local next_tile_id = water_tile_dynamic_id.."0_"..(water_animation_step_index + 1).."_"
		for tile in map:get_entities(current_tile_id) do
			if tile ~= nil then
				tile:set_enabled(false)
				--print("disable curr tile"..current_tile_id)
			end
		end
		for tile in map:get_entities(next_tile_id) do
			if tile ~= nil then
				tile:set_enabled(true)
				--print("enable next tile"..next_tile_id)
			end
		end
		water_animation_step_index = water_animation_step_index + 1
		if water_animation_step_index == 2 then
      hero:unfreeze()
			return false
		end
		game:set_value("dungeon_"..game:get_dungeon_index().."_water_level", "high")
		return true
	end)
end

function water_level_manager:get_water_level(map)
  local game = map:get_game()
	return game:get_value("dungeon_"..game:get_dungeon_index().."_water_level")
end

return water_level_manager