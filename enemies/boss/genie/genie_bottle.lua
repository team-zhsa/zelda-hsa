-- Lua script of enemy boss_2_vase.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
local genie
local bottle_entity
local is_freeze

-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_damage(0)
  enemy:set_invincible(true)
  
end


-- The enemy was stopped for some reason and should restart.
function enemy:on_restarted()
  
  sprite:set_animation("stopped")
  if is_freeze then
    enemy:freeze()
  end
    
  
end

function enemy:set_genie(enemy)
  
  genie = enemy
  
end

function enemy:go_initial_place()
  
  sprite:set_animation("walking")
  local movement = sol.movement.create("target")
  movement:set_target(map:get_entity("placeholder_bottle"))
  movement:set_speed(32)
  movement:start(enemy, function()
    sol.timer.start(enemy, 4000, function()
      genie:appear()
    end)
  end)
  
end

function enemy:fight()
  
  local movement = sol.movement.create("target")
  movement:set_target(hero)
  movement:set_speed(32)
  movement:start(enemy)
  enemy:set_attack_consequence("sword", function()
    if not is_freeze then
      movement:stop()
      enemy:freeze()
    end  
  end)
  
end

function enemy:freeze()
  
  is_freeze = true  
  sprite:set_animation("stopped")
  enemy:set_damage(0)
  enemy:set_attack_consequence("sword", 0)
    sol.timer.start(enemy, 1000, function()
      game:start_dialog("maps.dungeons.2.boss_message_2", function()
        enemy:set_enabled(false)
        local x_enemy, y_enemy, layer_enemy = enemy:get_position()
        bottle_entity = map:create_custom_entity({
          name = "bottle_entity",
          sprite = "entities/destructibles/genie_bottle",
          model = "bottle",
          x = x_enemy,
          y = y_enemy ,
          width = 16,
          height = 16,
          layer = layer_enemy,
          direction = 0
        })
        function bottle_entity:on_hit(entity)
          if entity and entity:get_name() == nil and is_freeze then
            is_freeze = false
            local x_enemy_entity, y_enemy_entity, layer_enemy_entity = bottle_entity:get_position()
            enemy:set_position(x_enemy_entity, y_enemy_entity)
            bottle_entity:set_enabled(false)
            enemy:set_enabled(true)
            enemy:go_initial_place()
          end
        end
      end)
  end)
end
