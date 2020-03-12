-- Lua script of custom entity midpoint_teletransporter.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local audio_manager=require("scripts/audio_manager")
local entity_respawn_manager=require ("scripts/maps/entity_respawn_manager")
local transition=require("scripts/gfx_effects/distorsion")

local function call_with_delay_if_on_entity(entity_to_overlap, source_entity, delay, callback)
  if not entity_to_overlap.call_timer then
    local delay_time_remaining=delay

--    debug_print "Initialize pre-action timer"
    entity_to_overlap.call_timer=sol.timer.start(entity_to_overlap, 10, function()

        if not source_entity:overlaps(entity_to_overlap, "center") then
          if entity_to_overlap.call_timer then
            entity_to_overlap.call_timer:stop()
            entity_to_overlap.call_timer=nil
          end
          return false
        end
        delay_time_remaining=delay_time_remaining-10
        if delay_time_remaining==0 then
          entity_to_overlap.call_timer=nil
          callback()
          return false
        end
        return true
      end)
  end
end

entity:add_collision_test("center", function(entity, other)
    if other:get_type()=="hero" then
      local hero_sprite = other:get_sprite()
      if other:get_state()=="back to solid ground" then

        other.just_recovered_from_bad_ground=true
        if other.tp_cooldown_timer==nil then
          other.tp_cooldown_timer=sol.timer.start(other, 100, function()
              other.tp_cooldown_timer=nil
              other.just_recovered_from_bad_ground=nil
            end)
        end
      end
      if other.just_recovered_from_bad_ground==nil and (other.is_being_transported==nil or other.is_being_transported==false) then
        call_with_delay_if_on_entity(entity, other, 1000, function() --TODO find how to reset the timer when not on the tp anymore
          local midpoint_index=entity:get_property("tp_midpoint_index")
          other.is_being_transported = true
          game:set_suspended(true)
          game:set_pause_allowed(false)
          entity:get_sprite():set_ignore_suspend(true)
          entity:get_sprite():set_animation("teleportation")
          other:set_position(entity:get_position())
          hero_sprite:set_ignore_suspend(true)
          game.transition_in_progress=true
          local destination_map = map:get_id()
          local dungeon_info = game:get_dungeon() -- Get destination map infos if available, else teleport on the same map.
          if dungeon_info and dungeon_info.teletransporter_small_boss then
            local map_info = dungeon_info.teletransporter_small_boss
            destination_map = midpoint_index=="A" and map_info.map_id_B or map_info.map_id_A
          end
          local destination_name = "teletransporter_destination_" .. (midpoint_index=="A" and "B" or "A")
          if destination_map==map:get_id() then
            entity_respawn_manager:respawn_entities(map)
          end
          --function lib.start_effect(surface, game, mode, sfx, callback)
          transition.start_effect(map:get_camera():get_surface(), game, "in", "misc/dungeon_teleport", function()
              other:teleport(destination_map, destination_name)
              transition.start_effect(map:get_camera():get_surface(), game, "out", nil, function()
                other.tp_cooldown_timer=sol.timer.start(other, 100, function()
                  other.is_being_transported=false
                  other.tp_cooldown_timer=nil
                end)
                other:save_solid_ground()
                game:set_suspended(false)
                game:set_pause_allowed(true)
                entity:get_sprite():set_ignore_suspend(false)
                hero_sprite:set_ignore_suspend(false)
                entity:get_sprite():set_animation("normal")
              end)
            end)
          end)
      else
        if other.tp_cooldown_timer then
          other.tp_cooldown_timer:set_remaining_time(100)
        end
      end
    end
  end)
