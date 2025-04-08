-- Shadowball projectile, mainly used by the Aghanim enemy.

local enemy = ...
local common_action = require("enemies/lib/common_actions")
common_action.learn(enemy)

-- Global variables
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local camera = map:get_camera()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local circle = math.pi * 2.0
local quarter = math.pi * 0.5
local eighth = math.pi * 0.25
local is_returnable

-- Configuration variables.
local speed = 160

-- Create an impact and its trail that will go on the given angle.
local function create_impact(angle)

  local impact = enemy:create_enemy({
    name = (enemy:get_name() or enemy:get_breed()) .. "_impact",
    breed = "empty", -- Workaround: Breed is mandatory but a non-existing one seems to be ok to create an empty enemy though.
    direction = 0,
  })
  common_action.learn(impact)
  impact:set_damage(enemy:get_damage())
  impact:set_invincible()
  impact:set_layer_independent_collisions(true)
  impact:set_obstacle_behavior("flying")
  impact:set_layer(map:get_max_layer())

  local direction = math.floor(angle / quarter) % 4
  for i = 1, 3, 1 do
    local sprite = impact:create_sprite("enemies/" .. enemy:get_breed())
    sprite:set_animation("impact_" .. i)
    sprite:set_direction(direction)
    sprite:set_xy(math.cos(angle) * 8 * (3 - i), -math.sin(angle) * 8 * (3 - i))
  end

  local movement = sol.movement.create("straight")
  movement:set_speed(speed)
  movement:set_angle(angle)
  movement:set_ignore_obstacles()
  movement:start(impact)

  -- Remove the impact if off screen.
  function movement:on_position_changed()
    if not camera:overlaps(impact:get_max_bounding_box()) then
      impact:start_death()
    end
  end
end

-- Determine the shadowball type then start going to the hero.
local function start_throwing()

  local movement = enemy:start_straight_walking(enemy:get_angle(hero), speed, nil, function()

    -- Impact effect on hit an obstacle.
    if is_returnable then
      enemy:start_brief_effect("entities/effects/impact_projectile", "default", sprite:get_xy())
    else
      -- Create 4 impacts that can hurt the hero.
      for i = 0, 4, 1 do
        create_impact(eighth + quarter * i)
      end
    end
    enemy:start_death()
  end)
  movement:set_smooth(false)

  -- Make the shadowball returnable by the hero sword if needed.
  if is_returnable then
    enemy:set_hero_weapons_reactions({
    	sword = function()
        local angle = movement:get_angle()
        local normal_angle = hero:get_direction() * quarter
        if math.cos(math.abs(normal_angle - angle)) <= 0 then -- Don't bounce if the enemy is walking away the hero.
          movement:set_angle((2.0 * normal_angle - angle + math.pi) % circle)
        end
        if enemy.on_returned then
          enemy:on_returned()
        end
      end
    })
  end
  sprite:set_animation(is_returnable and "returnable" or "hurtless")

  if enemy.on_throwed then
    enemy:on_throwed()
  end
end

-- Start loading the shadowball.
local function start_loading()

  is_returnable = math.random(2) == 1
  sprite:set_animation(is_returnable and "returnable_loading" or "hurtless_loading", function()
    start_throwing()
  end)
end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(1)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 8)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_damage(4)
  enemy:set_invincible()
  enemy:set_layer_independent_collisions(true)
  enemy:set_obstacle_behavior("flying")
  enemy:set_pushed_back_when_hurt(false)
  start_loading()
end)
