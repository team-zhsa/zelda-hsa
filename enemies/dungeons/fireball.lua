-- Lua script of fireball.
-- This script is executed every time an enemy with this model is created.

-- Variables
local enemy = ...
local last_direction4 = 0
local clockwise = false

-- The enemy appears: set its properties.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_can_hurt_hero_running(true)
  enemy:set_invincible()
  enemy:set_obstacle_behavior("swimming")
  clockwise = (enemy:get_property("clockwise") == "true")

end)

-- The enemy was stopped for some reason and should restart.
enemy:register_event("on_restarted", function(enemy)

  local sprite = enemy:get_sprite()
  local direction4 = sprite:get_direction()
  enemy:go(direction4)

end)

enemy:register_event("on_obstacle_reached", function(enemy)

  if clockwise then
    enemy:go((last_direction4 - 1) % 4)
  else
    enemy:go((last_direction4 + 1) % 4)
  end
            
end)

enemy:register_event("on_position_changed", function(enemy)
  
  if clockwise then
    enemy:go_if_traversable((last_direction4 + 1) % 4)
  else
    enemy:go_if_traversable((last_direction4 - 1) % 4)
  end

end)

function enemy:go_if_traversable(direction4)

  local dxy = {
    { x =  1, y =  0},
    { x =  0, y = -1},
    { x = -1, y =  0},
    { x =  0, y =  1}
  }
  if not enemy:test_obstacles(dxy[direction4 + 1].x, dxy[direction4 + 1].y) then
    enemy:go(direction4)
  end

end

-- Makes the Fireball go towards a horizontal or vertical direction.
function enemy:go(direction4)

  local m = sol.movement.create("straight")
  m:set_speed(80)
  m:set_smooth(false)
  m:set_angle(direction4 * math.pi / 2)
  m:start(enemy)
  last_direction4 = direction4

end