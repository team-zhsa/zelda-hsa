-- Lua script of enemy wizzrobe.
-- This script is executed every time an enemy with this model is created.

-- Variables
local enemy = ...
local map = enemy:get_map()
local children = {}
local is_appear = false
local previous_on_removed = enemy.on_removed

-- Include scripts
local audio_manager = require("scripts/audio_manager")

-- The enemy appears: set its properties.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(3)
  enemy:set_damage(0)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  
end)

-- Wizzrobe appear
function enemy:appear()

  local sprite = enemy:get_sprite()
  enemy:set_visible(true)
  sprite:fade_in(20, function()
      enemy:set_damage(5)
      is_appear = true
      enemy:update_attack()
      enemy:shoot()
  end)

end

-- Wizzrobe disappear
function enemy:disappear()

  local sprite = enemy:get_sprite()
  sprite:fade_out(20, function()
      enemy:set_damage(0)
      is_appear = false
      enemy:update_attack()
      local hero = enemy:get_map():get_hero()
      local direction = enemy:get_direction4_to(hero)
      local sprite = enemy:get_sprite()
      sprite:set_direction(direction)
      sol.timer.start(enemy, 2000, function()
        enemy:appear()
      end)  
  end)

end

function enemy:shoot()

  local sprite = enemy:get_sprite()
  sprite:set_animation("walking")
  local hero = map:get_hero()
  if enemy:get_distance(hero) > 200 or not enemy:is_in_same_region(hero) then
    return true 
  end

  local sprite = enemy:get_sprite()
  local x, y, layer = enemy:get_position()
  local direction = sprite:get_direction()

  -- Where to start the beam from.
  local dxy = {
    {  0, -5 },
    {  0, -5 },
    {  0, -5 },
    {  0, -5 },
  }

  local beam = enemy:create_enemy({
    name = (enemy:get_name() or enemy:get_breed()) .. "_beam",
    breed = "projectiles/beam",
    x = dxy[direction + 1][1],
    y = dxy[direction + 1][2],
  })
  children[#children + 1] = beam

  if not map.wizzrobe_recent_sound then
    audio_manager:play_entity_sound(enemy, "enemies/wizzrobe")
    -- Avoid loudy simultaneous sounds if there are several wizzrobes.
    map.wizzrobe_recent_sound = true
    sol.timer.start(map, 200, function()
      map.wizzrobe_recent_sound = nil
    end)
  end
  beam:go(direction)
  sol.timer.start(enemy, 2000, function()
    enemy:disappear()
  end)
end

function enemy:update_attack()

  if is_appear then
      enemy:set_attack_consequence("sword", 1)
  else
      enemy:set_invincible()
  end
  enemy:set_can_attack(is_appear)
end

-- The enemy was stopped for some reason and should restart.
enemy:register_event("on_restarted", function(enemy)

  if is_appear == false then
    enemy:set_can_attack(false)
    local sprite = enemy:get_sprite()
    enemy:set_visible(false)
    sol.timer.start(enemy, 2000, function()
      enemy:appear()
    end)  
  end

end)

enemy:register_event("on_removed", function(enemy)

  if previous_on_removed then
    previous_on_removed(enemy)
  end

  for _, child in ipairs(children) do
    child:start_death()
  end
end)

enemy:register_event("on_custom_attack_received", function(enemy, attack)

  -- Custom reaction: don't get hurt but step back.
  sol.timer.stop_all(enemy)  -- Stop the towards_hero behavior.
  local hero = enemy:get_map():get_hero()
  local angle = hero:get_angle(enemy)
  local movement = sol.movement.create("straight")
  movement:set_speed(128)
  movement:set_ignore_obstacles(true)
  movement:set_angle(angle)
  movement:start(enemy)
  sol.timer.start(enemy, 400, function()
    enemy:restart()
  end)

end)
