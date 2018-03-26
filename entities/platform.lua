    -- Platform: entity which moves in either horizontally or vertically (depending on direction) 
    -- and carries the hero on it.
    local entity = ...
    local map = entity:get_map()
    local game = entity:get_game()
    local hero = map:get_hero()
     
    entity.can_save_state = true
     
    local time_stopped = 1000
    local is_moving = false
    -- Remark: speeds bigger than 12 give problems for water platforms (rafts) when trying to enter or go out. No problem above holes.
    entity.speed = 50 -- Set speed.
     
    function entity:on_created()
      --self:create_sprite("entities/platform")
      self:set_size(32, 32)
      self:set_origin(16, 13) -- Important: the 32x32 sprite must have center in (16,13).
      self:set_modified_ground("traversable")
      
      -- Set dynamic solid ground position for the hero to avoid problems.
      sol.timer.start(entity, 10, function()
        -- Do nothing if hero is not on solid ground.
        local is_hero_on_solid_ground = map:is_solid_ground(hero:get_ground_position())
        if hero.is_jumping or not is_hero_on_solid_ground then return true end
        -- Save or clear solid ground position on this platform.
        if map.current_hero_platform ~= entity and self:is_on_platform(hero) then
          map.current_hero_platform = entity
          self:save_hero_position() -- Save solid ground on the platform.
        elseif map.current_hero_platform == entity and (not self:is_on_platform(hero)) then
          map.current_hero_platform = nil
          hero:reset_solid_ground() -- Clear solid ground.
        end
        return true
      end)
     
      -- Custom function.
      if entity.on_custom_created then 
        entity:on_custom_created()
        return
      end
      
      -- Initialize properties.
      self:set_can_traverse("jumper", true)
      self:set_can_traverse_ground("hole", true)
      self:set_can_traverse_ground("deep_water", true)
      self:set_can_traverse_ground("traversable", true)
      self:set_can_traverse_ground("shallow_water", true)
      self:set_can_traverse_ground("wall", false)
     
      -- Start movement.
      local direction = self:get_direction()
      local m = sol.movement.create("path")
      m:set_path{direction * 2}; m:set_speed(entity.speed)
      m:set_loop(true); m:start(self)
      is_moving = true
     
    end
     
    -- Function to save hero position on the platform.
    function entity:save_hero_position()
      hero:save_solid_ground(function()
        --[[ When the hero reappears, the camera moves towards the new position,
        which produces a delay, and the platform has already moved when the hero appers.
        To fix this problem, change the position of the hero directly, so the movement
        will be instantaneous with no delay. To avoid this we must not call
        "hero:get_solid_ground_position()", or there will be problems with platforms.
        --]]
        local x, y, layer = entity:get_center_position()
        -- Change position at next cycle to avoid engine problems (keep this timer!).
        sol.timer.start(self, 1, function()
          hero:unfreeze() 
          hero:set_blinking(true, 1000)
          hero:set_invincible(true, 1000)
          hero:set_position(x, y, layer)
        end)
        return x, y, layer
      end)
    end
     
     
    -- Update shifting variables for the translation.
    local function get_shifts()
      local direction = entity:get_direction()
      local dx, dy = 0, 0 -- Variables for the translation.
      if direction == 0 then dx = 1 elseif direction == 1 then dy = -1
      elseif direction == 2 then dx = -1 elseif direction == 3 then dy = 1 end
      return dx, dy
    end
     
    -- Get movable entities that were on the previous position of the platform.
    function entity:get_movable_entities()
      local movable_entities = {}
      for other in map:get_entities_in_rectangle(entity:get_bounding_box()) do
        -- Check only entities that can be moved, including the hero.
        if other.moved_on_platform or other:get_type() == "hero" then
          -- Check if the entity was on the platform before the movement.
          if entity:was_on_platform(other) and entity:is_on_platform(other) then 
            -- Exclude portable entities unless they are on the ground.
            if (not other.is_portable) or other.state == "on_ground" then
              table.insert(movable_entities, other)
            end          
          end
        end
      end   
      return movable_entities
    end
     
    -- Return true if an entity is on the platform.
    -- IMPORTANT: This function is only used in the script generic_portable.lua.
    function entity:is_on_platform(other)
      local x, y, layer = other:get_ground_position()
      return entity:overlaps(x, y)
    end
     
    -- Return true if an entity was on the platform before the movement.
    function entity:was_on_platform(other)
      local dx, dy = get_shifts()
      local ox, oy, oz = other:get_ground_position()
      local bx, by, w, h = entity:get_bounding_box()
      local pbx, pby = bx-dx, by-dy -- Previous position of bounding box (before the movement).
      return ox >= pbx and ox < pbx+w and oy >= pby and oy < pby+h
    end
     
    function entity:on_obstacle_reached(movement)
      --Make the platform turn back.
      local direction = self:get_direction()
      movement:stop(); is_moving = false
      movement = sol.movement.create("path")    
      direction = (direction+2)%4
      self:set_direction(direction)
      movement:set_path{direction * 2}
      movement:set_speed(entity.speed)
      movement:set_loop(true)
      sol.timer.start(self, time_stopped, function()
        movement:start(self)
        is_moving = true  
      end)
    end
     
    -- Move the movable entities that were on the platform before the movement.
    function entity:on_position_changed()
      -- Get the movable entities that were on the platform before the change of position.
      local dx, dy = get_shifts() -- Variables for the translation.
      local movable_entities = entity:get_movable_entities()
      local ex, ey, ez = self:get_position()
      local bx, by, w, h = self:get_bounding_box()
      local pbx, pby = bx-dx, by-dy -- Previous position of bounding box (before the movement).
      for _, other in pairs(movable_entities) do
        local ox, oy, oz = other:get_position() 
        -- Move the entity with the platform.
        if not other:test_obstacles(dx, dy, oz) then 
          other:set_position(ox + dx, oy + dy, oz)
        end
      end
    end
     