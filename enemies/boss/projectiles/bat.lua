----------------------------------
--
-- Grim Creeper's Bat.
--
-- Bat invoked by the Grim Creeper, invincible and harmless until charging.
--
-- Methods : enemy:start_positioning(target_x, target_y)
--           enemy:start_throwed(entity)
--
-- Events :  enemy:on_positioned()
--           enemy:on_off_screen()
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local map = enemy:get_map()
local camera = map:get_camera()
local sprite = enemy:create_sprite("enemies/boss/grim_creeper/minion")
local quarter = math.pi * 0.5

-- Configuration variables.
local fly_height = 32
local positioning_speed = 120
local charging_speed = 200
local hurt_duration = 500

-- Return the angle from the enemy sprite to given entity.
local function get_angle_from_sprite(sprite, entity)

  local x, y, _ = enemy:get_position()
  local sprite_x, sprite_y = sprite:get_xy()
  local entity_x, entity_y, _ = entity:get_position()

  return math.atan2(y - entity_y + sprite_y, entity_x - x - sprite_x)
end

-- Custom die to display the dying animation on the sprite position instead of the enemy position.
local function die()

  enemy:stop_all()
  sprite:set_animation("hurt")
  sol.timer.start(enemy, hurt_duration, function()
    enemy:start_death(function()
      local x_offset, y_offset = sprite:get_xy()
      enemy:remove_sprite(sprite)
      local dying_sprite = enemy:create_sprite(enemy:get_dying_sprite_id())
      dying_sprite:set_xy(x_offset, y_offset)

      function dying_sprite:on_animation_finished()
        finish_death()
      end
    end)
  end)
end

-- Make the enemy start positioning at the given position.
function enemy:start_positioning(target_x, target_y)

  sprite:set_animation("waiting")
  local movement = sol.movement.create("target")
  movement:set_ignore_obstacles(true)
  movement:set_speed(positioning_speed)
  movement:set_target(target_x, target_y)
  movement:start(enemy)

  function movement:on_finished()
    if enemy.on_positioned then
      enemy:on_positioned()
    end
  end
end

-- Make the enemy start being throwed.
function enemy:start_throwed(entity)

  local angle = get_angle_from_sprite(sprite, entity)
  local movement = enemy:start_straight_walking(angle, charging_speed)
  movement:set_ignore_obstacles(true)
  sprite:set_animation("attacking")

  enemy:set_hero_weapons_reactions({
  	arrow = die,
  	boomerang = die,
  	explosion = die,
  	sword = die,
  	thrown_item = die,
  	fire = die,
  	jump_on = "ignored",
  	hammer = die,
  	hookshot = die,
  	magic_powder = die,
  	shield = "protected",
  	thrust = die
  })
  enemy:set_can_attack(true)

  -- Remove the bat without killing him and call the on_off_screen() event when off screen.
  function movement:on_position_changed()
    if not camera:overlaps(enemy:get_max_bounding_box()) then
      enemy:remove()
      if enemy.on_off_screen then
        enemy:on_off_screen()
      end
    end
  end

  -- Progressively reduce the height.
  sol.timer.start(enemy, 50, function()
    local x, y = sprite:get_xy()
    sprite:set_xy(x, y + 1)
    return enemy:exists()
  end)
end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(1)
  enemy:set_size(24, 16)
  enemy:set_origin(12, 13)
  enemy:start_shadow()
  sprite:set_xy(0, -fly_height)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_invincible()

  enemy:set_can_attack(false)
  enemy:set_damage(2)
  enemy:set_obstacle_behavior("flying")
  enemy:set_layer_independent_collisions(true)
  enemy:set_pushed_back_when_hurt(false)
end)
