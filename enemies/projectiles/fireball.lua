-- 3 fireballs shot by enemies like Zora, Eyegore statue or Face lamp and that go toward the hero.
-- They can be hit with the sword, this changes their direction.

local enemy = ...
local sprites = {}

require("enemies/lib/common_actions").learn(enemy)
local audio_manager = require("scripts/audio_manager")

local function on_shield_collision()
  print("shield")
  enemy:remove()
end

-- Call the enemy:on_hit() callback if the enemy still can attack, and remove the entity if it doesn't return false.
local function hit_behavior()

  if enemy:get_can_attack() and (not enemy.on_hit or enemy:on_hit() ~= false) then
    enemy:remove()
  end
end

enemy:register_event("on_created", function(enemy)

  enemy:set_life(1)
  enemy:set_damage(4)
  enemy:set_size(8, 8)
  enemy:set_origin(4, 4)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_minimum_shield_needed(2)
  enemy:set_invincible()
  enemy:set_hero_weapons_reactions({
    shield = on_shield_collision,
    sword = "custom"
  })

  sprites[1] = enemy:create_sprite("enemies/" .. enemy:get_breed())
  -- Sprites 2 and 3 do not belong to the enemy to avoid testing collisions with them.
  sprites[2] = sol.sprite.create("enemies/" .. enemy:get_breed())
  sprites[3] = sol.sprite.create("enemies/" .. enemy:get_breed())
end)

local function go(angle)

  local movement = sol.movement.create("straight")
  movement:set_speed(128)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:set_ignore_obstacles(false)

  function movement:on_obstacle_reached()
    hit_behavior()
  end

  -- Compute the coordinate offset of follower sprites.
  local x = math.cos(angle) * 10
  local y = -math.sin(angle) * 10
  sprites[1]:set_xy(2 * x, 2 * y)
  sprites[2]:set_xy(x, y)

  sprites[1]:set_animation("walking")
  sprites[2]:set_animation("following_1")
  sprites[3]:set_animation("following_2")

  movement:start(enemy)
end

enemy:register_event("on_restarted", function(enemy)

  local hero = enemy:get_map():get_hero()
  local angle = enemy:get_angle(hero:get_center_position())
  go(angle)

end)

-- Check if the projectile should be destroyed when the hero is touched. 
enemy:register_event("on_attacking_hero", function(enemy, hero, enemy_sprite)

  if not hero:is_shield_protecting(enemy) and not hero:is_blinking() then
    hero:start_hurt(enemy, enemy_sprite, enemy:get_damage())
  else enemy:remove()
  end
  hit_behavior()
end)

-- Change the direction of the movement when hit with the sword.
enemy:register_event("on_custom_attack_received", function(enemy, attack, sprite)

  if attack == "sword" and sprite == sprites[1] then
    local hero = enemy:get_map():get_hero()
    local movement = enemy:get_movement()
    if movement == nil then
      return
    end

    local old_angle = movement:get_angle()
    local angle
    local hero_direction = hero:get_direction()
    if hero_direction == 0 or hero_direction == 2 then
      angle = math.pi - old_angle
    else
      angle = 2 * math.pi - old_angle
    end

    go(angle)
    audio_manager:play_sound("enemy_hurt")

    -- The trailing fireballs are now on the hero: don't attack temporarily
    enemy:set_can_attack(false)
    sol.timer.start(enemy, 500, function()
      enemy:set_can_attack(true)
    end)
  end
end)

enemy:register_event("on_pre_draw", function(enemy)

  local map = enemy:get_map()
  local x, y = enemy:get_position()
  map:draw_visual(sprites[2], x, y)
  map:draw_visual(sprites[3], x, y)
end)

