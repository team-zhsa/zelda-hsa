-- Lua script of item _placeholder.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local item = ...
local audio_manager = require("scripts/audio_manager")

-- Event called when all items have been created.
function item:on_created()
	self:set_assignable(true)
	self:set_savegame_variable("possession_magic_mirror")
  -- initialise the properties of your item here,
  -- like whether it can be saved, whether it has an amount
  -- and whether it can be assigned.
end

-- Event called when the hero starts using this item.
function item:on_using()
		local game = self:get_game()
    local map = self:get_map()
  	local map = game:get_map()
   	local hero = map:get_hero()
	if game:get_dungeon() ~= nil then
		audio_manager:play_sound("common/warp")
    local dungeon_infos = game:get_dungeon()
		local map_id = dungeon_infos["main_entrance"]["map_id"]
    local destination_name = dungeon_infos["main_entrance"]["destination_name"]
    hero:teleport(map_id, destination_name, "fade")
	else
		audio_manager:play_sound("common/wrong")
	end

  -- Define here what happens when using this item
  -- and call item:set_finished() to release the hero when you have finished.
  item:set_finished()
end

-- Event called when a pickable treasure representing this item
-- is created on the map.
function item:on_pickable_created(pickable)

  -- You can set a particular movement here if you don't like the default one.
end