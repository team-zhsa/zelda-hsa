-- Heart container
local item = ...

function item:on_created()

  self:set_sound_when_picked(nil)
  self:set_brandish_when_picked(false)

end

function item:on_obtained(variant, savegame_variable)


  local map = self:get_map()
  local hero = map:get_entity("hero")
  local x_hero,y_hero, layer_hero = hero:get_position()
  hero:freeze()
  hero:set_animation("brandish")
  sol.audio.play_sound("common/get_heart_container")
  local heart_container_entity = map:create_custom_entity({
      name = "brandish_sword",
      sprite = "entities/items",
      x = x_hero,
      y = y_hero - 24,
      width = 16,
      height = 16,
      layer = layer_hero,
      direction = 0
    })
    heart_container_entity:get_sprite():set_animation("heart_container")
    heart_container_entity:get_sprite():set_direction(0)
    sol.timer.start(heart_container_entity, 2000, function()
        hero:set_animation("stopped")
        map:remove_entities("brandish")
        hero:unfreeze()
        local game = self:get_game()
        game:add_max_life(4)
        game:set_life(game:get_max_life())
      end)

end

