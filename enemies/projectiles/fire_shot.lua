local enemy = ...

-- A fireball thrown by another enemy (Lynel, Lizalfos).

local function on_shield_collision()
  enemy:remove()
end

enemy:register_event("on_created", function(enemy)
  enemy:set_life(1)
	enemy:set_damage(2)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_size(16, 16); enemy:set_origin(8, 8)
  enemy:set_invincible()
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_hero_weapons_reactions({
    shield = on_shield_collision,
  })
end)

function enemy:on_obstacle_reached()
  enemy:remove()
end

function enemy:go(direction4)
  local angle = direction4 * math.pi / 2
  local movement = sol.movement.create("straight")
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(enemy)
  enemy:get_sprite():set_direction(direction4)
end