----------------------------------
--
-- Like Like.
--
-- Moves randomly over horizontal and vertical axis.
-- Eat the hero and steal the equiped shield if any, then wait for eight
-- actions before freeing the hero.

-- Methods : enemy:is_eating_hero()
--
----------------------------------

-- Global variables.
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local hero_tunic_sprite = hero:get_sprite()
local hero_eaten_sprite
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local quarter = math.pi * 0.5
local is_eating = false
local is_exhausted = true
local command_pressed_count = 0

-- Configuration variables.
local walking_angles = {0, quarter, 2.0 * quarter, 3.0 * quarter}
local walking_speed = 32
local walking_minimum_distance = 16
local walking_maximum_distance = 96
local walking_pause_duration = 1500

-- Set opacity on the given sprite if existing.
local function set_sprite_opacity(sprite, opacity)

  if sprite then
    sprite:set_opacity(opacity)
  end
end

-- Return true if no like-like enemy is currenly eating the hero on the map.
local function is_hero_eatable()

  for likelike in map:get_entities_by_type("enemy") do
    if likelike:get_breed() == enemy:get_breed()
    and likelike:is_eating_hero() then
      return false
    end
  end
  return true
end

-- Steal an item and drop it when died, possibly conditionned on the variant
-- and the assignation to a slot.
local function steal_item(item_name, variant, only_if_assigned, drop_when_dead)

  if game:has_item(item_name) then
    local item = game:get_item(item_name)
    local is_stealable = not only_if_assigned or (game:get_item_assigned(1) == item and 1)
    or (game:get_item_assigned(2) == item and 2)

    if (not variant or item:get_variant() == variant) and is_stealable then
      if item:is_being_used() then
        if item == game:get_item("shield_hero") or item == game:get_item("shield_hylia")
        or item == game:get_item("shield_mirror") then
          -- Workaround: No event called when the item finished being used, use this method instead of item:set_finished() to properly finish using shield.
          item:stop_using()
        else
          item:set_finished()
        end
      end
      if drop_when_dead then
        enemy:set_treasure(item_name, item:get_variant()) -- TODO savegame variable
      end
      item:set_variant(0)
      if item_slot then
        game:set_item_assigned(item_slot, nil)
      end
    end
  end
end

-- Start the enemy movement.
local function start_walking()

  enemy:start_straight_walking(walking_angles[math.random(4)], walking_speed, math.random(walking_minimum_distance, walking_maximum_distance), function()
    start_walking()
  end)
end

-- Free the hero.
local function free_hero()

  if not is_eating then
    return
  end
  is_eating = false
  is_exhausted = true
  hero.is_eaten = false

  -- Remove hero eaten sprite
  hero:remove_sprite(hero_eaten_sprite)
  hero_eaten_sprite = nil

  -- Reset hero opacity.
  set_sprite_opacity(hero_tunic_sprite, 255)
  set_sprite_opacity(hero:get_sprite("shadow"), 255)
  set_sprite_opacity(hero:get_sprite("shadow_override"), 255)

  enemy:set_drawn_in_y_order()
  enemy:restart()
end

-- Make the enemy eat the hero.
local function eat_hero()

  if is_eating or is_exhausted or not is_hero_eatable() then
    return
  end
  is_eating = true
  hero.is_eaten = true -- Also set a flag on the hero to make some actions differently when eaten, such as the jump.

  command_pressed_count = 0
  enemy:stop_movement()
  enemy:set_invincible()
  enemy:set_drawn_in_y_order(false) -- Workaround : Ensure the enemy is displayed below the hero while eaten.
  enemy:bring_to_front()

  -- Create the hero eaten sprite.
  hero_eaten_sprite = hero:create_sprite(hero_tunic_sprite:get_animation_set(), "eaten")
  hero_eaten_sprite:set_animation("eaten")

  -- Make the hero eaten, but still able to interact.
  set_sprite_opacity(hero_tunic_sprite, 0)
  set_sprite_opacity(hero:get_sprite("shadow"), 0)
  set_sprite_opacity(hero:get_sprite("shadow_override"), 0)

  -- Eat the shield if it is the first variant and assigned to a slot.
  steal_item("shield_hero", 1, true, true)
  steal_item("shield_hylia", 1, true, true)
  steal_item("shield_mirror", 1, true, true)
end

-- Return true if the enemy is currently eating the hero.
function enemy:is_eating_hero()

  return is_eating
end

-- Store the number of command pressed while eaten, and free the hero once 8 item commands are pressed.
map:register_event("on_command_pressed", function(map, command)

  if not enemy:exists() or not enemy:is_enabled() then
    return
  end

  if is_eating and (command == "attack" or command == "item_1" or command == "item_2" or command == "action"
  or command == "left" or command == "right" or command == "up" or command == "down") then
    command_pressed_count = command_pressed_count + 1
    if command_pressed_count == 8 then
      free_hero()
    end
  end
end)

-- Eat the hero on attacking him.
enemy:register_event("on_attacking_hero", function(enemy, hero, enemy_sprite)

  if not hero:is_shield_protecting(enemy) and not hero:is_blinking() then
    eat_hero()
  end
  return true
end)

-- Free hero on dying.
enemy:register_event("on_dying", function(enemy)

  free_hero()
end)

-- Passive behaviors needing constant checking.
enemy:register_event("on_update", function(enemy)

  if not enemy:is_enabled() then
    return
  end

  -- Make sure the hero is stuck while eaten even if something move him or the enemy.
  if is_eating then
    hero:set_position(enemy:get_position())
    hero_eaten_sprite:set_direction(hero:get_direction())

    -- Workaround: No fucking way to make additional hero sprites blink when hurt, make the eaten sprite blink here if needed.
    if hero:is_blinking() and not hero_eaten_sprite.is_blinking then
      hero_eaten_sprite.is_blinking = true
      local blinking_timer = sol.timer.start(hero, 50, function()
        if not hero_eaten_sprite then
          return
        end
        hero_eaten_sprite:set_opacity(math.abs(hero_eaten_sprite:get_opacity() - 255))
        return true
      end)
      sol.timer.start(hero, 2000, function()
        if not hero_eaten_sprite then
          return
        end
        hero_eaten_sprite.is_blinking = false
        hero_eaten_sprite:set_opacity(255)
        blinking_timer:stop()
      end)
    end
  end
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(2)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  -- Schedule the damage rules setup once not in collision with the hero, in case he was just released and still overlaps.
  sol.timer.start(enemy, 10, function()
    if enemy:overlaps(hero, "sprite") then
      return true
    end
    is_exhausted = false
    enemy:set_damage(1)
    enemy:set_can_attack(true)

    enemy:set_hero_weapons_reactions({
    	arrow = 2,
    	boomerang = 2,
    	explosion = 2,
    	sword = 1,
    	thrown_item = 2,
    	fire = 2,
      ice = "ignored",
    	jump_on = "ignored",
    	hammer = 2,
    	hookshot = 2,
    	magic_powder = 2,
    	shield = "protected",
    	thrust = 2
    })
  end)

  -- States.
  enemy:set_invincible()
  enemy:set_damage(0)
  enemy:set_can_attack(false)
  command_pressed_count = 0
  start_walking()
end)
