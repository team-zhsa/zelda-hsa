    local entity = ...
    -- Raft entity.
     
    sol.main.load_file("entities/generic_platform")(entity)
    local sea_foam_sprite -- Foam sprite for the raft.
    entity.speed = 20 -- Set speed.
     
    function entity:on_custom_created()
      -- Set custom properties.
      time_stopped = 1000
      self:set_can_traverse_ground("deep_water", true)
      self:set_can_traverse_ground("wall", false)
      self:set_can_traverse("jumper", false)
      self:set_can_traverse_ground("hole", false)
      self:set_can_traverse_ground("traversable", true)
      self:set_can_traverse_ground("shallow_water", false)
      self:set_can_traverse_ground("grass", false)
      
      -- Customize movement.
      local direction = self:get_direction()
      local m = sol.movement.create("path")
      m:set_path{direction * 2}; m:set_speed(entity.speed)
      m:set_loop(true); m:start(self)
      is_moving = true
      
      -- Start the sea foam and wavering.
      self:add_sea_foam()
      self:start_wavering() -- Start moving raft sprite to simulate the waves.
    end
     
    ----------------- Raft functions:
     
    -- Add the sea foam sprite.
    function entity:add_sea_foam()
      -- Remark: The variable sea_foam_sprite is already local in this script!
      sea_foam_sprite = self:create_sprite("things/platform")
      sea_foam_sprite:set_animation("sea_foam")
      sea_foam_sprite:set_xy(-8,24)
    end
     
    -- Make the sprite move up and down.
    function entity:start_wavering()
      local sprite = self:get_sprite()
      -- Define vectors with the shifts of each "frame" of the sprite and time for each pause between "frames".
      local raft_dy = {0,-1,-2,-1} -- Shifts for the "y" coordinate of the sprite.
      local entities_dy = {1,-1,-1,1} -- Shifts for the "y" coordinate of position of entities.
      local pause_time = {200,1000,200,1000} -- Pause times between "frames".
      
      -- Move the movable entities located over the platform, if possible.
      local function shift_entities(dy_shift)
        local movable_entities = entity:get_movable_entities()
        local x, y, z = self:get_position()
        local bx, by, w, h = self:get_bounding_box()
        for _, something in pairs(movable_entities) do   
          if entity:is_on_platform(something, bx, by, w, h) then    
                  local sx, sy, sz = something:get_position()
            -- Move only entities that can be moved.
            local needs_move = false
            if something:get_type() == "hero" then 
              if something:get_animation() ~= "walking" then 
                needs_move = true 
              end 
            elseif something:get_sprite() then
              if something:get_sprite():get_animation() ~= "walking" then
                needs_move = true
              end
            end
            -- Check for obstacles.
            local found_obstacles = something:test_obstacles(0, dy_shift, sz)
            -- Finally check if the entity is not in the "bad border" to move it without getting out the platform.
            if needs_move and (not found_obstacles) then
              if (sy + dy_shift) >= by+2 and (sy + dy_shift) <= by+h-3 then sy = sy +dy_shift end
              something:set_position(sx, sy, sz)
            end
          end
        end
      end
     
      -- Shift sprite and move entities.
      local function set_frame_loop(frame_nb)
        -- Shift the sprite. Shift entities above the rift, if possible.
        sprite:set_xy(0, raft_dy[frame_nb])
        shift_entities(entities_dy[frame_nb])
        -- Restart the loop.
        frame_nb = (frame_nb %4) +1 -- Next frame index.
        sol.timer.start(entity, pause_time[frame_nb], function() set_frame_loop(frame_nb) end)
      end
      
      -- Start the wavering loop.  
      set_frame_loop(1) 
    end
     