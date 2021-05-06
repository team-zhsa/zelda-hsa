----------------------------------
--
-- Add some basic weapon abilities to an enemy.
-- There is no passive behavior without an explicit method call when learning this to an enemy.
--
-- Methods : enemy:hold_weapon([sprite_name, [reference_sprite, [x_offset, [y_offset]]]])
--           enemy:throw_projectile(projectile_name, [throwing_duration, [x_offset, [y_offset, [on_throwed_callback]]]])
--
-- Usage : 
-- local my_enemy = ...
-- local weapons = require("enemies/lib/weapons")
-- weapons.learn(my_enemy)
--
----------------------------------

local weapons = {}

function weapons.learn(enemy)

  require("enemies/lib/common_actions").learn(enemy)

  local game = enemy:get_game()
  local map = enemy:get_map()
  local hero = map:get_hero()
  local quarter = math.pi * 0.5

  -- Make the enemy hold a basic weapon that hurt the hero on touched and push back on hit by sword.
  function enemy:hold_weapon(sprite_name, reference_sprite, x_offset, y_offset)

    local enemy_x, enemy_y, enemy_layer = enemy:get_position()
    reference_sprite = reference_sprite or enemy:get_sprite()

    -- Create the welded custom entity.
    local weapon = map:create_custom_entity({
      name = (enemy:get_name() or enemy:get_breed()) .. "_weapon",
      direction = enemy:get_sprite():get_direction(),
      x = enemy_x,
      y = enemy_y,
      layer = enemy_layer,
      width = 16,
      height = 16,
      sprite = sprite_name or "enemies/" .. enemy:get_breed() .. "/sword"
    })
    enemy:start_welding(weapon, x_offset, y_offset)
    
    -- Synchronize sprites animation and direction.
    local weapon_sprite = weapon:get_sprite()
    weapon_sprite:synchronize(reference_sprite)
    reference_sprite:register_event("on_direction_changed", function(reference_sprite)
      weapon_sprite:set_direction(reference_sprite:get_direction())
    end)
    reference_sprite:register_event("on_animation_changed", function(reference_sprite, name)
      if weapon_sprite:has_animation(name) then
        weapon_sprite:set_animation(name)
      end
    end)

    -- Hurt hero on collision with any sprite but the hero sword, else slightly move the hero back.
    local is_pushed_back = false
    weapon:add_collision_test("sprite", function(weapon, entity, weapon_sprite, entity_sprite)
      if entity == hero  and not enemy:is_immobilized() then
        if entity_sprite ~= hero:get_sprite("sword") then
          if not hero:is_blinking() and not hero:is_invincible() then
            hero:start_hurt(enemy, enemy:get_damage())
          end
        else
          if not is_pushed_back then
            is_pushed_back = true
            enemy:set_invincible()
            enemy:start_shock(hero, 100, 150, function()
              enemy:restart()
            end)
          end
        end
      end
    end)
    enemy:register_event("on_restarted", function(enemy)
      is_pushed_back = false
    end)

    return weapon
  end

  -- Throw a projectile when throwing animation finished or duration reached.
  function enemy:throw_projectile(projectile_name, throwing_duration, x_offset, y_offset, on_throwed_callback)

    local sprite = enemy:get_sprite()

    local is_throwed = false
    local function throw()
      if not is_throwed then
        is_throwed = true
        local direction = sprite:get_direction()
        local x, y, layer = enemy:get_position()
        local projectile = map:create_enemy({
          breed = projectile_name,
          x = x + x_offset,
          y = y + y_offset,
          layer = layer,
          direction = direction
        })

        local projectile_sprite = projectile:get_sprite()
        projectile_sprite:set_direction(direction)
        if on_throwed_callback then
          on_throwed_callback()
        end
      end
    end
    for _, sprite in enemy:get_sprites() do
      if sprite:has_animation("throwing") then
        sprite:set_animation("throwing")
      end
    end

    if throwing_duration then
      sol.timer.start(enemy, throwing_duration, function()
        throw()
      end)
    end
  end
end

return weapons