-- Initialize block behavior specific to this quest.

-- Variables
local block_meta = sol.main.get_metatable("block")
require("scripts/multi_events")
-- Include scripts
local audio_manager = require("scripts/audio_manager")
local entity_manager = require("scripts/maps/entity_manager")
local math_utils = require("scripts/tools/math_utils")

function block_meta:on_created()
  self:set_drawn_in_y_order()
  self.movement_start_x, self.movement_start_y=self:get_position()
end

function block_meta:on_removed()

  local game = self:get_game();
  local map = game:get_map()
  if self:get_ground_below()== 'hole' then
    local x,y, layer=self:get_position()
    local sprite=self:get_sprite()
      local falling_entity = self:get_map():create_custom_entity({
      name="falling_block_actor",
      sprite = sprite:get_animation_set(),
      x = x,
      y = y,
      width = 16,
      height = 16,
      layer = layer,
      direction = 0,
    })
    falling_entity:set_traversable_by("hero", false)
    falling_entity:set_can_traverse_ground("hole", true)
    local m=sol.movement.create("straight")
    if x~=self.movement_start_x then
      m:set_max_distance(16-math.abs(x-self.movement_start_x))
    elseif y~=self.movement_start_y then
      m:set_max_distance(16-math.abs(y-self.movement_start_y))
    end
    debug_print ("distance to go: "..m:get_max_distance())
    m:set_angle(self:get_angle(self.movement_start_x, self.movement_start_y)+math.pi)
    m:register_event("on_obstacle_reached", function()
        debug_print "fake block: obstacle_reached"
        entity_manager:fall(falling_entity)       
      end)
    m:start(falling_entity, function()
        debug_print "fake block: movement over"
        entity_manager:fall(falling_entity)
      end)
  end
end
function block_meta:on_movement_started(movement)
  
  --The following line returns "movement", should be something like "straignt_movement" or "piel_movement", hence the bugs when trying to call the type-specific movement methods. This is obviously an engine bug.
--  debug_print ("block movement type: "..sol.main.get_type(movement)) 
--  movement:set_ignore_obstacles()
end

function block_meta:on_moving()
  self.movement_start_x, self.movement_start_y = self:get_position()
  local x_start, y_start = self:get_position() 
  sol.timer.start(self, 50, function()
      local x_end, y_end = self:get_position()  
      if x_start ~= x_end or y_start ~= y_end then
        audio_manager:play_sound("hero_pushes")
      end
    end)

end



function block_meta:on_position_changed(x, y, layer)

  --local moving_direction=self:get_movement():get_direction4() --BROKEN, the block mvement returns wrong object
  local moving_direction=(self:get_direction4_to(self.movement_start_x, self.movement_start_y)+2)%4 --Hack, see line above why

  if true or self:get_movement():get_ignore_obstacles() then --BROKEN see above why
    local bx,by,bh,bw=self:get_bounding_box()
    local dx, dy=unpack(math_utils.get_offset_from_direction4(moving_direction))
    for e in self:get_map():get_entities_in_rectangle(bx+dx, by+dy, bw, bh) do --push any enemy which gets overlapped by the block
      if e:get_type()=="enemy" and e:get_obstacle_behavior()~="flying" then
        local ex,ey=e:get_position()
        e:set_position(ex+dx, ey+dy)
      end
    end
  end

end