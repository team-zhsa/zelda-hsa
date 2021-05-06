----------------------------------
--
-- Genie's Bottle.
--
-- Bottle used by the genie to hide.
-- Invincible until set_stunnable() is called to make it vulnerable to sword attack, then can be carried and throwed while stunned.
--
-- Methods : enemy:set_stunnable(stunnable)
--
-- Events : enemy:on_stunned()
--          enemy:on_stun_finished()
--          enemy:on_finish_throw()
--          enemy:on_breaking()
--
----------------------------------

-- Global variables.
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/boss/genie/bottle")
local bottle_entity, bottle_entity_sprite
local is_stunned = false
local is_hurtable = true

-- Configuration variables.
local hurt_bounce_duration = 500
local hurt_bounce_height = 16
local hurt_bounce_speed = 64
local stunned_duration = 5000
local shaking_duration = 1000

local function switch_to_carriable()

  bottle_entity:set_position(enemy:get_position())
  bottle_entity:set_enabled(true)
  enemy:set_visible(false)
  enemy:set_invincible()
  enemy:set_can_attack(false)
end

local function switch_to_enemy()

  is_hurtable = true
  enemy:set_position(bottle_entity:get_position())
  enemy:set_can_attack(true)
  enemy:set_hero_weapons_reactions({
  	sword = "protected",
  	shield = "protected"
  })
  enemy:set_visible(true)
  bottle_entity:set_enabled(false)
end

-- Workaround : Create a ball custom entity to be able to lift the enemy when stunned.
local function create_liftable_entity()

  local x, y, layer = enemy:get_position()
  bottle_entity = map:create_custom_entity({
    direction = 0,
    x = x,
    y = y,
    layer = layer,
    width = 16,
    height = 16,
    model = "ball",
    sprite = "enemies/boss/genie/bottle"
  })
  bottle_entity:set_traversable_by("enemy", true)
  bottle_entity:set_can_traverse("enemy", true)
  bottle_entity:set_weight(1)
  bottle_entity:set_enabled(false)

  bottle_entity_sprite = bottle_entity:get_sprite()
  bottle_entity_sprite:set_animation("stopped")

  -- Propagate on_finish_throw() event.
  bottle_entity:register_event("on_finish_throw", function(bottle_entity)
    switch_to_enemy()
    if enemy.on_finish_throw then
      enemy:on_finish_throw()
    end
  end)

  -- Break on hit if no more life point.
  bottle_entity:register_event("on_hit", function(bottle_entity, entity)
    if not is_hurtable then -- Ensure to only hit once a throw.
      return
    end
    is_hurtable = false

    if enemy:get_life() == 1 then
      enemy:set_position(bottle_entity:get_position())
      if enemy.on_breaking then
        enemy:on_breaking()
      end
      bottle_entity:stop_movement()
      sol.timer.stop_all(bottle_entity)
      bottle_entity_sprite:set_animation("destroyed", function()
        bottle_entity:remove()
        enemy:start_death()
      end)
    else
      bottle_entity_sprite:set_animation("hurt")
      enemy:set_life(enemy:get_life() - 1)
    end
  end)
end

-- Make the bottle stunned and carriable.
local function start_stunned()

  switch_to_carriable()
  bottle_entity_sprite:set_animation("stopped")
  if enemy.on_stunned then
    enemy:on_stunned()
  end

  -- Finish the stun normally when timer ended.
  local stunned_timer = sol.timer.start(bottle_entity, stunned_duration, function()
    switch_to_enemy()
    if enemy.on_stun_finished then
      enemy:on_stun_finished()
    end
  end)

  -- Start shaking when close to the end of stun duration.
  local immobile_timer = sol.timer.start(bottle_entity, stunned_duration - shaking_duration, function()
    bottle_entity_sprite:set_animation("shaking")
  end)

  -- Stop timers on lifted.
  bottle_entity:register_event("on_interaction", function(bottle_entity)
    bottle_entity_sprite:set_animation("stopped")
    stunned_timer:stop()
    immobile_timer:stop()
  end)
end

-- Make the bottle stunned on sword attack.
function enemy:set_stunnable(stunnable)

  if stunnable then
    enemy:set_hero_weapons_reactions({
    	sword = function()
        
        -- Make the bottle jump away on hurt by sword, then stunned on ground touched.
        enemy:set_stunnable(false)
        enemy:stop_movement()
        local angle = hero:get_angle(enemy)
        enemy:start_jumping(hurt_bounce_duration, hurt_bounce_height, angle, hurt_bounce_speed, function()
          start_stunned()
        end)
      end
    })
  else
    enemy:set_hero_weapons_reactions({sword = "protected"})
  end
end

-- Enable the bottle entity on enabled.
enemy:register_event("on_enabled", function(enemy)

  if is_stunned then
    bottle_entity:set_enabled()
  end
end)

-- Disable the bottle entity on disabled.
enemy:register_event("on_disabled", function(enemy)

  if is_stunned then
    bottle_entity:set_enabled(false)
  end
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(2)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:start_shadow()
  create_liftable_entity()
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_invincible()
  enemy:set_hero_weapons_reactions({
  	sword = "protected",
  	shield = "protected"
  })

  -- States.
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_can_attack(true)
  enemy:set_damage(4)
  sprite:set_animation("stopped")
end)