local enemy = ...

-- Bari: a flying enemy that follows the hero and tries to electrocute him.

local shocking = false

-- Electrocute the hero.
local function electrocute()
	hero:start_electrocution(4)
end

local function hurt_by_sword()
  function enemy:on_hurt_by_sword(hero, enemy_sprite)
    if shocking == true then
      electrocute()
    else
      self:hurt(1)
      enemy:remove_life(1)
    end
  end
end

function enemy:on_created()
  self:set_life(3)
  self:create_sprite("enemies/dungeons/bari_blue")
  self:set_size(16, 16); self:set_origin(8, 13)
end

function enemy:shock()
  shocking = true
  enemy:get_sprite():set_animation("shaking")
  sol.timer.start(enemy, math.random(10)*1000, function()
    enemy:get_sprite():set_animation("walking")
    shocking = false
    sol.timer.start(enemy, math.random(10)*1000, function() enemy:restart() end)
  end)
end

-- The enemy appears: set its properties.
enemy:register_event("on_created", function(enemy)
  enemy:set_life(3)
end)

-- The enemy appears: set its properties.
enemy:register_event("on_restarted", function(enemy)

  shocking = false
  local m = sol.movement.create("random")
  m:set_speed(12)
  m:start(enemy)
  if math.random(10) < 5 then
    enemy:shock()
  end

  enemy:set_hero_weapons_reactions({
  	arrow = 3,
  	boomerang = "ignored",
  	explosion = 3,
  	sword = hurt_by_sword(),
  	thrown_item = 3,
  	fire = 3,
  	jump_on = "ignored",
  	hammer = "protected",
  	hookshot = 3,
  	shield = "protected",
  	thrust = hurt_by_sword()
  })

  -- States.
  enemy:set_damage(2)

end)

function enemy:on_attacking_hero(hero, enemy_sprite)
  if shocking == true then
    electrocute()
  else
    hero:start_hurt(2)
  end
end