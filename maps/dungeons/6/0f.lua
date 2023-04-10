-- Lua script of map dungeons/6/1f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")
local door_manager = require("scripts/maps/door_manager")
local enemy_manager = require("scripts/maps/enemy_manager")
local separator_manager = require("scripts/maps/separator_manager")
local switch_manager = require("scripts/maps/switch_manager")
local treasure_manager = require("scripts/maps/treasure_manager")
local flying_tile_manager = require("scripts/maps/flying_tile_manager")
local cannonball_manager = require("scripts/maps/cannonball_manager")

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started(destination)
	if destination:get_name() == "from_outside" then map:set_water_level(1) end
	for tile in map:get_entities("water_dynamic_") do
		tile:set_enabled(false)
	end
	for tile in map:get_entities("water_static_") do
		tile:set_enabled(false)
	end
	door_manager:open_when_switch_activated(map, "switch_26_door", "door_26_n_1")
end





function map:set_water_level(level)
	local water_delay = 500
	local current_water_level = game:get_value("dungeon_6_water_level")
	local water_tile_static_id = "water_static_"
	local water_tile_dynamic_id = "water_dynamic_"
	local water_tile_level = level
	sol.audio.play_sound("water_drain_begin")
  sol.audio.play_sound("water_drain")
  local water_animation_step_index = 1
  sol.timer.start(water_delay, function()
			local next_tiles = map:get_entities(water_tile_dynamic_id..water_tile_level..water_animation_step_index - 1)
			local previous_tiles = map:get_entities(water_tile_dynamic_id..water_tile_level..water_animation_step_index)
			if next_tiles == nil then
				return false
			end
			for tile in next_tiles do
				tile:set_enabled(true)
			end
			for tile in previous_tiles do
				tile:set_enabled(false)
			end
			water_animation_step_index = water_animation_step_index - 1
			return true
		end)
		for tile in map:get_entities(water_tile_static_id..water_tile_level) do
			tile:set_enabled(false)
		end
end
	--[[ Water level lower than wanted level: raise water level
	if current_water_level > level then
		local water_animation_step_index = -1
		sol.timer.start(water_delay, function()
			local previous_tile_id = ..water_tile_level.."_"..(water_animation_step_index).."_"
			local next_tile_id = water_tile_dynamic_id..water_tile_level.."_"..(water_animation_step_index + 1).."_"
			if level ~= - map:get_floor() then
				for tile in map:get_entities(previous_tile_id) do
					if tile ~= nil then
						tile:set_enabled(false)
						print("disable prev tile")
					end
				end
				for tile in map:get_entities(next_tile_id) do
					if tile ~= nil then
						tile:set_enabled(true)
						print("enable next tile")
					end
				end
				if water_animation_step_index == 1 then
					for tile in map:get_entities(water_tile_static_id..water_tile_level.."_") do
						tile:set_enabled(true)
					end
					print("end of water raising")
					game:set_value("dungeon_6_water_level", level)
					return false
				end
				print(water_animation_step_index)
				water_animation_step_index = water_animation_step_index + 1
				return true
			else
				for tile in map:get_entities(water_tile_static_id..water_tile_level.."_") do
					tile:set_enabled(true)
				end
				game:set_value("dungeon_6_water_level", level)
				return false
			end
		end)
		-- Water level higher than wanted level: lower water level TODO
	elseif current_water_level < level then
		local water_animation_step_index = 2
		sol.timer.start(water_delay, function()
			local previous_tile_id = water_tile_dynamic_id..water_tile_level.."_"..(water_animation_step_index).."_"
			local next_tile_id = water_tile_dynamic_id..water_tile_level.."_"..(water_animation_step_index - 1).."_"
			if level ~= - map:get_floor() then
				for tile in map:get_entities(previous_tile_id) do
					if tile ~= nil then
						tile:set_enabled(false)
						print("disable prev tile")
					end
				end
				for tile in map:get_entities(next_tile_id) do
					if tile ~= nil then
						tile:set_enabled(true)
						print("enable next tile")
					end
				end
				if water_animation_step_index == 2 then
					for tile in map:get_entities(water_tile_static_id..water_tile_level.."_") do
						tile:set_enabled(false)
					end
					print("end of water lowering")
					game:set_value("dungeon_6_water_level", level)
					return false
				end
				print(water_animation_step_index)
				water_animation_step_index = water_animation_step_index - 1
				return true
			else
				for tile in map:get_entities(water_tile_static_id..water_tile_level.."_") do
					tile:set_enabled(true)
				end
				game:set_value("dungeon_6_water_level", level)
				return false
			end
		end)
	end
end--]]
--[[ 


			local next_tile = map:get_entity("dynamic_water_" .. water_tile_index)
			local previous_tile = map:get_entity("dynamic_water_" .. water_tile_index + 1)
			if next_tile == nil then
				hero:unfreeze()
				return false
			end
			next_tile:set_enabled(true)
			if previous_tile ~= nil then
				previous_tile:set_enabled(false)
			end
			water_tile_index = water_tile_index - 1
			return true


		for tile in map:get_entities(water_tile_static_id..water_tile_level.."_") do

				for tile in  do
					tile:set_enabled(false)
					sol.timer.start(water_delay, function()
						for tile in  do
							tile:set_enabled(false)
							sol.timer.start(water_delay, function()
								for tile in map:get_entities(water_tile_static_id..water_tile_level.."_") do tile:set_enabled(false) end
							end)game:set_value("dungeon_6_water_level", level)
						end
					end)
				end
			end
		end


end ]]
		--[[ for tile in map:get_entities(water_tile_id..water_tile_level.."_") do
			if water_tile_level <= level then


				sol.audio.play_sound("water_fill_begin")
				sol.audio.play_sound("water_fill")
				local water_tile_animation_index = -1
				function enable_static_tile()
					for tile in map:get_entities(water_tile_id..water_tile_level) do
						tile:set_enabled(true)
					end
				end
				for water_tile_dynamic_index = 0, 99 do
					sol.timer.start(500, function()
						local next_tile = map:get_entity("water_dynamic_"..water_tile_level.."_"..(water_tile_animation_index + 1).."_"..water_tile_dynamic_index)
						local previous_tile = map:get_entity("water_dynamic_"..water_tile_level.."_"..(water_tile_animation_index).."_"..water_tile_dynamic_index)
				
						if next_tile ~= nil then
							next_tile:set_enabled(true)
						end
						if previous_tile ~= nil then
							previous_tile:set_enabled(false)
						end
						
						water_tile_animation_index = water_tile_animation_index + 1
							if next_tile == nil then
							enable_static_tile()
							return false
						end
						return true
					end)
				end
			elseif water_tile_level ~= level then
				sol.audio.play_sound("water_drain_begin")
				sol.audio.play_sound("water_drain")
				local water_tile_animation_index = 1
				function disable_static_tile()
					for tile in map:get_entities(water_tile_id..water_tile_level) do
						tile:set_enabled(false)
					end
				end
				for water_tile_dynamic_index = 0, 99 do
					sol.timer.start(500, function()
						local next_tile = map:get_entity("water_dynamic_"..water_tile_level.."_"..(water_tile_animation_index).."_"..water_tile_dynamic_index)
						local previous_tile = map:get_entity("water_dynamic_"..water_tile_level.."_"..(water_tile_animation_index + 1).."_"..water_tile_dynamic_index)
				
						if next_tile ~= nil then
							next_tile:set_enabled(true)
						end
						if previous_tile ~= nil then
							previous_tile:set_enabled(false)
						end
						
						water_tile_animation_index = water_tile_animation_index - 1
						if next_tile == nil then
							disable_static_tile()
							return false
						end
						return true
					end)
				end
			end
		end
	end ]]

function map:get_water_level()
	return game:get_value("dungeon_6_water_level")
end

npc_18_hint:register_event("on_interaction", function()
	game:start_dialog("maps.dungeons.6.hint_1", game:get_player_name())
end)


handle_4_water_1:register_event("on_released", function()
	if map:get_water_level() == 1 then map:set_water_level(0)
	elseif map:get_water_level() == 0 then map:set_water_level(1) end
end)

handle_4_water_2:register_event("on_released", function()
	if map:get_water_level() == 1 then map:set_water_level(0)
	elseif map:get_water_level() == 0 then map:set_water_level(1) end
end)

handle_9_water:register_event("on_released", function()
	if map:get_water_level() == 1 then map:set_water_level(0)
	elseif map:get_water_level() == 0 then map:set_water_level(1) end
end)

handle_17_water_1:register_event("on_released", function()
	for stream in map:get_entities("water_stream_17_1_") do
		local sprite = stream:get_sprite()
		if stream:get_direction() < 4 then
			stream:set_direction(6)
			sprite:set_direction(6)
		elseif sprite:get_direction() >= 4 then
			stream:set_direction(2)
			sprite:set_direction(2)
		end
	end
end)

handle_17_water_2:register_event("on_released", function()
	for stream in map:get_entities("water_stream_17_2_") do
		local sprite = stream:get_sprite()
		if sprite:get_direction() < 4 then
			stream:set_direction(4)
			sprite:set_direction(4)
		elseif sprite:get_direction() >= 4 then
			stream:set_direction(0)
			sprite:set_direction(0)
		end
	end
end)

handle_17_water_3:register_event("on_released", function()
	for stream in map:get_entities("water_stream_17_3_") do
		local sprite = stream:get_sprite()
		if stream:get_direction() < 4 then
			stream:set_direction(6)
			sprite:set_direction(6)
		elseif sprite:get_direction() >= 4 then
			stream:set_direction(2)
			sprite:set_direction(2)
		end
	end
end)

handle_17_water_4:register_event("on_released", function()
	for stream in map:get_entities("water_stream_17_2_") do
		local sprite = stream:get_sprite()
		if sprite:get_direction() < 4 then
			stream:set_direction(4)
			sprite:set_direction(4)
		elseif sprite:get_direction() >= 4 then
			stream:set_direction(0)
			sprite:set_direction(0)
		end
	end
end)

handle_18_water:register_event("on_released", function()
	if map:get_water_level() == 1 then map:set_water_level(0)
	elseif map:get_water_level() == 0 then map:set_water_level(1) end
end)

--[[ Water levels info:
static_water_X_N means that the Nth static water tile is enabled when the water level is at X (0 being the highest).
dynamic_water_A_B_K_R means that the Kth water tile (in water_tile index for raising/lowering the water) of the Rth room can be raised from level A to B.

Water levels:
0: water at -1 of 0F
1: water at -1 of B1
2: water at -1 of B2
3: water at -1 of B3
4: water at -1 of B4
5: water at -1 of B5

For handle base sprites :
Up arrow set to 1
Down arrow set to 2
Circle switch stream direction
Heart switch between water at the current floor and floor below

Triangle set to 3
Rupee set to 4
Wave set to 5


]]

--[[local water_delay = 500
-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
	if game:get_value("dungeon_2_b2_24_pool_full") == false then
		for tile in map:get_entities("static_water_") do
	 		tile:set_enabled(false)
		end	
		dynamic_water_1:set_enabled(false)
		switch_24_pool_empty:set_activated(true)
		switch_24_pool_fill:set_activated(false)
	elseif game:get_value("dungeon_2_b2_24_pool_full") ~= false then
		switch_24_pool_empty:set_activated(false)
		switch_24_pool_fill:set_activated(true)
		game:set_value("dungeon_2_b2_24_pool_full", true)
	end
	dynamic_water_2:set_enabled(false)
	dynamic_water_3:set_enabled(false)
	dynamic_water_4:set_enabled(false)
	separator_manager:manage_map(map)
	map:set_doors_open("door_33_e", false)
	map:set_doors_open("door_34_w", false)
	map:set_doors_open("door_29_n", false)
	map:set_doors_open("door_21_s", false)
	
	door_manager:open_when_switch_activated(map, "switch_27_door", "door_27_n")
	door_manager:open_when_switch_activated(map, "switch_24_door", "door_29_n")
	door_manager:open_when_switch_activated(map, "switch_34_door", "door_29_n")
	-- You can initialise the movement and sprites of various
	-- map entities here.
end)

-- Pool fill switch mechanism
-- The switch fills up the swimming pool
function switch_24_pool_fill:on_activated()
	hero:freeze()
	switch_24_pool_empty:set_activated(false)
	sol.audio.play_sound("water_fill_begin")
	sol.audio.play_sound("water_fill")
	local water_tile_index = 4
	sol.timer.start(water_delay, function()
		local next_tile = map:get_entity("dynamic_water_" .. water_tile_index)
		local previous_tile = map:get_entity("dynamic_water_" .. water_tile_index + 1)
		if next_tile == nil then
			hero:unfreeze()
			return false
		end
		next_tile:set_enabled(true)
		if previous_tile ~= nil then
			previous_tile:set_enabled(false)
		end
		water_tile_index = water_tile_index - 1
		return true
	end)
	for tile in map:get_entities("static_water_") do
		tile:set_enabled(true)
	end
	game:set_value("dungeon_2_b2_24_pool_full", true)
end

-- Pool empty switch mechanism
-- The switch drains the swimming pool
function switch_24_pool_empty:on_activated()
	hero:freeze()
	switch_24_pool_fill:set_activated(false)
	sol.audio.play_sound("water_drain_begin")
	sol.audio.play_sound("water_drain")
	local water_tile_index = 1
	sol.timer.start(water_delay, function()
		local next_tile = map:get_entity("dynamic_water_" .. water_tile_index + 1)
		local previous_tile = map:get_entity("dynamic_water_" .. water_tile_index)
		if next_tile ~= nil then		
			next_tile:set_enabled(true)
		end
		if previous_tile ~= nil then
			previous_tile:set_enabled(false)
		end
		water_tile_index = water_tile_index + 1
		if next_tile == nil then
			hero:unfreeze()
			return false
		end
		return true
	end)
	for tile in map:get_entities("static_water_") do
		tile:set_enabled(false)
	end
	game:set_value("dungeon_2_b2_24_pool_full", false)
end]]