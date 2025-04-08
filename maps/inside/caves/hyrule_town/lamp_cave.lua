-- Lua script of map inside/caves/hyrule_town/lamp_cave.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local separator_manager = require("scripts/maps/separator_manager.lua")

function map:on_started()
  map.fsa_dark = true
	separator_manager:manage_map(map)
  if game:has_item("magic_bar") then
    npc_wizard:set_enabled(false)
    wall_wizard:set_enabled(false)
  end
end

sensor_cutscene:register_event("on_activated", function()
  if not game:has_item("magic_bar") then
    map:set_cinematic_mode(true, options)
    game:start_dialog("maps.caves.hyrule_town.lamp_cave.wizard_magic_bar", function(answer)
      if answer == 1 then
        if game:get_money() >= 50 then
          game:remove_money(50)
          hero:start_treasure("magic_bar", 1, "inside_hyrule_town_magic_bar", function()
            local wizard_movement = sol.movement.create("straight")
            wizard_movement:set_ignore_obstacles(true)
            wizard_movement:set_ignore_suspend(true)
            wizard_movement:set_angle(math.pi / 2)
            wizard_movement:set_speed(96)
            wizard_movement:set_max_distance(96)
            wizard_movement:start(npc_wizard, function()
              npc_wizard:set_enabled(false)
              wall_wizard:set_enabled(false)
              map:set_cinematic_mode(false, options)
            end)
          end)
        else
          game:start_dialog("_shop.not_enough_money", function()
            map:set_cinematic_mode(false, options)
          end)
        end
      else
        game:start_dialog("maps.caves.hyrule_town.lamp_cave.wizard_magic_bar_no", function()
          map:set_cinematic_mode(false, options)
          hero:set_direction(3)
          local hero_movement = sol.movement.create("straight")
          hero_movement:set_ignore_suspend(true)
          hero_movement:set_angle(math.pi / 2)
          hero_movement:set_speed(88)
          hero_movement:set_max_distance(24)
          hero_movement:start(hero, function()
            hero:unfreeze()
          end)
        end)
      end
    end)
  end
end)

