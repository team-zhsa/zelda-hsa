-- Lua script of map dungeon_9/1f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local separator_manager = require("scripts/maps/separator_manager.lua")

function map:on_started()
	separator_manager:manage_map(map)
	tile_7_puzzle:set_enabled(false)
	tile_7_puzzle_2:set_enabled(false)
	tile_7_puzzle_3:set_enabled(false)
	tile_7_puzzle_4:set_enabled(false)
	tile_7_puzzle_5:set_enabled(false)
	tile_7_puzzle_6:set_enabled(false)
end


-- Room 7 puzzle:
function switch_7_puzzle:on_activated()
	map:start_coroutine(function()
		tile_7_puzzle:set_enabled(true)
		wait(3000)
		tile_7_puzzle:set_enabled(false)
		switch_7_puzzle:set_activated(false)
	end)
end

function switch_7_puzzle_2:on_activated()
	map:start_coroutine(function()
		tile_7_puzzle_2:set_enabled(true)
		wait(2000)
		tile_7_puzzle_2:set_enabled(false)
		switch_7_puzzle_2:set_activated(false)
	end)
end

function switch_7_puzzle_3:on_activated()
	map:start_coroutine(function()
		tile_7_puzzle_3:set_enabled(true)
		wait(5000)
		tile_7_puzzle_3:set_enabled(false)
		switch_7_puzzle_3:set_activated(false)
	end)
end

function switch_7_puzzle_4:on_activated()
	map:start_coroutine(function()
		tile_7_puzzle_4:set_enabled(true)
		wait(4000)
		tile_7_puzzle_4:set_enabled(false)
		switch_7_puzzle_4:set_activated(false)
	end)
end

function switch_7_puzzle_5:on_activated()
	map:start_coroutine(function()
		tile_7_puzzle_5:set_enabled(true)
		tile_7_puzzle_6:set_enabled(true)
		sol.audio.play_sound("common/secret_discover_minor")
		wait(5000)
		tile_7_puzzle_5:set_enabled(false)
		tile_7_puzzle_6:set_enabled(false)
		switch_7_puzzle_5:set_activated(false)
	end)
end