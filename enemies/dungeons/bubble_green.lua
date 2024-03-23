local enemy = ...
local behavior = require("enemies/generic/bubble")

-- Bubble: an invincible enemy that moves in diagonal directions
-- and bounces against walls- this one poisons the hero.

local properties = {
  sprite = "enemies/dungeons/bubble_green",
}
behavior:create(enemy, properties)

function enemy:on_attacking_hero(hero)
  if not hero:is_invincible() then
    hero:set_invincible(true, 200)
		hero:start_hurt(enemy, 4)
    if self:get_game():get_magic() > 0 then
      self:get_game():remove_magic(5)
      sol.audio.play_sound("menus/magic_bar")
    end
  end
end