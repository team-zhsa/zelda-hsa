local enemy = ...
local behavior = require("enemies/generic/bubble")

-- Bubble: an invincible enemy that moves in diagonal directions
-- and bounces against walls - this one shocks the hero.

local properties = {
  sprite = "enemies/dungeons/bubble_yellow",
}
behavior:create(enemy, properties)

function enemy:on_attacking_hero(hero)
  if not hero:is_invincible() then
    hero:set_invincible(true, 200)
		hero:freeze()
		hero:set_animation("electrocuted")
		sol.timer.start(1000, function()
			hero:unfreeze()
		end)
    if self:get_game():get_magic() > 0 then
      self:get_game():remove_magic(2)
      sol.audio.play_sound("common/magic_bar/6")
    end
  end
end