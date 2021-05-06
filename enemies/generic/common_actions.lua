----------------------------------
--
-- Add some basic methods to an enemy.
-- There is no passive behavior without an explicit start when learning this to an enemy.
--
-- Methods : General informations :
--           enemy:is_aligned(entity, thickness, [sprite])
--           enemy:is_near(entity, triggering_distance, [sprite])
--           enemy:is_leashed_by(entity)
--           enemy:is_over_grounds(grounds)
--           enemy:is_watched([sprite, [fully_visible]])
--           enemy:get_angle_from_sprite(sprite, entity)
--           enemy:get_central_symmetry_position(x, y)
--           enemy:get_grid_position()
--           enemy:get_obstacles_normal_angle()
--           enemy:get_obstacles_bounce_angle([angle])
--
--           Movements and positioning :
--           enemy:start_straight_walking(angle, speed, [distance, [on_stopped_callback]])
--           enemy:start_target_walking(entity, speed)
--           enemy:start_jumping(duration, height, [angle, speed, [on_finished_callback]])
--           enemy:start_flying(take_off_duration, height, [on_finished_callback])
--           enemy:stop_flying(landing_duration, [on_finished_callback])
--           enemy:start_attracting(entity, speed, [moving_condition_callback])
--           enemy:stop_attracting()
--           enemy:start_impulsion(x, y, speed, acceleration, deceleration)
--           enemy:start_throwing(entity, duration, start_height, maximum_height, [angle, speed, [on_finished_callback]])
--           enemy:start_welding(entity, [x_offset, [y_offset]])
--           enemy:start_leashed_by(entity, maximum_distance)
--           enemy:stop_leashed_by(entity)
--           enemy:start_pushed_back(entity, [speed, [duration, [on_finished_callback]]])
--           enemy:start_pushing_back(entity, [speed, [duration, [on_finished_callback]]])
--           enemy:start_shock(entity, [speed, [duration, [on_finished_callback]]])
--
--           Effects and other actions :
--           enemy:silent_kill()
--           enemy:start_shadow([sprite_name, [animation_name]])
--           enemy:start_brief_effect(sprite_name, [animation_name, [x_offset, [y_offset, [maximum_duration, [on_finished_callback]]]]])
--           enemy:steal_item(item_name, [variant, [only_if_assigned, [drop_when_dead]]])
--
-- Usage : 
-- local my_enemy = ...
-- local common_actions = require("enemies/lib/common_actions")
-- common_actions.learn(my_enemy)
--
----------------------------------

local common_actions = {}

function common_actions.learn(enemy)

  local game = enemy:get_game()
  local map = enemy:get_map()
  local hero = map:get_hero()
  local camera = map:get_camera()
  local trigonometric_functions = {math.cos, math.sin}
  local circle = 2.0 * math.pi
  local quarter = 0.5 * math.pi
  local eighth = 0.25 * math.pi

  local attracting_timers = {}
  local leashing_timers = {}
  local shadow = nil
  
  local function xor(a, b)
    return (a or b) and not (a and b)
  end

  -- Return true if the entity is on the same row or column than the entity.
  function enemy:is_aligned(entity, thickness, sprite)

    local half_thickness = thickness * 0.5
    local entity_x, entity_y, entity_layer = entity:get_position()
    local x, y, layer = enemy:get_position()
    if sprite then
      local x_offset, y_offset = sprite:get_xy()
      x, y = x + x_offset, y + y_offset
    end

    return (math.abs(entity_x - x) < half_thickness or math.abs(entity_y - y) < half_thickness)
      and (layer == entity_layer or enemy:has_layer_independent_collisions())
  end

  -- Return true if the entity is closer to the enemy than triggering_distance
  function enemy:is_near(entity, triggering_distance, sprite)

    local entity_layer = entity:get_layer()
    local x, y, layer = enemy:get_position()
    if sprite then
      local x_offset, y_offset = sprite:get_xy()
      x, y = x + x_offset, y + y_offset
    end

    return entity:get_distance(x, y) < triggering_distance 
      and (layer == entity_layer or enemy:has_layer_independent_collisions())
  end

  -- Return true if the enemy is currently leashed by the entity.
  function enemy:is_leashed_by(entity)
    return leashing_timers[entity] ~= nil
  end

  -- Return true if the four corners of the enemy are over one of the given ground, not necessarily the same.
  function enemy:is_over_grounds(grounds)

    local x, y, layer = enemy:get_position()
    local width, height = enemy:get_size()
    local origin_x, origin_y = enemy:get_origin()
    x, y = x - origin_x, y - origin_y

    local function is_position_over_grounds(x, y)
      for _, ground in pairs(grounds) do
        if string.find(map:get_ground(x, y, layer), ground) then
          return true
        end
      end
      return false
    end

    return is_position_over_grounds(x, y)
        and is_position_over_grounds(x + width, y)
        and is_position_over_grounds(x, y + height)
        and is_position_over_grounds(x + width, y + height)
  end

  -- Return true if the enemy or its given sprite is partially visible at the camera, or fully visible if requested.
  function enemy:is_watched(sprite, fully_visible)

    local camera_x, camera_y = camera:get_position()
    local camera_width, camera_height = camera:get_size()
    local target = sprite or enemy
    local x, y, _ = enemy:get_position()
    local width, height = target:get_size()
    local origin_x, origin_y = target:get_origin()
    x, y = x - origin_x, y - origin_y

    if sprite then
      local offset_x, offset_y = sprite:get_xy()
      x, y = x + offset_x, y + offset_y
    end

    if fully_visible then
      x, y = x + width, y + height
      width, height = -width, -height
    end

    return x + width >= camera_x and x <= camera_x + camera_width 
        and y + height >= camera_y and y <= camera_y + camera_height
  end

  -- Return the angle from the enemy sprite to given entity.
  function enemy:get_angle_from_sprite(sprite, entity)

    local x, y, _ = enemy:get_position()
    local sprite_x, sprite_y = sprite:get_xy()
    local entity_x, entity_y, _ = entity:get_position()

    return math.atan2(y - entity_y + sprite_y, entity_x - x - sprite_x)
  end

  -- Return the central symmetry position over the given point.
  function enemy:get_central_symmetry_position(x, y)

    local enemy_x, enemy_y, _ = enemy:get_position()
    return 2.0 * x - enemy_x, 2.0 * y - enemy_y
  end

  -- Get the upper-left grid node coordinates of the enemy position.
  function enemy:get_grid_position()

    local position_x, position_y, _ = enemy:get_position()
    return position_x - position_x % 8, position_y - position_y % 8
  end

  -- Return the normal angle of close obstacles as a multiple of pi/4, or nil if none.
  function enemy:get_obstacles_normal_angle()

    local collisions = {
      [0] = enemy:test_obstacles(-1,  0),
      [1] = enemy:test_obstacles(-1,  1),
      [2] = enemy:test_obstacles( 0,  1),
      [3] = enemy:test_obstacles( 1,  1),
      [4] = enemy:test_obstacles( 1,  0),
      [5] = enemy:test_obstacles( 1, -1),
      [6] = enemy:test_obstacles( 0, -1),
      [7] = enemy:test_obstacles(-1, -1)
    }

    -- Return the normal angle for this direction if collision on the direction or the two surrounding ones, and no obstacle in the two next or obstacle in both.
    local function check_normal_angle(direction8)
      return ((collisions[direction8] or collisions[(direction8 - 1) % 8] and collisions[(direction8 + 1) % 8]) 
          and not xor(collisions[(direction8 - 2) % 8], collisions[(direction8 + 2) % 8])
          and direction8 * eighth)
    end

    -- Check for obstacles on each direction8 and return the normal angle if it is the correct one.
    local normal_angle
    for direction8 = 0, 7 do
      normal_angle = normal_angle or check_normal_angle(direction8)
    end

    return normal_angle
  end

  -- Return the angle after bouncing against close obstacles towards the given angle, or nil if no obstacles.
  function enemy:get_obstacles_bounce_angle(angle)

    local normal_angle = enemy:get_obstacles_normal_angle()
    if not normal_angle then
      return
    end
    angle = angle or enemy:get_movement():get_angle()

    return (2.0 * normal_angle - angle + math.pi) % circle
  end

  -- Make the enemy straight move.
  function enemy:start_straight_walking(angle, speed, distance, on_stopped_callback)

    local movement = sol.movement.create("straight")
    movement:set_speed(speed)
    movement:set_max_distance(distance or 0)
    movement:set_angle(angle)
    movement:set_smooth(true)
    movement:start(enemy)

    -- Consider the current move as stopped if finished or stuck.
    function movement:on_finished()
      if on_stopped_callback then
        on_stopped_callback()
      end
    end
    function movement:on_obstacle_reached()
      movement:stop()
      if on_stopped_callback then
        on_stopped_callback()
      end
    end

    -- Update the enemy sprites.
    for _, sprite in enemy:get_sprites() do
      if sprite:has_animation("walking") and sprite:get_animation() ~= "walking" then
        sprite:set_animation("walking")
      end
      sprite:set_direction(movement:get_direction4())
    end

    return movement
  end

  -- Make the enemy move to the entity.
  function enemy:start_target_walking(entity, speed)

    local movement = sol.movement.create("target")
    movement:set_speed(speed)
    movement:set_target(entity)
    movement:start(enemy)

    -- Update enemy sprites.
    local direction = movement:get_direction4()
    for _, sprite in enemy:get_sprites() do
      if sprite:has_animation("walking") and sprite:get_animation() ~= "walking" then
        sprite:set_animation("walking")
      end
      sprite:set_direction(direction)
    end
    function movement:on_position_changed()
      if movement:get_direction4() ~= direction then
        direction = movement:get_direction4()
        for _, sprite in enemy:get_sprites() do
          sprite:set_direction(direction)
        end
      end
    end

    return movement
  end

  -- Make the enemy start jumping.
  function enemy:start_jumping(duration, height, angle, speed, on_finished_callback)

    local movement

    -- Schedule an update of the sprite vertical offset by frame.
    local elapsed_time = 0
    sol.timer.start(enemy, 10, function()

      elapsed_time = elapsed_time + 10
      if elapsed_time < duration then
        for _, sprite in enemy:get_sprites() do
          sprite:set_xy(0, -math.sqrt(math.sin(elapsed_time / duration * math.pi)) * height)
        end
        return true
      else
        for _, sprite in enemy:get_sprites() do
          sprite:set_xy(0, 0)
        end
        if movement and enemy:get_movement() == movement then
          movement:stop()
        end

        -- Call events once jump finished.
        if on_finished_callback then
          on_finished_callback()
        end
      end
    end)
    enemy:set_obstacle_behavior("flying")

    -- Move the enemy on-floor if requested.
    if angle then
      movement = sol.movement.create("straight")
      movement:set_speed(speed)
      movement:set_angle(angle)
      movement:set_smooth(false)
      movement:start(enemy)
    
      return movement
    end
  end

  -- Make the enemy start flying.
  function enemy:start_flying(take_off_duration, height, on_finished_callback)

    -- Make enemy sprites start elevating.
    local event_called = false
    for _, sprite in enemy:get_sprites() do
      local movement = sol.movement.create("straight")
      movement:set_speed(height * 1000 / take_off_duration)
      movement:set_max_distance(height)
      movement:set_angle(math.pi * 0.5)
      movement:set_ignore_obstacles(true)
      movement:start(sprite)

      -- Call on_finished_callback() at the first movement finished.
      if not event_called then
        event_called = true
        function movement:on_finished()
          if on_finished_callback then
            on_finished_callback()
          end
        end
      end
    end
    enemy:set_obstacle_behavior("flying")
  end

  -- Make the enemy stop flying.
  function enemy:stop_flying(landing_duration, on_finished_callback)

    -- Make the enemy sprites start landing.
    local event_called = false
    for _, sprite in enemy:get_sprites() do
      local _, height = sprite:get_xy()
      height = math.abs(height)

      local movement = sol.movement.create("straight")
      movement:set_speed(height * 1000 / landing_duration)
      movement:set_max_distance(height)
      movement:set_angle(-math.pi * 0.5)
      movement:set_ignore_obstacles(true)
      movement:start(sprite)

      -- Call on_finished_callback() at the first movement finished.
      if not event_called then
        event_called = true
        function movement:on_finished()
          if on_finished_callback then
            on_finished_callback()
          end
        end
      end
    end
  end

  -- Start attracting the given entity, negative speed possible.
  function enemy:start_attracting(entity, speed, moving_condition_callback)

    -- Workaround : Don't use solarus movements to be able to start several movements at the same time.
    local move_ratio = speed > 0 and 1 or -1
    attracting_timers[entity] = {}

    local function attract_on_axis(axis)

      local entity_position = {entity:get_position()}
      local enemy_position = {enemy:get_position()}
      local angle = math.atan2(entity_position[2] - enemy_position[2], enemy_position[1] - entity_position[1])
      
      local axis_move = {0, 0}
      local axis_move_delay = 10 -- Default timer delay if no move

      if not moving_condition_callback or moving_condition_callback() then

        -- Always move pixel by pixel.
        axis_move[axis] = math.max(-1, math.min(1, enemy_position[axis] - entity_position[axis])) * move_ratio
        if axis_move[axis] ~= 0 then

          -- Schedule the next move on this axis depending on the remaining distance and the speed value, avoiding too high and low timers.
          axis_move_delay = 1000.0 / math.max(1, math.min(100, math.abs(speed * trigonometric_functions[axis](angle))))

          -- Move the entity.
          if not entity:test_obstacles(axis_move[1], axis_move[2]) then
            entity:set_position(entity_position[1] + axis_move[1], entity_position[2] + axis_move[2], entity_position[3])
          end
        end
      end

      -- Start the next pixel move timer.
      attracting_timers[entity][axis] = sol.timer.start(enemy, axis_move_delay, function()
        attract_on_axis(axis)
      end)
    end

    attract_on_axis(1)
    attract_on_axis(2)
  end

  -- Stop looped timers related to the attractions.
  function enemy:stop_attracting()

    for _, timers in pairs(attracting_timers) do
      if timers then
        for i = 1, 2 do
          if timers[i] then
            timers[i]:stop()
          end
        end
      end
    end
  end

  -- Start a straight move to the given target and apply a constant acceleration and deceleration (px/s²).
  function enemy:start_impulsion(x, y, speed, acceleration, deceleration)

    -- Workaround : Don't use solarus movements to be able to start several movements at the same time.
    local movement = {}
    local timers = {}
    local angle = enemy:get_angle(x, y)
    local start = {enemy:get_position()}
    local target = {x, y}
    local accelerations = {acceleration, acceleration}
    local ignore_obstacles = false

    -- Call given event on the movement table.
    local function call_event(event)
      if event then
        event(movement)
      end
    end

    -- Schedule 1 pixel moves on each axis depending on the given acceleration.
    local function move_on_axis(axis)

      local axis_current_speed = math.abs(trigonometric_functions[axis](angle) * 2.0 * acceleration)
      local axis_maximum_speed = math.abs(trigonometric_functions[axis](angle) * speed)
      local axis_move = {[axis % 2 + 1] = 0, [axis] = math.max(-1, math.min(1, target[axis] - start[axis]))}

      -- Avoid too low speed (less than 1px/s).
      if axis_current_speed < 1 then
        accelerations[axis] = 0
        return
      end

      return sol.timer.start(enemy, 1000.0 / axis_current_speed, function()

        -- Move enemy if it wouldn't reach an obstacle.
        local position = {enemy:get_position()}
        if ignore_obstacles or not enemy:test_obstacles(axis_move[1], axis_move[2]) then
          enemy:set_position(position[1] + axis_move[1], position[2] + axis_move[2], position[3])
          call_event(movement.on_position_changed)
        else
          call_event(movement.on_obstacle_reached)
          timers[axis] = nil
          return false
        end

        -- Replace axis acceleration by negative deceleration if beyond axis target.
        local axis_position = position[axis] + axis_move[axis]
        if accelerations[axis] > 0 and math.min(start[axis], axis_position) <= target[axis] and target[axis] <= math.max(start[axis], axis_position) then
          accelerations[axis] = -deceleration
          call_event(movement.on_changed)

          -- Call decelerating callback if both axis timers are decelerating.
          if accelerations[axis % 2 + 1] <= 0 then
            call_event(movement.on_decelerating)
          end
        end

        -- Update speed between 0 and maximum speed (px/s) depending on acceleration.
        axis_current_speed = math.min(math.sqrt(math.max(0, math.pow(axis_current_speed, 2.0) + 2.0 * accelerations[axis])), axis_maximum_speed)     

        -- Schedule the next pixel move and avoid too low timers (less than 1px/s).
        if axis_current_speed >= 1 then
          return 1000.0 / axis_current_speed
        end

        -- Call on_finished() event when the last axis timers finished normally.
        timers[axis] = nil
        if not timers[axis % 2 + 1] then
          call_event(movement.on_finished)
        end
      end)
    end
    timers = {move_on_axis(1), move_on_axis(2)}

    -- TODO Reproduce generic build-in movement methods on the returned movement table.
    function movement:stop()
      for i = 1, 2 do
        if timers[i] then
          timers[i]:stop()
        end
      end
    end
    function movement:set_ignore_obstacles(ignore)
      ignore_obstacles = ignore or true
    end
    function movement:get_direction4()
      return math.floor((angle / circle * 8 + 1) % 8 / 2)
    end

    return movement
  end

  -- Throw the given entity.
  function enemy:start_throwing(entity, duration, start_height, maximum_height, angle, speed, on_finished_callback)

    local movement

    -- Consider the throw as an already-started sinus function, depending on start_height.
    local elapsed_time = duration / (1 - math.asin(math.pow(start_height / maximum_height, 2)) / math.pi) - duration
    duration = duration + elapsed_time

    -- Schedule an update of the sprite vertical offset by frame.
    sol.timer.start(entity, 10, function()

      elapsed_time = elapsed_time + 10
      if elapsed_time < duration then
        for sprite_name, sprite in entity:get_sprites() do
          if sprite_name ~= "shadow_override" then -- Workaround : Don't change shadow height when the sprite is part of the entity.
            sprite:set_xy(0, -math.sqrt(math.sin(elapsed_time / duration * math.pi)) * maximum_height)
          end
        end
        return true
      else
        for _, sprite in entity:get_sprites() do
          sprite:set_xy(0, 0)
        end
        if movement and entity:get_movement() == movement then
          movement:stop()
        end

        -- Call events once jump finished.
        if on_finished_callback then
          on_finished_callback()
        end
      end
    end)

    -- Move the entity on-floor if requested.
    if angle then
      movement = sol.movement.create("straight")
      movement:set_speed(speed)
      movement:set_angle(angle)
      movement:set_smooth(false)
      movement:start(entity)
    
      return movement
    end
  end

  -- Make the entity welded to the enemy at the given offset position, and propagate main events and methods.
  function enemy:start_welding(entity, x_offset, y_offset)

   x_offset = x_offset or 0
   y_offset = y_offset or 0
    enemy:register_event("on_update", function(enemy) -- Workaround : Replace the entity in on_update() instead of on_position_changed() to take care of hurt movements.
      local x, y, layer = enemy:get_position()
      entity:set_position(x + x_offset, y + y_offset)
    end)
    enemy:register_event("on_removed", function(enemy)
      entity:remove()
    end)
    enemy:register_event("on_enabled", function(enemy)
      entity:set_enabled()
    end)
    enemy:register_event("on_disabled", function(enemy)
      entity:set_enabled(false)
    end)
    enemy:register_event("on_dying", function(enemy)
      sol.timer.start(entity, 300, function() -- No event when the enemy became invisible, hardcode a timer.
        entity:set_enabled(false)
      end)
    end)
    enemy:register_event("set_visible", function(enemy, visible)
      entity:set_visible(visible)
    end)
  end

  -- Set a maximum distance between the enemy and an entity, else replace the enemy near it.
  function enemy:start_leashed_by(entity, maximum_distance)

    leashing_timers[entity] = sol.timer.start(enemy, 10, function()
      
      if enemy:get_distance(entity) > maximum_distance then
        local enemy_x, enemy_y, layer = enemy:get_position()
        local hero_x, hero_y, _ = hero:get_position()
        local vX = enemy_x - hero_x;
        local vY = enemy_y - hero_y;
        local magV = math.sqrt(vX * vX + vY * vY);
        local x = hero_x + vX / magV * maximum_distance;
        local y = hero_y + vY / magV * maximum_distance;

        -- Move the entity.
        if not enemy:test_obstacles(x - enemy_x, y - enemy_y) then
          enemy:set_position(x, y, layer)
        end
      end

      return true
    end)
  end

  -- Stop the leashing attraction on the given entity
  function enemy:stop_leashed_by(entity)
    if leashing_timers[entity] then
      leashing_timers[entity]:stop()
      leashing_timers[entity] = nil
    end
  end

  -- Start pushing back the enemy.
  function enemy:start_pushed_back(entity, speed, duration, on_finished_callback)

    local movement = sol.movement.create("straight")
    movement:set_speed(speed or 100)
    movement:set_angle(entity:get_angle(enemy))
    movement:set_smooth(false)
    movement:start(enemy)

    sol.timer.start(enemy, duration or 150, function()
      movement:stop()
      if on_finished_callback then
        on_finished_callback()
      end
    end)
  end

  -- Start pushing the entity back.
  function enemy:start_pushing_back(entity, speed, duration, on_finished_callback)
    
    -- Workaround: Movement crashes sometimes when used at the wrong time on the hero, use a negative attraction instead.
    enemy:start_attracting(entity, -speed or 100)

    sol.timer.start(enemy, duration or 150, function()
      enemy:stop_attracting()
      if on_finished_callback then
        on_finished_callback()
      end
    end)
  end

  -- Start pushing both enemy and entity back with an impact effect.
  function enemy:start_shock(entity, speed, duration, on_finished_callback)

    local x, y, _ = enemy:get_position()
    local hero_x, hero_y, _ = hero:get_position()
    enemy:start_pushing_back(hero, speed or 100, duration or 150)
    enemy:start_pushed_back(hero, speed or 100, duration or 150, function()
      if on_finished_callback then
        on_finished_callback()
      end
    end)
    enemy:start_brief_effect("entities/effects/impact_projectile", "default", (hero_x - x) / 2, (hero_y - y) / 2)
  end

  -- Kill the enemy right now, silently and without animation.
  function enemy:silent_kill()

    enemy.is_hurt_silently = true -- Workaround : Don't play sounds added by enemy meta script.

    if enemy.on_dying then
      enemy:on_dying()
    end
    enemy:remove()
    if enemy.on_dead then
      enemy:on_dead()
    end

    -- TODO Handle savegame if any.
  end

  -- Add a shadow below the enemy.
  function enemy:start_shadow(sprite_name, animation_name)

    if not shadow then
      local enemy_x, enemy_y, enemy_layer = enemy:get_position()
      shadow = map:create_custom_entity({
        direction = 0,
        x = enemy_x,
        y = enemy_y,
        layer = enemy_layer,
        width = 16,
        height = 16,
        sprite = sprite_name or "entities/shadows/shadow"
      })
      enemy:start_welding(shadow)

      if animation_name then
        shadow:get_sprite():set_animation(animation_name)
      end
      shadow:set_traversable_by(true)
      
      -- Always display the shadow on the lowest possible layer.
      function shadow:on_position_changed(x, y, layer)
        for ground_layer = enemy:get_layer(), map:get_min_layer(), -1 do
          if map:get_ground(x, y, ground_layer) ~= "empty" then
            if shadow:get_layer() ~= ground_layer then
              shadow:set_layer(ground_layer)
            end
            break
          end
        end
      end

      -- Make enemy:set_visible() affect shadow.
      enemy:register_event("set_visible", function(enemy, visible)
        shadow:set_visible(visible)
      end)
    end
    return shadow
  end

  -- Start a standalone sprite animation on the enemy position, that will be removed once finished or maximum_duration reached if given.
  function enemy:start_brief_effect(sprite_name, animation_name, x_offset, y_offset, maximum_duration, on_finished_callback)

    local x, y, layer = enemy:get_position()
    local entity = map:create_custom_entity({
        sprite = sprite_name,
        x = x + (x_offset or 0),
        y = y + (y_offset or 0),
        layer = layer,
        width = 80,
        height = 32,
        direction = 0
    })
    entity:set_drawn_in_y_order()

    -- Remove the entity once animation finished or max_duration reached.
    local function on_finished()
      if on_finished_callback then
        on_finished_callback()
      end
      entity:remove()
    end
    local sprite = entity:get_sprite()
    sprite:set_animation(animation_name or sprite:get_animation(), function()
      on_finished()
    end)
    if maximum_duration then
      sol.timer.start(entity, maximum_duration, function()
        on_finished()
      end)
    end

    return entity
  end

  -- Steal an item and drop it when died, possibly conditionned on the variant and the assignation to a slot.
  function enemy:steal_item(item_name, variant, only_if_assigned, drop_when_dead)

    if game:has_item(item_name) then
      local item = game:get_item(item_name)
      local is_stealable = not only_if_assigned or (game:get_item_assigned(1) == item and 1) or (game:get_item_assigned(2) == item and 2)

      if (not variant or item:get_variant() == variant) and is_stealable then 
        if drop_when_dead then
          enemy:set_treasure(item_name, item:get_variant()) -- TODO savegame variable
        end
        item:set_variant(0)
        if item_slot then
          game:set_item_assigned(item_slot, nil)
        end
      end
    end
  end
end

return common_actions