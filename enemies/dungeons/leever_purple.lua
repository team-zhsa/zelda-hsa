----------------------------------
--
-- Leever.
--
-- Start invisible and appear after a random time at a random position, then go to the hero direction.
-- The apparition point may be restricted to an area if the corresponding custom property is filled with a valid area, else the point will always be a visible one.
-- Disappear after some time.
--
-- Properties : area
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)
require("scripts/multi_events")

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local camera = map:get_camera()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local quarter = math.pi * 0.5
local eighth = math.pi * 0.25
local is_underground = true

-- Configuration variables
local area = enemy:get_property("area")
local walking_speed = 32
local walking_minimum_duration = 3000
local walking_maximum_duration = 5000
local waiting_minimum_duration = 2000
local waiting_maximum_duration = 3000

-- Return the layer of the given position.
local function get_ground_layer(x, y)

  for ground_layer = map:get_max_layer(), map:get_min_layer(), -1 do
    if map:get_ground(x, y, ground_layer) ~= "empty" then
      return ground_layer
    end
  end
end

-- Make the enemy disappear.
local function disappear()

  sprite:set_animation("sinking_start", function()
    sprite:set_animation("sinking_end", function()
      is_underground = true
      enemy:restart()
    end)
  end)
end

-- Start the enemy movement.
local function start_walking()

  local movement = enemy:start_target_walking(hero, walking_speed)
  sol.timer.start(enemy, math.random(walking_minimum_duration, walking_maximum_duration), function()
    movement:stop()
    disappear()
  end)
end

-- Make the enemy appear at a random position.
local function appear()

  -- Postpone to the next frame if the random position would be over an obstacle.
  local x, y = enemy:get_position()
  local random_x, random_y = enemy:get_random_position_in_area(area or camera)
  local layer = get_ground_layer(random_x, random_y)
  enemy:set_layer(layer or enemy:get_layer())
  if not layer or enemy:test_obstacles(random_x - x, random_y - y) then
    sol.timer.start(enemy, 10, function()
      appear()
    end)
    return
  end

  enemy:set_position(random_x, random_y)
  enemy:set_visible()
  sprite:set_animation("emerging", function()

    is_underground = false
    enemy:set_hero_weapons_reactions({
    	arrow = 2,
    	boomerang = 2,
    	explosion = 2,
    	sword = 1,
    	thrown_item = 2,
    	fire = 2,
    	jump_on = "ignored",
    	hammer = 2,
    	hookshot = 2,
    	magic_powder = 2,
    	shield = "protected",
    	thrust = 2
    })
    enemy:set_can_attack(true)

    start_walking()
  end)
end

-- Wait a few time and appear.
local function wait()

  sol.timer.start(enemy, math.random(waiting_minimum_duration, waiting_maximum_duration), function()
    if not camera:overlaps(enemy:get_max_bounding_box()) then
      return true
    end
    appear()
  end)
end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(5)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  -- States.
  enemy:set_damage(4)
  if is_underground then
    enemy:set_invincible()
    enemy:set_can_attack(false)
    enemy:set_visible(false)
    wait()
  else
    start_walking()
  end
end)

