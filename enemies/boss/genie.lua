----------------------------------
--
-- Genie.
--
-- Flying enemy that have 5 fighting steps and comes with a bottle sub enemy.
-- Starts hidden into the bottle which will go to the middle of the room, then appear and throw some fireballs to the hero, and finally hide into its bottle again to chase the hero.
-- The bottle is stunnable with a sword attack during the chasing step, and is carriable and vulnerable to a throw against obstacles while stunned.
-- Go back to the fireball steps when the bottle is hurt or stun duration finished normally.
-- Break the bottle after some hits, to make the boss appear again and chase the hero while being vulnerable to sword attacks.
-- Spin around the center of the room when hurt then throw a fireball, and finally go back to chase step again.
--
-- Events : enemy:on_step_started(step)
--          enemy:on_stunned()
--
----------------------------------

-- Global variables.
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local camera = map:get_camera()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local quarter = math.pi * 0.5
local circle = math.pi * 2.0
local bottle, bottle_sprite
local steps_callback = {}
local room_center_x, room_center_y
local current_step = 0

-- Configuration variables.
local before_steps_duration = {1500, 500, 500, 200, 200}
local before_genie_appear_duration = 1000
local bottle_slow_speed = 22
local vertical_oscillation_duration = 1200
local vertical_oscillation_height = 8
local horizontal_oscillation_duration = 5000
local horizontal_oscillation_height = 62
local fireball_number = 8
local fireball_juggling_duration = 1000
local fireball_juggling_height = 48
local fireball_throwing_duration = 600
local fireball_throwing_height = 24
local fireball_throwing_speed = 200
local between_juggling_fireballs_duration = 330
local before_throwing_fireballs_duration = 4000
local between_fireball_throw_duration = 800
local back_to_center_speed = 44
local bottle_speed = 56
local chasing_speed = 88
local chasing_acceleration = 88
local chasing_deceleration = 88
local blinking_step_duration = 50
local circle_duration = 1000
local circle_radius_diminution = 0.1
local circle_minimum_radius = 8
local spinning_minimum_duration = 2000
local spinning_maximum_duration = 4000
local hurt_duration = 600

-- Start the given step.
local function start_step(step)

  if current_step == step then -- The enemy restarted during the step, only restart the corresponding action.
    steps_callback[current_step]()
    return
  end

  current_step = step
  sol.timer.start(enemy, before_steps_duration[current_step] or 0, function()
    steps_callback[current_step]()
    if enemy.on_step_started then
      enemy:on_step_started(current_step)
    end
  end)
end

-- Start appearing.
local function start_appearing(callback)

  local x, y = bottle:get_position()
  enemy:set_position(x, y - 32)
  enemy:set_visible()
  sprite:set_animation("appearing", function()
    sprite:set_animation("walking")
    callback()
  end)
  enemy:set_can_attack(true)
end

-- Start appearing.
local function start_disappearing(callback)

  sprite:set_animation("disappearing", function()
    enemy:set_visible(false)
    enemy:set_can_attack(false)
    callback()
  end)
end

-- Create the bottle enemy.
local function create_bottle()

  bottle = enemy:create_enemy({
    name = (enemy:get_name() or enemy:get_breed()) .. "_bottle",
    breed = "boss/projectiles/bottle",
    direction = 0
  })
  bottle_sprite = bottle:get_sprite()

  local function go_back_to_step_2()
    local movement = sol.movement.create("target")
    movement:set_speed(bottle_speed)
    movement:set_target(room_center_x, room_center_y)
    movement:start(bottle)

    function movement:on_finished()
      movement:stop()
      start_appearing(function()
        bottle_sprite:set_animation("waiting")
        start_step(2)
      end)
    end
  end

  -- Go back to step 2 on bottle stun finished normally or hit an obstacle while throwed.
  bottle:register_event("on_stun_finished", function(bottle)
    go_back_to_step_2()
  end)
  bottle:register_event("on_finish_throw", function(bottle)
    go_back_to_step_2()
  end)

  -- Start step 4 on bottle broken.
  bottle:register_event("on_breaking", function(bottle)
    start_appearing(function()
      start_step(4)
    end)
  end)

  -- Propagate stun event.
  bottle:register_event("on_stunned", function(bottle)
    if enemy.on_stunned then
      enemy:on_stunned()
    end
  end)
end

-- Check if the custom death as to be started before triggering the built-in hurt behavior.
local function hurt(damage)

  -- Custom die if no more life.
  if enemy:get_life() - damage < 1 then

    -- Wait a few time, start 2 sets of explosions close from the enemy, wait a few time again and finally make the final explosion and enemy die.
    enemy:start_death(function()
      sprite:set_animation("hurt")
      sol.timer.start(enemy, 1500, function()
        enemy:start_close_explosions(32, 2500, "entities/explosion_boss", 0, -30, function()
          sol.timer.start(enemy, 1000, function()
            enemy:start_brief_effect("entities/explosion_boss", nil, 0, -30)
            finish_death()
          end)
        end)
        sol.timer.start(enemy, 200, function()
          enemy:start_close_explosions(32, 2300, "entities/explosion_boss", 0, -30)
        end)
      end)
    end)
    return
  end

  -- Manually hurt to not restart and start step 5.
  enemy:set_life(enemy:get_life() - damage)
  local movement = enemy:get_movement()
  if movement then
    movement:stop()
  end
  sol.timer.stop_all(enemy)
  enemy:set_invincible()
  enemy:start_pushed_back(hero, 250, 150, sprite)
  sprite:set_animation("hurt")
  if enemy.on_hurt then
    enemy:on_hurt()
  end

  sol.timer.start(enemy, hurt_duration, function()
    sprite:set_animation("walking")
    start_step(5)
  end)
end

-- Start juggling with a fireball.
local function start_juggling()

  local fireball = enemy:create_sprite("enemies/boss/genie/fireball")
  fireball:set_xy(-24, -24)

  local elapsed_time = 0
  sol.timer.start(enemy, 10, function()
    elapsed_time = elapsed_time + 10
    if elapsed_time < fireball_juggling_duration then
      fireball:set_xy(-24 + elapsed_time / fireball_juggling_duration * 48, -math.sin(elapsed_time / fireball_juggling_duration * math.pi) * fireball_juggling_height - 24)
      return true
    else
      enemy:remove_sprite(fireball)
    end
  end)
end

-- Throw a fireball to the hero.
local function start_throwing_fireball(on_throwed_callback)

  local direction = hero:get_position() > enemy:get_position() and 0 or 2
  sprite:set_direction(direction)
  sprite:set_animation("throwing", function()

    local fireball = enemy:create_enemy({
      name = (enemy:get_name() or enemy:get_breed()) .. "_fireball",
      breed = "boss/projectiles/fireball",
      direction = 0,
      x = direction == 0 and -12 or 12,
      y = -12
    })
    enemy:start_throwing(fireball, fireball_throwing_duration, -12, fireball_throwing_height, enemy:get_angle(hero), fireball_throwing_speed, function()
      fireball:extinguish()
    end)
    on_throwed_callback()
  end)
end

-- Start targetting the hero with acceleration.
local function start_target_impulsion()

  local target_x, target_y = hero:get_position()
  local angle = enemy:get_angle(target_x, target_y)

  -- Start moving to the target with acceleration.
  local movement = enemy:start_impulsion(angle, chasing_speed, chasing_acceleration, chasing_deceleration, 16) -- Retarget every 16px traveled.
  movement:set_ignore_obstacles(true)
  sprite:set_direction(angle > quarter and angle < 3.0 * quarter and 2 or 0)

  -- Target a new random point when target reached.
  function movement:on_decelerating()
    start_target_impulsion()
  end
end

-- Step 1, make the bottle walk to the center of the room and make the Genie appear.
local function start_step_1()

  local movement = sol.movement.create("target")
  movement:set_speed(bottle_slow_speed)
  movement:set_target(room_center_x, room_center_y)
  movement:start(bottle)
  enemy:set_invincible()
  sprite:set_direction(0)
  bottle_sprite:set_animation("hopping")

  -- Start next step on movement finished.
  function movement:on_finished()
    movement:stop()
    bottle_sprite:set_animation("waiting")
    sol.timer.start(enemy, before_genie_appear_duration, function()
      start_appearing(function()
        start_step(2)
      end)
    end)
  end
end

-- Step 2, move around the bottle and throw fireballs.
local function start_step_2()

  -- Start a vertical and horizontal oscillation.
  local initial_x, initial_y = enemy:get_position()
  local elapsed_time = 0
  local oscillating_timer = sol.timer.start(enemy, 10, function()
    elapsed_time = elapsed_time + 10
    local elapsed_horizontal_modulo = elapsed_time % horizontal_oscillation_duration
    local direction = (elapsed_horizontal_modulo < horizontal_oscillation_duration * 0.25 or elapsed_horizontal_modulo > horizontal_oscillation_duration * 0.75) and 0 or 2
    if sprite:get_direction() ~= direction and sprite:get_animation() ~= "throwing" then
      sprite:set_direction(direction)
    end
    enemy:set_position(
      initial_x + math.sin(elapsed_time / horizontal_oscillation_duration * circle) * horizontal_oscillation_height,
      initial_y + math.sin(elapsed_time / vertical_oscillation_duration * circle) * vertical_oscillation_height
    )
    return true
  end)

  -- Juggle with fireballs.
  local juggling_timer = sol.timer.start(enemy, between_juggling_fireballs_duration, function()
    start_juggling()
    return true
  end)

  -- Throw fireballs and start step 3 once they are all throwed.
  local throw_count = 0
  sol.timer.start(enemy, before_throwing_fireballs_duration, function()
    sol.timer.start(enemy, between_fireball_throw_duration, function()
      throw_count = throw_count + 1
      if throw_count <= fireball_number then
        start_throwing_fireball(function()
          sprite:set_animation("walking")
        end)
        return true
      end

      -- Move back to initial position.
      oscillating_timer:stop()
      juggling_timer:stop()
      local movement = sol.movement.create("target")
      movement:set_speed(back_to_center_speed)
      movement:set_target(initial_x, initial_y)
      movement:start(enemy)

      local angle = movement:get_angle()
      sprite:set_direction(angle > quarter and angle < 3.0 * quarter and 2 or 0)

      -- Start next step on movement finished.
      function movement:on_finished()
        movement:stop()
        start_disappearing(function()
          start_step(3)
        end)
      end
    end)
  end)
end

-- Step 3, make boss hide into the bottle and bottle charge the hero until the bottle is hurt by the sword.
local function start_step_3()

  bottle:start_target_walking(hero, bottle_speed)
  bottle:set_stunnable(true)
  bottle_sprite:set_animation("hopping")
end

-- Step 4, make the boss vulnerable and chasing the hero.
local function start_step_4()

  start_target_impulsion()
  enemy:set_can_attack(true)
  enemy:set_hero_weapons_reactions({
    sword = function() hurt(1) end
  })
  sprite:set_animation("walking")
end

-- Step 4, make the boss spin for some time, then throw a fireball and finally go back to step 4.
local function start_step_5()

  enemy:set_can_attack(false)
  enemy:set_invincible()
  local elapsed_time = 0
  local circle_radius = enemy:get_distance(room_center_x, room_center_y)
  local duration = math.random(spinning_minimum_duration, spinning_maximum_duration)
  sol.timer.start(enemy, 10, function()
    elapsed_time = elapsed_time + 10
    circle_radius = math.max(circle_radius - circle_radius_diminution, circle_minimum_radius)
    local blinking_additional_angle = elapsed_time % (blinking_step_duration * 2.0) <= blinking_step_duration and math.pi or 0
    enemy:set_position(
      room_center_x + math.cos(elapsed_time / circle_duration * circle + blinking_additional_angle) * circle_radius,
      room_center_y + math.sin(elapsed_time / circle_duration * circle + blinking_additional_angle) * circle_radius
    )

    -- If the spinning duration is reached, throw a fireball and go back to step 4.
    if elapsed_time <= duration then
      return true
    end
    start_throwing_fireball(function()
      sprite:set_animation("throwed")
      start_step(4)
    end)
  end)
end

-- Enable the bottle on enabled.
enemy:register_event("on_enabled", function(enemy)

  if bottle and bottle:exists() then
    bottle:set_enabled()
  end
end)

-- Disable the bottle on disabled.
enemy:register_event("on_disabled", function(enemy)

  if bottle and bottle:exists() then
    bottle:set_enabled(false)
  end
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(4)
  enemy:set_size(32, 32)
  enemy:set_origin(16, 29)
  enemy:set_drawn_in_y_order(false) -- Display as a flat entity to draw fireball over it.
  steps_callback = {start_step_1, start_step_2, start_step_3, start_step_4, start_step_5} -- Fill steps_callback table.
  create_bottle()

  local camera_x, camera_y, camera_width, camera_height = camera:get_bounding_box()
  room_center_x, room_center_y = camera_x + camera_width / 2.0, camera_y + camera_height / 2.0

  -- Make the boss invisible at start and move it to upper layer.
  enemy:set_layer_independent_collisions(true)
  enemy:set_layer(map:get_max_layer())
  enemy:set_visible(false)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_invincible()
  enemy:set_hero_weapons_reactions({
    sword = current_step == 4 and function() hurt(1) end or "ignored"
  })

  -- States.
  enemy:set_can_attack(enemy:is_visible())
  enemy:set_damage(4)
  start_step(current_step ~= 0 and current_step or 1)
end)