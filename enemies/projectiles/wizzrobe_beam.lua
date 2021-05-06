local enemy = ...
local type

-- A magic beam thrown by another enemy (Wizzrobe).

function enemy:on_created(properties)
  self:set_life(1); self:set_damage(6)
  self:create_sprite("enemies/dungeons/wizzrobe_beam")
  self:set_size(16, 16); self:set_origin(8, 8)
  self:set_invincible()
  self:set_minimum_shield_needed(2)
  self:set_can_hurt_hero_running(true)
  self:set_obstacle_behavior("flying")
  if self:get_name() ~= nil then
    if self:get_name() == "fire" or self:get_name():match("^fire_(%d+)") then type = "fire" end
    if self:get_name() == "ice" or self:get_name():match("^ice_(%d+)") then type = "ice" end
    if self:get_name() == "elec" or self:get_name():match("^ice_(%d+)") then type = "elec" end
  end
end

function enemy:on_obstacle_reached()
  self:remove()
end

function enemy:on_restarted()
  if type == "fire" then
    self:get_sprite():set_animation("fire")
  elseif type == "ice" then
    self:get_sprite():set_animation("ice")
  elseif type == "elec" then
    self:get_sprite():set_animation("electric")
  else
    self:get_sprite():set_animation("magic")
  end
  local dir4 = self:get_sprite():get_direction()
  local m = sol.movement.create("straight")
  if dir4 == 0 then angle = 0 end
  if dir4 == 1 then angle = math.pi / 2 end
  if dir4 == 2 then angle = math.pi end
  if dir4 == 3 then angle = 3 * math.pi / 2 end
  m:set_smooth(false)
  m:set_speed(92)
  m:set_angle(angle)
  m:start(self)
end

function enemy:on_attacking_hero(hero)
  if type == "ice" and self:get_game():get_item("shield"):get_variant() < 3 then
    hero:start_frozen(2000)
    hero:set_invincible(true, 3000)
  elseif type == "elec" and self:get_game():get_item("shield"):get_variant() < 3 then
    hero:start_electrocution(2000)
    hero:set_invincible(true, 3000)
  end
end