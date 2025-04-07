local enemy = ...

local behavior = require("enemies/lib/towards_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 1,
  damage = 12,
  normal_speed = 64,
  faster_speed = 64,
}

behavior:create(enemy, properties)

-- Invincible but steps back when touched.
-- Should be pushed into a hole.
enemy:set_invincible(true)

enemy:set_attack_consequence("arrow", "custom")
enemy:set_attack_consequence("boomerang", "custom")
enemy:set_attack_consequence("sword", "custom")
enemy:set_attack_consequence("thrown_item", "custom")
enemy:set_fire_reaction("custom")
enemy:set_hammer_reaction("custom")
enemy:set_hookshot_reaction("custom")

function enemy:on_custom_attack_received(attack)

  -- Custom reaction: don't get hurt but step back.
  sol.timer.stop_all(enemy)  -- Stop the towards_hero behavior.
  local hero = enemy:get_map():get_hero()
  local angle = hero:get_angle(enemy)
  local movement = sol.movement.create("straight")
  movement:set_speed(128)
  movement:set_ignore_obstacles(properties.ignore_obstacles)
  movement:set_angle(angle)
  movement:start(enemy)
  sol.timer.start(enemy, 400, function()
    enemy:restart()
  end)
end
