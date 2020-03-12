--[[
  Generic moving platform, which oscillates back and forth.
  It can be made semi-solid (you can go through while you are under it, and you can walk on it as soon as you are above it)
  To customize it, use the following custom properties :
    direction (0-7): the direction to follow from the starting position. Defaults to 0 (right)
    distance: the mawimum distance in pisels to go from the starting position. Defaults to 0 (no movement)
    cycle_duration: the back-and-forth duration. defaults to 4000 ms
    is_semisolid: Whether it should be semi-solid. Dafaults to false
    
  Note: The way the semi-solidity is handled makes it incompatible with having multiples heroes.
--]]

-- Variables
local entity = ...
local game = entity:get_game()
local hero = game:get_hero()
local map = entity:get_map()
--local movement
local sprite
local ax, ay
local is_solidified = true

-- Include scripts
require("scripts/multi_events")

-- Event called when the custom entity is initialized.
--function entity:on_created()
entity:register_event("on_created", function()
    entity.start_x, entity.start_y = entity:get_position()
    entity.old_x, entity.old_y = entity:get_bounding_box()
    entity:set_traversable_by(false)
    entity.direction = entity:get_property("direction")
    if entity.direction == nil then
      entity.direction = 0
    end
    entity.distance = entity:get_property("distance")
    if entity.distance == nil then
      entity.distance= 0
    end
    entity.cycle_duration = entity:get_property("cycle_duration")
    if entity.cycle_duration == nil then
      entity.cycle_duration = 4000
    end

    entity.elapsed_time=0
    entity.movement_angle=(entity.direction)/4*math.pi
    ax = math.cos(entity.movement_angle)*entity.distance/2
    ay = -math.sin(entity.movement_angle)*entity.distance/2
  end)

--This function makes the given entity maintain it's relative position to the platform
local function move_entity_with_me(other)

  local x,y=entity:get_bounding_box()
  local dx, dy = x-entity.old_x, y-entity.old_y
  local xx, yy = other:get_position()

  other:set_position(xx+dx, yy+dy)

end

function entity:reset()
  entity.elapsed_time=0
end

function entity:on_position_changed()

  local x,y,w,h = entity:get_bounding_box()
  --Try to synchronize every compatible entity in range
  for other in map:get_entities_in_rectangle(x-16, y-16, w+32, h+32) do

    if other ~= entity then --This may be obvious, but you don't want to apply the synch in itself unless you want to be a bit trolly :p
      local e_type = other:get_type()
      if e_type == "hero" or e_type == "npc" or e_type == "enemy" or e_type == "pickable" or (e_type=="custom_entity" and other:get_model()=="npc") then --TODO identity all compatible entity typesx, 

        --Update entity position start
        local other_x, other_y, other_w , other_h = other:get_bounding_box()

        -- Maybe use the same coordinates for entity's position range ?
        if other_y+other_h <= y+1 then
          if e_type == "hero" and is_solidified == true then
--              debug_print "ME SOLID NOW"
            is_solidified = false
            entity:set_traversable_by("hero", false)
          end
          if other_x+other_w/2 <= x+w-1 and other_x+other_w/2 >= x and other_y+other_h >= y-1 then
            move_entity_with_me(other)
          end
        else
          if e_type == "hero" and is_solidified == false then
--              debug_print "ME NON SOLID NOW"
            is_solidified = true
            entity:set_traversable_by("hero", true)
          end
        end
        --update entity position end

      end
    end
  end
  --Finally, update the previous position
  entity.old_x=x
  entity.old_y=y

-- debug_print ("Job's done for" ..(entity:get_name() or "<some entity>")) 
end

sol.timer.start(entity, 10, function()
    entity.elapsed_time=entity.elapsed_time+10
    local a=-math.cos(entity.elapsed_time/entity.cycle_duration*math.pi*2)+1
    local new_x = entity.start_x + a*ax
    local new_y = entity.start_y + a*ay
    entity:set_position(new_x,new_y)
    return true
  end)