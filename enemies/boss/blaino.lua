----------------------------------
--
-- Blaino.
--
-- Boxer enemy that move in front of the hero with little jumps.
-- May use jab, straight and uppercut punches. The first one only hurts, the second one hurts and stuns and the third one hurts and ejects the hero.
-- Protected against sword attacks when done on the front.
-- 
-- Events : enemy:on_hero_ejected()
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local camera = map:get_camera()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local is_hero_on_left = true
local is_jumping_forward = true
local is_straight_punching = false
local is_uppercut_punching = false
local is_hero_hurt_by_straight = false
local is_hero_hurt_by_uppercut = false
local is_hero_pushed_back = false
local is_hurt = false
local quarter = math.pi * 0.5
local eighth = math.pi * 0.25

-- Configuration variables
local minimum_distance_x_to_hero = 24
local maximum_distance_x_to_hero = 52
local minimum_jumping_distance_x = 4
local jumping_speed = 120
local jumping_height = 6
local jumping_duration = 200
local straight_arming_duration = 1000
local straight_speed = 248
local straight_maximum_distance = 96
local straight_duration = 1000
local uppercut_arming_duration = 2000
local uppercut_arming_speed = 88
local uppercut_arming_distance = 24
local uppercut_speed = 248
local uppercut_maximum_distance = 48
local uppercut_duration = 1000
local minimum_jump_in_a_row = 4
local maximum_jump_in_a_row = 12
local minimum_jab_in_a_row = 1
local maximum_jab_in_a_row = 8
local jab_probability = 0.5
local straight_probability = 0.3
local hero_frozen_duration_on_straight_received = 3000
local ejecting_speed = 248
local front_angle = 2.0 * math.pi / 3.0

-- Start a straight movement.
local function start_straight_movement(entity, speed, distance, angle)

  local movement = sol.movement.create("straight")
  movement:set_speed(speed)
  movement:set_max_distance(distance)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(entity)

  return movement
end

-- Hurt the enemy if hero is not on his front. 
local function on_attack_received(damage)

  -- Don't hurt if a previous hurt animation is still running.
  if is_hurt then
    return
  end

  -- Repulse the hero instead of hurting the enemy if the hero is in front of him.
  if enemy:is_entity_in_front(hero, front_angle) then
    if not is_hero_pushed_back then
      is_hero_pushed_back = true
      enemy:start_pushing_back(hero, 200, 100, sprite, nil, function()
        is_hero_pushed_back = false
      end)
    end
    return
  end
  is_hurt = true

  -- Custom die if no more life.
  if enemy:get_life() - damage < 1 then

    -- Wait a few time, start 2 sets of explosions close from the enemy, wait a few time again and finally make the final explosion and enemy die.
    enemy:stop_all()
    enemy:start_death(function()
      sprite:set_animation("hurt")
      sol.timer.start(enemy, 1500, function()
        enemy:start_close_explosions(32, 2500, "entities/explosion_boss", 0, -10, function()
          sol.timer.start(enemy, 1000, function()
            enemy:start_brief_effect("entities/explosion_boss", nil, 0, -10)
            finish_death()
          end)
        end)
        sol.timer.start(enemy, 200, function()
          enemy:start_close_explosions(32, 2300, "entities/explosion_boss", 0, -10)
        end)
      end)
    end)
    return
  end

  -- Hurt normally else.
  enemy:hurt(damage)
end

-- Move back then start an uppercut punch and eject the hero if touched.
local function start_uppercut()

  sprite:set_animation("arming_uppercut")
  start_straight_movement(enemy, uppercut_arming_speed, uppercut_arming_distance, is_hero_on_left and 0 or math.pi)
  sol.timer.start(enemy, uppercut_arming_duration, function()

    is_uppercut_punching = true
    start_straight_movement(enemy, uppercut_speed, uppercut_maximum_distance, is_hero_on_left and math.pi or 0)
    sprite:set_animation("uppercut")

    -- Stop the uppercut after some time.
    sol.timer.start(enemy, uppercut_duration, function()
      is_uppercut_punching = false
      if not is_hero_hurt_by_uppercut then
        enemy:restart()
      end
    end)
  end)
end

-- Start a straight punch that stun the hero if hit, and directly start an uppercut in this case.
local function start_straight()

  sprite:set_animation("arming_straight")
  sol.timer.start(enemy, straight_arming_duration, function()

    is_straight_punching = true
    start_straight_movement(enemy, straight_speed, straight_maximum_distance, is_hero_on_left and math.pi or 0)
    sprite:set_animation("straight")

    -- Stop the punch after some time.
    sol.timer.start(enemy, straight_duration, function()
      is_straight_punching = false
      if is_hero_hurt_by_straight then
        start_uppercut()
      else
        enemy:restart()
      end
    end)
  end)
end

-- Start a serie of jab punch.
local function start_jab(jab_countdown)

  sprite:set_animation("jab", function()
    if jab_countdown > 1 then
      start_jab(jab_countdown - 1)
      return
    end
    enemy:restart()
  end)
end

-- Start the enemy jumping movement to the front of the hero, with a slight back and forth on the jump.
local function start_jumping(jump_countdown)

  local x = enemy:get_position()
  local hero_x, hero_y, _ = hero:get_position()
  local current_x_offset = math.abs(x - hero_x)
  local minimum_move_x = is_jumping_forward and current_x_offset + minimum_jumping_distance_x or minimum_distance_x_to_hero
  local maximum_move_x = is_jumping_forward and maximum_distance_x_to_hero or current_x_offset - minimum_jumping_distance_x
  local move_x = math.random(minimum_move_x, maximum_move_x)

  is_hero_on_left = hero_x < x
  local target_x, target_y = hero_x + (is_hero_on_left and move_x or -move_x), hero_y
  local angle = enemy:get_angle(target_x, target_y)
  local speed = jumping_speed * math.min(1.0, enemy:get_distance(target_x, target_y) / (jumping_speed * 0.2))
  local duration = jumping_duration
  local movement = enemy:start_jumping(duration, jumping_height, angle, speed, function()

    -- Start the next jump if no action should occurs at the end of the jump, else start an attack randomly.
    if jump_countdown > 1 then
      start_jumping(jump_countdown - 1)
      return
    end
    local action_random_number = math.random()
    if action_random_number <= jab_probability then
      start_jab(math.random(minimum_jab_in_a_row, maximum_jab_in_a_row))
    elseif action_random_number <= jab_probability + straight_probability then
      start_straight()
    else
      start_uppercut()
    end
  end)
  movement:set_smooth(true)

  sprite:set_animation("jumping")
  sprite:set_direction(is_hero_on_left and 2 or 0)
  is_jumping_forward = not is_jumping_forward
end

-- Hurt the hero, and do the additional behavior if hurt during straight punch or uppercut.
enemy:register_event("on_attacking_hero", function(enemy, hero, enemy_sprite)

  if hero:is_blinking() then
    return
  end

  hero:start_hurt(enemy, enemy:get_damage())

  -- Push the hero back and start an uppercut on hurt by a straight punch.
  if is_straight_punching then
    is_hero_hurt_by_straight = true
    enemy:get_movement():stop()
    hero:freeze()
    hero:set_animation("collapse")

    enemy:start_pushing_back(hero, 250, 150)
    sol.timer.start(hero, hero_frozen_duration_on_straight_received, function()
      hero:unfreeze()
    end)
  end

  -- Eject the hero on hurt by the uppercut.
  if is_uppercut_punching then
    is_hero_hurt_by_uppercut = true
    enemy:get_movement():stop()
    hero:freeze()
    hero:set_animation("collapse")

    local ejecting_movement = start_straight_movement(hero, ejecting_speed, 0, is_hero_on_left and 3.0 * eighth or eighth)
    ejecting_movement:set_ignore_obstacles()
    ejecting_movement:start(hero)

    local function ejected()
      ejecting_movement:stop()
      hero:unfreeze()
      if enemy.on_hero_ejected then
        enemy:on_hero_ejected()
      end
    end

    function ejecting_movement:on_position_changed(x, y, layer)
      hero:set_layer(map:get_max_layer()) -- Workaround: Avoid the hero falling on ground layer each time the position change.

      -- Call the enemy:on_hero_ejected() once hero is out of the room or map before a possible separator is triggered. 
      if not hero:overlaps(camera:get_bounding_box()) then
        ejected()
        return
      end
      for separator in map:get_entities_by_type("separator") do
        if separator:overlaps(hero) then
          ejected()
          return
        end
      end
    end
  end
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(1)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:start_shadow()
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = "protected",
  	boomerang = "protected",
  	explosion = "ignored",
  	sword = function() on_attack_received(1) end,
  	thrown_item = "protected",
  	fire = "protected",
  	jump_on = "ignored",
  	hammer = "protected",
  	hookshot = "protected",
  	magic_powder = "ignored",
  	shield = "protected",
  	thrust = function() on_attack_received(1) end
  })

  -- States.
  is_jumping_forward = true
  is_straight_punching = false
  is_uppercut_punching = false
  is_hero_hurt_by_straight = false
  is_hero_hurt_by_uppercut = false
  is_hurt = false
  enemy:set_can_attack(true)
  enemy:set_damage(4)
  start_jumping(math.random(minimum_jump_in_a_row, maximum_jump_in_a_row))
end)
