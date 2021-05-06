-- Lua script of enemy bomb, mainly used by the bomber and monkey enemies.

-- Global variables
local enemy = ...
local projectile_behavior = require("enemies/lib/projectile")

local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local circle = 2.0 * math.pi

-- Configuration variables
local before_blinking_minimum_delay = 1500
local before_blinking_maximum_delay = 2000
local before_explosing_delay = 1000

-- Make the bomb explode and hurt only the hero.
function enemy:explode()

  local x, y, layer = enemy:get_position()
  local explosion = map:create_custom_entity({
    model = "explosion",
    direction = 0,
    x = x,
    y = y,
    layer = layer,
    width = 16,
    height = 16,
    properties = {
      {key = "damage_on_hero", value = "4"},
      {key = "explosive_type_1", value = "crystal"},
      {key = "explosive_type_2", value = "destructible"},
      {key = "explosive_type_3", value = "door"},
      {key = "explosive_type_4", value = "hero"},
      {key = "explosive_type_5", value = "sensor"}
    }
  })
  enemy:start_death()
end

-- Don't remove on hit.
enemy:register_event("on_hit", function(enemy)
  return false
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  projectile_behavior.apply(enemy, sprite)
  enemy:set_life(1)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:start_shadow()
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  sprite:set_animation("walking")
  enemy:set_damage(4)
  enemy:set_obstacle_behavior("flying")
  enemy:set_layer_independent_collisions(true)
  enemy:set_invincible()

  -- Make the bomb explode after some time
  sol.timer.start(enemy, math.random(before_blinking_minimum_delay, before_blinking_maximum_delay), function()
    sprite:set_animation("explosion_soon")
    sol.timer.start(enemy, before_explosing_delay, function()
      enemy:explode()
    end)
  end)
end)
