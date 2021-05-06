local enemy = ...

-- Cannonball or random sprite
-- made for the ALTTP room in Temple of Stupidities 1F NE

local random_balls = {
  {
    sprite = "enemies/dungeons/cannonball",
    sound = "cannonball",
    width = 16,
    height = 16,
    origin_x = 8,
    origin_y = 13,
  },
  {
    sprite = "enemies/dungeons/cannonball_big",
    sound = "cannonball",
    width = 32,
    height = 32,
    origin_x = 16,
    origin_y = 29,
  },
}

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_invincible()
  enemy:set_can_hurt_hero_running(true)

  local index
    -- Choose between the 2 real cannonballs.
    index = math.random(2)
  local props = random_balls[index]

  enemy:create_sprite(props.sprite)
  enemy:set_size(props.width, props.height)
  enemy:set_origin(props.origin_x, props.origin_y)
  local x, y = enemy:get_position()
  sol.audio.play_sound(props.sound)
end

function enemy:on_restarted()

  local movement = sol.movement.create("straight")

  function movement:on_obstacle_reached()
    enemy:remove()
  end

  local direction4 = enemy:get_sprite():get_direction()
  local angle = direction4 * math.pi / 2
  movement:set_speed(72)
  movement:set_angle(angle)

  -- Distance for a standard room.
  local max_distance = direction4 % 2 == 0 and 272 or 192
  movement:set_max_distance(max_distance)

  movement:start(self, function()
    enemy:remove()
  end)

  -- debug TODO
  movement:set_ignore_obstacles(true)
end

