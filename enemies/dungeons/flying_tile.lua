-- Lua script of enemy flying tile.
-- This script is executed every time an enemy with this model is created.

-- Variables
local enemy = ...
local shadow_sprite = nil
local initial_y = nil
local state = nil  -- "raising", "attacking" or "destroying".

-- Include scripts
local audio_manager = require("scripts/audio_manager")

-- The enemy appears: set its properties.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(1)
  enemy:set_damage(2)
  enemy:set_enabled(false)
  enemy:set_obstacle_behavior("flying")
  enemy.state = state

  local sprite = enemy:create_sprite("enemies/dungeons/evil_tile1")
  function sprite:on_animation_finished(animation)
    if enemy.state == "destroying" then
      enemy:remove()
    end
  end

  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:set_invincible()
  enemy:set_attack_consequence("sword", "custom")
  shadow_sprite = sol.sprite.create("entities/shadows/shadow")
  shadow_sprite:set_animation("big")
  
end)

-- The enemy was stopped for some reason and should restart.
enemy:register_event("on_restarted", function(enemy)

  local x, y = enemy:get_position()
  initial_y = y

  local m = sol.movement.create("path")
  m:set_path{2,2}
  m:set_speed(16)
  m:start(enemy)
  sol.timer.start(enemy, 2000, function() enemy:go_hero() end)
  enemy.state = "raising"
  
end)

function enemy:go_hero()

  local angle = enemy:get_angle(enemy:get_map():get_entity("hero"))
  local m = sol.movement.create("straight")
  m:set_speed(192)
  m:set_angle(angle)
  m:set_smooth(false)
  m:start(enemy)
  enemy.state = "attacking"
  
end

enemy:register_event("on_obstacle_reached", function(enemy)
  
  enemy:disappear()
  
end)

enemy:register_event("on_custom_attack_received", function(enemy, attack, sprite)

  if enemy.state == "attacking" then
    enemy:disappear()
  end
  
end)

function enemy:disappear()

  if enemy.state ~= "destroying" then
    enemy.state = "destroying"
    local sprite = enemy:get_sprite()
    enemy:set_attack_consequence("sword", "ignored")
    enemy:set_can_attack(false)
    enemy:stop_movement()
    sprite:set_animation("destroy")
    audio_manager:play_entity_sound(enemy, "stone")
    sol.timer.stop_all(enemy)
    if enemy.on_flying_tile_dead ~= nil then
      enemy:on_flying_tile_dead()
    end
  end
  
end

enemy:register_event("on_pre_draw", function(enemy)

  -- Show the shadow.
  if enemy.state ~= "destroying" then
    local x, y = enemy:get_position()
    if enemy.state == "attacking" then
      y = y + 16
    else
      y = initial_y or y
    end
    enemy:get_map():draw_visual(shadow_sprite, x, y)
  end
  
end)

