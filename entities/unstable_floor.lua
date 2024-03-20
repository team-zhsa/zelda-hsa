-- Unstable floor: breaks if the hero stays for a while above it.

--[[
IMPORTANT:
If an instance of unstable floor has a name entity_name, when the floor is destroyed we
also destroy all other entities with the prefix: entity_name .. "_unstable_associate_"
--]]
-- Variables
local entity = ...
local default_sprite_id = "entities/cave_hole"
local break_sound = "environment/rock_shatter" --TODO find another sound
local time_resistance = 1500 -- The time it resists with hero above. In milliseconds.

-- Include scripts
local audio_manager = require("scripts/audio_manager")
require("scripts/multi_events")

-- Event called when the custom entity is initialised.
entity:register_event("on_created", function()

  local hero = entity:get_map():get_hero()
  -- Add an unstable floor (do not save ground position!!!).
  entity:set_modified_ground("traversable")
  entity:set_property("unstable_floor", "true")
  entity:set_drawn_in_y_order(false)
  -- Create sprite if necessary.
  if entity:get_sprite() == nil then entity:create_sprite(default_sprite_id) end
  -- Add collision test. Break if the hero stays above more time than time_resistance.
  local time_above = 0 -- Stores how much time the hero has been above.
  local layer = entity:get_layer()
  local timer = nil
  local timer_delay = 50

  entity:add_collision_test(function(this, other) -- Test: ground position inside bounding box.
    if timer then
      return
    end
    if other:get_type() ~= "hero" then
      return false
    end
    if hero:is_jumping() or hero:get_state() == "jumping" then
      return false
    end
    local hx, hy, hl = hero:get_ground_position()
    if hl ~= layer then
      return false
    end
    return this:overlaps(hx, hy)
  end, function() -- Callback: play sound and remove entity.
    timer = sol.timer.start(entity , timer_delay, function()
      local hx, hy, hl = hero:get_ground_position()
      if hl == layer and entity:overlaps(hx, hy)
            and (not hero:is_jumping()) and hero:get_state() ~= "jumping" then
        time_above = time_above + timer_delay
        if time_above >= time_resistance then
          audio_manager:play_sound(break_sound)
          local entity_name = entity:get_name()
          if entity_name then
            local prefix = entity_name .. "_unstable_bg_"
            for entity_map in entity:get_map():get_entities(prefix) do
              entity_map:remove()
            end
          end
          entity:remove()
        end
        return true
      else
        timer:stop()
        time_above = 0
        timer = nil
      end
    end)
  end)

end)
