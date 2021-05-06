----------------------------------
--
-- Arm Mimic.
--
-- Copy and reverse hero moves.
-- Sword only hurt him if the sword attack is a spin attack or sword better than level 1.
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local is_pushed_back = false

-- Only hurt the enemy if the sword attack is a spin attack or sword better than level 1, else push the enemy back.
local function on_sword_attack_received()

  local hero_animation = hero:get_sprite():get_animation()

  -- Stop the sword loading if any.
  if hero_animation == "sword_loading_stopped" or hero_animation == "sword_loading_walking" then
    -- TODO
  end

  local sword_variant = game:get_item("sword"):get_variant()
  if hero_animation == "spin_attack" or sword_variant > 1 then
    enemy:hurt(1)

  elseif not is_pushed_back then
    is_pushed_back = true
    enemy:start_pushed_back(hero, 250, 120, sprite, nil, function()
      is_pushed_back = false
    end)
  end
end

-- Reverse the hero movement if he is moving, not hurt and if the enemy not dying.
local function reverse_move()

  local movement = hero:get_movement()
  if movement and movement:get_speed() > 0 and hero:get_state() ~= "hurt" and enemy:get_life() > 0 then
    enemy:start_straight_walking(movement:get_angle() + math.pi, movement:get_speed())
    sprite:set_direction((movement:get_direction4() + 2) % 4) -- Always keep the hero opposite movement direction, not sprite direction.
  else
    enemy:stop_movement()
    sprite:set_animation("immobilized")
  end
end

-- Copy and reverse hero moves on movement changed.
hero:register_event("on_movement_changed", function(hero)

  if not enemy:exists() or not enemy:is_enabled() then
    return
  end

  reverse_move()
end)

-- Stop the enemy when the hero reaches an obstacle.
hero:register_event("on_obstacle_reached", function(hero)

  if not enemy:exists() or not enemy:is_enabled() then
    return
  end

  enemy:stop_movement()
  sprite:set_animation("immobilized")
end)

-- Workaround: Stop the enemy on hero states that doesn't trigger the hero:on_movement_changed() event.
hero:register_event("on_state_changing", function(hero, state_name, next_state_name)

  if not enemy:exists() or not enemy:is_enabled() then
    return
  end

  if next_state_name == "sword swinging" then
    enemy:stop_movement()
    sprite:set_animation("immobilized")
  end
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(1)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
    arrow = "protected",
    boomerang = "immobilized",
    explosion = "ignored",
    sword = on_sword_attack_received,
    thrown_item = "protected",
    fire = "protected",
    jump_on = "ignored",
    hammer = "protected",
    hookshot = "immobilized",
    magic_powder = "ignored",
    shield = "protected",
    thrust = 1
  })

  -- States.
  reverse_move() -- Reverse move on restarted in case the hero is already running when the map is loaded or separator crossed.
  enemy:set_can_attack(true)
  enemy:set_damage(12)
end)
