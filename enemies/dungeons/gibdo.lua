local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Gibdos: Hylian mummy.

local properties = {
  sprite = "enemies/dungeons/gibdo",
  life = 6,
  damage = 2,
  normal_speed = 24,
  faster_speed = 32,
  pushed_when_hurt = false
}
behavior:create(enemy, properties)

  enemy:set_hero_weapons_reactions({
  	arrow = "protected",
  	boomerang = "protected",
  	explosion = 2,
  	sword = 1,
  	thrown_item = "protected",
  	fire = "custom",
  	jump_on = "ignored",
  	hammer = "protected",
  	hookshot = "protected",
  	magic_powder = "custom",
  	shield = "protected",
  	thrust = "protected"
  })

function enemy:on_custom_attack_received(attack, sprite)
  if attack == "fire" then enemy:get_sprite():set_animation("fire") end
  enemy:hurt(6)
  enemy:remove_life(6)
end