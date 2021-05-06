--[[
Custom crystal block.

unlike the built-in crystal block, this model allows to :
  - jump between two of them when they are raised,
  - Pass through in debug mode (!)

--]]
local entity = ...
local game = entity:get_game()
local map = entity:get_map()
require("scripts/multi_events")

local initially_raised
local raised
local sprite

function entity:setup_sprite()
  local suffix=raised and "raised" or "lowered"
  local prefix=initially_raised and "blue" or "orange"
  sprite:set_animation (prefix.."_"..suffix)
end

entity:register_event("on_created", function(entity)
    initially_raised=entity:get_property("initially_raised")=="true"
    raised=initially_raised ~= map:get_crystal_state()
    sprite=entity:get_sprite()
    debug_print ("initially raised? ", tostring(initially_raised))
    entity:setup_sprite()
    sprite:set_frame(sprite:get_num_frames()-1)
  end)

entity:set_traversable_by(function(other) 
    return not raised 
  end)

entity:set_traversable_by("bomb", true)
entity:set_traversable_by("camera", true)
entity:set_traversable_by("carried_object", true)

local function check_generic_collision(entity, other)

  local other_x, other_y, other_w, other_h=other:get_bounding_box()
  local entity_x, entity_y, entity_w, entity_h=entity:get_bounding_box()

  return not (other_x+other_w<=entity_x or other_x>=entity_x+entity_w or other_y+other_h<=entity_y or other_y>=entity_y+entity_h) 
end

entity:set_traversable_by("custom_entity", function(entity, other)
    local x,y,layer=other:get_position()
    local bx, by, bw, bh=other:get_bounding_box()
    local ex, ey, ew, eh=entity:get_bounding_box()

    local model=other:get_model()
    return model=="arrow" or model=="bomb_arrow" 

  end)

entity:set_traversable_by("hero", function(entity, other)
    debug_print (other.ignore_crystal_block)
    if entity:is_raised() and not other.ignore_crystal_block then
      return check_generic_collision(entity, other)
    else
      return true
    end
  end)

entity:set_traversable_by("enemy", function(entity, other)
    if other:get_obstacle_behavior()=="flying" then
      return true
    else
      return check_generic_collision(entity, other)
    end
  end)

function entity:is_raised()
  return raised
end

function entity:notity_other_left(other)
  --TODO allow to play a custom animation
end

function entity:switch()
  raised=not raised
  entity:setup_sprite()
end

function entity:notify_crystal_state_changed()
  self:switch()   
end