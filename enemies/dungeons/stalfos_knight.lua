----------------------------------
--
-- Stalfos Knight.
--
-- Moves randomly over horizontal and vertical axis, and is invulnerable to front attacks.
-- Can be defeated by attacking him in the back, or take off his mask with the hookshot to set him weak from everywhere.
--
-- Methods : enemy:set_weak()
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)
require("enemies/lib/weapons").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local quarter = math.pi * 0.5
local is_weak = false

-- Configuration variables

-- Hurt if the hero is in the back of the enemy.
local function on_sword_attack_received()
 -- Make sure to only trigger this event once by attack.

  if is_weak then
    enemy:hurt(1)
  else
		enemy:set_weak()
  end
end

-- Hurt if enemy and hero have same direction, else grab the mask and make enemy weak.
local function on_explosion_attack_received()


  if is_weak then
    enemy:hurt(2)
	end
end

-- Make the enemy faster and maskless.
function enemy:set_weak()

  is_weak = true

  sprite:set_animation("hurt")
  enemy:restart()

end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(5)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)
  enemy:set_hero_weapons_reactions({
  	arrow = 1,
  	boomerang = "immobilized",
  	explosion = on_explosion_attack_received,
  	sword = on_sword_attack_received,
  	thrown_item = 1,
  	fire = 1,
  	jump_on = "ignored",
  	hammer = 1,
  	hookshot = "ignored",
  	magic_powder = 1,
  	shield = "protected",
  	thrust = "ignored"
  })

  -- States.
  enemy:set_can_attack(true)
  enemy:set_damage(2)
end)
