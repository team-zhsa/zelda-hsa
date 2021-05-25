----------------------------------
--
-- Add basic projectile methods and events to an enemy.
--
-- Methods : enemy:remove_when_out_screen(movement)
--           enemy:straight_go([angle, [speed]])
-- Events :  enemy:on_hit()
--
-- Usage : 
-- local my_enemy = ...
-- local behavior = require("enemies/lib/projectile")
-- local main_sprite = enemy:create_sprite("my_enemy_main_sprite")
-- behavior.apply(my_enemy, main_sprite)
--
----------------------------------

local behavior = {}

function behavior.apply(enemy, sprite)

  require("enemies/lib/common_actions").learn(enemy)
  local audio_manager = require("scripts/audio_manager")

  local game = enemy:get_game()
  local map = enemy:get_map()
  local hero = map:get_hero()

  local default_speed = 192

  -- Call the enemy:on_hit() callback and remove the entity if it doesn't return false.
  local function hit_behavior()

    if not enemy.on_hit or enemy:on_hit() ~= false then
      enemy:silent_kill()
    end
  end

  -- Start going to the given angle, or to the hero if nil.
  function enemy:straight_go(angle, speed)

    local movement = sol.movement.create("straight")
    movement:set_angle(angle or enemy:get_angle(hero))
    movement:set_speed(speed or default_speed)
    movement:set_smooth(false)
    movement:start(enemy)
    sprite:set_direction(movement:get_direction4())

    function movement:on_obstacle_reached()
      hit_behavior()
    end

    return movement
  end

  -- Remove any projectile if its main sprite is completely out of the screen.
  enemy:register_event("on_position_changed", function(enemy)

    if not enemy:is_watched(sprite) then
      enemy:stop_movement()
      enemy:silent_kill()
    end
  end)

  -- Hide any projectile on dying
  enemy:register_event("on_dying", function(enemy, shield)
    enemy:set_visible(false)
  end)

  -- Check if the projectile should be destroyed when the hero is touched. 
  enemy:register_event("on_attacking_hero", function(enemy, hero, enemy_sprite)

    -- TODO adapt and move in the shield script for all enemy.
    if not hero:is_shield_protecting(enemy, enemy_sprite) or not game:has_item("shield") or game:get_item("shield"):get_variant() < enemy:get_minimum_shield_needed() then
      hero:start_hurt(enemy, enemy_sprite, enemy:get_damage())
    end

    hit_behavior()
  end)

  -- TODO Depends on the projectile, move to specific scripts
  -- Destroy the enemy when touching the shield.
  enemy:register_event("on_shield_collision", function(enemy, shield)
    hit_behavior()
  end)
end

return behavior