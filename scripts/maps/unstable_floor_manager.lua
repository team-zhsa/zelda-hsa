--[[
------------------------------------------------------
---------- UNSTABLE FLOORS MANAGER SCRIPT -----------
------------------------------------------------------

This feature is used to store the last stable floor position for the hero.
Then, you can recover it with:

  hero:get_last_stable_position()

UNSTABLE FLOORS are a custom property for entities, used to specify that we cannot use that position
to save it as a solid ground position, which is a general property of "bad grounds" too.
Recall that BAD GROUNDS include holes, lava, and also deep water only if the hero does NOT have
the "swim" ability. Unstable floors can be used on weak floors that break, perhaps on moving
platforms too, and any other type of custom grounds/floors that do not not allow saving solid ground position.

This can be used by other scripts in this way:

  hero:save_solid_ground(hero:get_last_stable_position())

------------------------------------------------------
-------------- INSTRUCTIONS FOR DUMMIES --------------
------------------------------------------------------

1) HOW TO include this feature. First, include the script with:

  require("scripts/maps/unstable_floor_manager")

-Use the multi-events script if you need to add some code there or you may break the feature temporarily.
-Do NOT redefine the event "hero/hero_meta.on_position_changed", or you will fully break the feature.
-Call "hero:initialize_unstable_floor_manager()" always after calling "hero:reset_solid_ground()",
to restart the feature.
-By default, the events "game.on_map_changed" and "separator.on_activated" restart/initialize this
feature, unless you override them (which could break the feature temporarily).

2) HOW TO define unstable floors (i.e., floors where the hero does not save position):

Create an entity and set its custom property "unstable_floor" to the string value "true",
either from the Editor, or in the script with:

  entity:set_property("unstable_floor", "true")

--]]
-- Variables
local game_meta = sol.main.get_metatable("game")
local map_meta = sol.main.get_metatable("map")
local hero_meta = sol.main.get_metatable("hero")
local separator_meta = sol.main.get_metatable("separator")
hero_meta.last_stable_position = {x = nil, y = nil, layer = nil, direction=nil}

-- Function to check if the position is BAD ground, i.e., holes, lava, and maybe deep water too.
-- Deep water is ONLY considered bad ground if the hero does NOT have the "swim" ability.
function map_meta:is_bad_ground(x, y, layer)

  local game = self:get_game()
  local ground = self:get_ground(x, y, layer)
  if ground == "hole" or ground == "lava" or 
  (ground == "deep_water" and game:get_ability("swim") == 0) then
    return true
  end
  return false
end

-- Return last stable position of the hero.
function hero_meta:get_last_stable_position()

  local pos = self.last_stable_position
  return pos.x, pos.y, pos.layer, pos.direction
end

-- Update the last stable position of the hero.
hero_meta:register_event("on_position_changed", function(hero)

    local map = hero:get_map()
    local game = hero:get_game()
    if map:get_world()=="outside_world" and hero:get_state()~="back to solid ground" then
      local x, y, layer = hero:get_ground_position() -- Check GROUND position.
      local state = hero:get_state_object() 
      local state_ignore_ground = state and not state:get_can_come_from_bad_ground()
      if (not state_ignore_ground) and hero:get_state() ~= "jumping" then
        if not map:is_bad_ground(x, y, layer) then
          hero.last_stable_position.x, hero.last_stable_position.y, hero.last_stable_position.layer = hero:get_position()
          local m=hero:get_movement()
          if m then
            if m.get_angle then
              hero.last_stable_position.direction=math.floor(m:get_angle()*8/(math.pi*2))
            else
              hero.last_stable_position.direction=m:get_direction4()*2
            end
          end
        end
      end
    end
  end)
-- Update the last stable position of the hero.
hero_meta:register_event("on_state_changing", function(hero, old_state, state)

    local map = hero:get_map()
    local game = hero:get_game()
    if old_state=="back to solid ground" and state=="free" then
      print("respawn")
      if map:get_world()=="outside_world" and not map:is_sideview() then
        local position = hero.last_stable_position
        local directions={{-8,0}, {-8, 8}, {0, 8}, {8, 8}, {8, 0}, {8, -8}, {0, -8}, {-8, -8}}
        local offset_x, offset_y=unpack(directions[position.direction+1])
        hero:set_position(position.x+offset_x, position.y+offset_y, position.layer)
      end
      --debug_print (hero.last_stable_position.direction)
      hero:set_direction(hero.last_stable_position.direction/2 or 0)
    end
  end)

-- Function to initialize the unstable floor manager.
-- Use it always after calling "hero:reset_solid_ground()".
function hero_meta:initialize_unstable_floor_manager()

  local hero = self  
  hero:save_solid_ground(function()
      -- Return the last stable position.
      return hero.last_stable_position.x, hero.last_stable_position.y, hero.last_stable_position.layer
    end)
  hero.last_stable_position.direction=hero:get_direction()*2
end


-- Save current position of the hero as a stable one (even over unstable floors).
-- (Used for the first position when the map or region change.)
function hero_meta:save_stable_floor_position()
  local hero = self  
  local x, y, layer = hero:get_position()
  hero.last_stable_position={
    x=x,
    y=y,
    layer=layer,
    direction=hero:get_direction()*2,
  }
end

-- Initialize the manager on the corresponding events.
game_meta:register_event("on_map_changed", function(game, map)

    local hero = game:get_hero()
    hero:save_stable_floor_position()
    hero:initialize_unstable_floor_manager()
  end)
separator_meta:register_event("on_activated", function(separator, dir4)

    local hero = separator:get_map():get_hero()
    hero:save_stable_floor_position()
    hero:initialize_unstable_floor_manager()
  end)
