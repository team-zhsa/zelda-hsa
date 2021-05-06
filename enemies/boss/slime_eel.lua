----------------------------------
--
-- Slime Eel.
--
-- Description
--
-- Methods : enemy:start_appearing()
--           enemy:start_fighting()
--           enemy:create_aperture(x, y, direction, broken_entity)
--
----------------------------------

-- Global variables.
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local quarter = math.pi * 0.5
local tail
local apertures = {}
local is_catchable = false
local is_catched = false

-- Configuration variables.
local arise_speed = 180
local arise_distance = 32
local go_back_speed = 30
local biting_duration = 500
local hidden_minimum_duration = 1000
local hidden_maximum_duration = 2000
local peeking_duration = 1000
local front_angle = math.pi * 0.25

-- Make the enemy vertically pulled by the hookshot, and pull the tail by the same length.
local function start_pulled(length, speed, direction)

  local movement = enemy:start_straight_walking(direction * quarter, speed, length, function()

  end)
  movement:set_ignore_obstacles()
  tail:start_pulled(length, speed)
end

-- Make the enemy actually catched or just bounce depending on the hookshot position and direction.
local function on_catched()

  enemy:set_hero_weapons_reactions({hookshot = "ignored"})

  -- Hook the enemy head if it is in front of the hero.
  local hookshot = game:get_item("hookshot")
  hookshot:catch_entity(nil) -- Make the hookshot go back.
  if is_catchable and enemy:is_entity_in_front(hero, front_angle) then
    
    local _, y = enemy:get_position()
    local _, hero_y = hero:get_position()
    local _, height = enemy:get_size()
    local direction = sprite:get_direction()
    local length = math.abs(hero_y - y) - (direction == 3 and height or height * 0.5)
    local speed = 256 -- TODO Get hooshot speed dynamically
    sol.timer.stop_all(enemy)
    enemy:stop_movement()
    start_pulled(length, speed, direction)
  end
end

-- Extends the visible function with vulnerability settings.
local function start_visible()

  enemy:set_hero_weapons_reactions({
    arrow = "protected",
    boomerang = "protected",
    explosion = "ignored",
    sword = "protected",
    thrown_item = "protected",
    fire = "protected",
    jump_on = "ignored",
    hammer = "protected",
    hookshot = on_catched,
    magic_powder = "ignored",
    shield = "protected",
    thrust = "protected"
  })
  enemy:set_visible()
end

-- Make the enemy invisible, invincible and harmless.
local function start_hidding()

  enemy:set_invincible()
  enemy:set_visible(false)
end

-- Make the enemy arise from an aperture.
local function start_arising(x, y, direction, on_finished_callback)

  enemy:set_position(x, y)
  local movement = enemy:start_straight_walking(direction * quarter, arise_speed, arise_distance, function()
    sol.timer.start(enemy, biting_duration, function()
      is_catchable = false
      local movement = enemy:start_straight_walking((direction + 2) % 4 * quarter, go_back_speed, arise_distance, function()
        if on_finished_callback then
          on_finished_callback()
        end
      end)
      movement:set_ignore_obstacles()
      sprite:set_direction(direction)
      sprite:set_animation("walking")
    end)
  end)
  movement:set_ignore_obstacles()
  sprite:set_animation("biting")
end

-- Make the enemy appear.
enemy:register_event("start_appearing", function(enemy)

  tail:start_appearing()
end)

-- Make the enemy start the fighting step.
enemy:register_event("start_fighting", function(enemy)

  sol.timer.start(enemy, math.random(hidden_minimum_duration, hidden_maximum_duration), function()

    -- Make the enemy immobile and peek out from the aperture for some time.
    local x, y, direction = unpack(apertures[math.random(1, 4)])
    enemy:set_position(x, y + (direction == 1 and -10 or 10))
    sprite:set_animation("peeking")
    sprite:set_direction(direction)
    start_visible()

    -- Then arise from the hole after some time to bite.
    sol.timer.start(enemy, peeking_duration, function()
      is_catchable = true
      start_arising(x, y, direction, function()
        start_hidding()
        enemy:start_fighting()
      end)
    end)
  end)
end)

-- Make the enemy create an apperture on the map from where the enemy can show up later while hidden on walls.
enemy:register_event("create_aperture", function(enemy, x, y, direction, broken_entity)

  table.insert(apertures, {x, y, direction})

  -- Make the enemy arise from the aperture, and possibly break the entity if given.
  start_visible()
  start_arising(x, y, direction, function()
    start_hidding()
  end)
  enemy:start_brief_effect("entities/effects/sparkle_small", "default", 0, direction == 1 and -32 or 32)
  broken_entity:remove()
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(8)
  enemy:set_size(32, 32)
  enemy:set_origin(16, 29)
  enemy:set_visible(false)

  tail = enemy:create_enemy({
    name = (enemy:get_name() or enemy:get_breed()) .. "_tail",
    breed = "boss/projectiles/eel_flail",
    direction = 2
  })
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  is_catched = false
  start_hidding()
  enemy:set_damage(4)
  enemy:set_can_attack(false)
  enemy:set_obstacle_behavior("flying") -- Don't fall in holes.
end)
