-- Beam projectile, mainly used by the Wizzrobe enemy.

local enemy = ...
local bounced = false

require("enemies/lib/common_actions").learn(enemy)
local audio_manager = require("scripts/audio_manager")

-- The enemy appears: set its properties.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(1)
  enemy:set_damage(12)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 8)
  enemy:set_obstacle_behavior("flying")
  enemy:set_invincible()
  enemy:set_attack_consequence("sword", "custom")
  enemy:create_sprite("enemies/" .. enemy:get_breed())
	enemy:set_minimum_shield_needed(2)

end)

enemy:register_event("on_obstacle_reached", function(enemy)
  enemy:start_death()
end)

function enemy:go(direction4)

  local angle = direction4 * math.pi / 2
  local movement = sol.movement.create("straight")
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(enemy)
  enemy:get_sprite():set_direction(direction4)
  
end

enemy:register_event("on_custom_attack_received", function(enemy, attack, sprite)

  if attack == "sword" and not bounced then
    local sprite = enemy:get_sprite()
    local hero = enemy:get_map():get_hero()
    local direction = hero:get_direction()
    sprite:set_direction(direction)
    local movement = enemy:get_movement()
    local angle = direction * math.pi / 2
    movement:set_angle(angle)
    --audio_manager:play_sound("enemy_hurt") Todo change sound
    bounced = true
  end
  
end)
