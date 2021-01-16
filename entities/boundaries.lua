-- Lua script of custom entity ladder.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero_is_on_boundary = false
local hero = game:get_hero()

-- Event called when the custom entity is initialized.
function entity:on_created()
  self:set_modified_ground("empty")
  local distance = self:get_distance(hero)
    if distance == 0 then
      if hero_is_on_boundary == false then
        hero_is_on_boundary = true
				print("map bounds!")
      end
    else
      hero_is_on_boundary = false
  	end
  return true
end
