--Sea urchin
local enemy = ...

function enemy:on_created()

  self:set_traversable(false)
  self:set_life(1)
  self:set_damage(1)
  self:set_hurt_style("normal")
  local sprite = enemy:create_sprite("enemies/outside/sea_urchin")

end

function sprite:on_animation_finished(animation)

  if animation == "bite" then
    self:set_animation("walking")
  end

end