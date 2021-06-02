local enemy = ...

-- Red Hardhat Beetle.

local behavior = require("enemies/lib/towards_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 8,
  damage = 6,
  normal_speed = 16,
  faster_speed = 16,
  hurt_style = "monster",
  push_hero_on_sword = true,
	detection_distance = 64,
  movement_create = function()
    local m = sol.movement.create("random")
    m:set_smooth(true)
    return m
  end
}

function enemy:on_created()
	enemy:set_attack_consequence("explosion", "immobilized")
	enemy:set_attack_consequence("boomerang", "ignored")
	enemy:set_attack_consequence("hookshot", "ignored")
end

behavior:create(enemy, properties)
