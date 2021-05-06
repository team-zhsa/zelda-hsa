--[[

  Twin platforms
  
  When one goes up, the other one goes down.
  And what's even cooler is that it manages it's own chain. No extra entity required!
  
  To make the system work:
  
  1. place two custom entities on the map. Any size will work
  2. Apply this model to them, as well as a sprite so you can see them
  3. Give them a name accoring to these rules:
    -They must have the same prefix, which will be unique for this particular couple
    -It must finish the caracter "_", following by either 1 or 2
  If configures correctly, then their movements shound be mirrored when stepped on
  
--]]

-- Variables
local entity = ...

local game = entity:get_game()
local hero = game:get_hero()
local max_dy=1
local accel = 0.1
local accel_duration = 1
local old_x=0
local old_y=0
local true_x, true_y
local initial_x, initial_y
entity.speed=0
local twin=nil
local chain=nil
local solidified=true

-- Include scripts
--require("scripts/multi_events")

-- Event called when the custom entity is initialized.
entity:register_event("on_created", function()
    --Get the twin entity
    local name=entity:get_name()
    twin = entity:get_map():get_entity(name:sub(1, -3).."_"..(3-tonumber(name:sub(-1)))) 

    --Set me up
    old_x, old_y=entity:get_bounding_box()
    entity:set_traversable_by(false)
    entity.is_on_twin=false
    local true_layer
    true_x, true_y = entity:get_position()
    initial_x, initial_y = entity:get_position()
    --Create it's chain
    chain = entity:get_map():create_custom_entity({
        x=true_x,
        y=true_y%16,
        layer=entity:get_layer(),
        direction = 0,
        width=16,
        height =true_y-(true_y%16),
        sprite = "entities/moving_platform_dg_5_chain", 
      })
    chain:set_tiled(true)
    chain:set_origin(8, 13)
  end)

local function is_on_platform(entity, other)
  if entity~=other and other:get_type()~="camera" and other~=chain then
    local x, y, w, h = entity:get_bounding_box()
    local other_x, other_y, other_w, other_h = other:get_bounding_box()
    return other_x < x+w and other_x+other_w > x and other_y <= y-1 and other_y+other_h >= y-1
  end
  return false
end

--Detects ehteher there is another entity on the platform, and moves it along
entity:add_collision_test(

  function(entity, other)
    return is_on_platform(entity, other)
  end,

  function(entity, other)
    local x,y=entity:get_bounding_box()
    if other:get_type()=="hero" then
      --Downward acceleration
      entity.speed = math.min(entity.speed+0.01*max_dy/2, max_dy)
      twin.speed=-entity.speed
    end

    --Move the other entity with me
    local dx, dy = x-old_x, y-old_y
    local other_x, other_y = other:get_position()
    if not other:test_obstacles(0, dy) then
      other:set_position(other_x+dx, other_y+dy)
    end
  end
)

function entity.reset(self)
 -- print ("reseting "..self:get_name())
  self:set_position(initial_x, initial_y)
end

function entity:on_removed()
  if chain then
    chain:remove()
    chain=nil
  end
  if twin then
    twin=nil
  end
end

function entity:on_disbled()
  if chain then
    chain:set_enabled(false)
  end    
end

function entity:on_enabled()
  if chain then
    chain:set_enabled(true)
  end    
end

--Synchronizes the associated chain
function entity:on_position_changed(x,y,layer)
  local dy = old_y+13
  chain:set_position(old_x+8, dy%16) 
  chain:set_size(16, math.max(8, dy-(dy%16)))
end

sol.timer.start(entity, 10, function() 
    local ex, ey, ew, eh=entity:get_bounding_box()
    local hx, hy, hw, hh=hero:get_bounding_box()
    local x, y=entity:get_position()
    local dx, dy = x-old_x, y-old_y

    if hy+hh <= ey+1 then

      if solidified == false then
--        debug_print "ME SOLID NOW"
        solidified = true
        entity:set_traversable_by("hero", false)
        if hx+hw<=ex+ew and hx>=ex and hy<=ey+eh-1 and hy+hh>=ey-1 then
          hero:set_position(hx+dx, hy+dy)
        end
      end


    else
      if solidified == true then
--        debug_print "ME NON SOLID NOW"
        solidified = false
        entity:set_traversable_by("hero", true)
      end
    end

    if is_on_platform(entity, hero)==false or is_on_platform(twin, hero) then
      --slowly decelerate
      if entity.speed>0 then
        entity.speed = math.max(entity.speed-0.01*max_dy, 0)
      else
        entity.speed = math.min(entity.speed+0.01*max_dy, 0)
      end
    end

    if entity:test_obstacles(0, math.floor(entity.speed)+1) or twin:test_obstacles(0, math.floor(twin.speed+1)) then
      --reset speed if there an obstacle under either of the twins
      debug_print (entity:get_name().." cannot move (position: X "..x..", Y "..y)
      entity.speed=0
    else
      --Compute the new position
      true_y=true_y+entity.speed
      entity:set_position(true_x, true_y)
      --update old position
      old_x, old_y = entity:get_bounding_box()
    end
    return true
  end)