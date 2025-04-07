local enemy = ...
local chain = nil

-- Knight with a chain and ball.

function enemy:on_created()
  self:set_life(20); self:set_damage(6)
  self:create_sprite("enemies/knight_green")
  self:set_size(48, 48); self:set_origin(24, 29)
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)
  self:set_invincible()
  self:set_attack_arrow(1)
  self:set_attack_hookshot(1)
  self:set_attack_consequence("sword", 2)
  self:set_attack_consequence("thrown_item", 1)
end

function enemy:on_enabled()
  if chain == nil then
    -- Create the chain and ball.
    local chain_name = self:get_name() .. "_chain"
    chain = self:create_enemy{
      name = chain_name,
      breed = "chain_and_ball",
      x = -8,
      y = -16,
    }
    chain:set_center_enemy(self)
    chain:set_enabled(true)
  end
end

function enemy:on_restarted()
  -- Set the movement.
  local m = sol.movement.create("random_path")
  m:set_speed(40)
  m:start(self)

  if chain ~= nil then
    chain:set_enabled(true)
  end
end

function enemy:on_hurt(attack)
  if self:get_life() <= 0 then
    -- dying: remove the chain and ball.
    chain:remove()
  else
    -- hurt: disable the chain and ball for a while.
    chain:set_enabled(false)
  end
end