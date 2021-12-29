----------------------------------
--
-- Shadow of Ganon's Bat.
--
-- Bat invoked by the shadow of Ganon, waiting for some time then charge the hero.
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local map = enemy:get_map()
local camera = map:get_camera()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local quarter = math.pi * 0.5

-- Configuration variables.
local charging_speed = 200
local waiting_duration = 500

-- Make the enemy start charging the hero.
local function start_charging()

  local movement = enemy:start_straight_walking(enemy:get_angle(hero), charging_speed)
  movement:set_ignore_obstacles(true)
  enemy:set_can_attack(true)

  -- Kill the bat when off screen.
  function movement:on_position_changed()
    if not camera:overlaps(enemy:get_max_bounding_box()) then
      enemy:start_death()
    end
  end
end

-- Make the bat appear.
local function start_appearing()

  enemy:start_brief_effect("entities/effects/flame")
  sprite:set_animation("walking")
  sol.timer.start(enemy, waiting_duration, function()
    start_charging()
  end)
end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(1)
  enemy:set_size(24, 16)
  enemy:set_origin(12, 13)
  enemy:start_shadow()
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_invincible()
  enemy:set_can_attack(false)
  enemy:set_damage(4)
  enemy:set_obstacle_behavior("flying")
  enemy:set_layer_independent_collisions(true)
  start_appearing()
end)
