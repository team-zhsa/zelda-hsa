-- Heart
local item = ...

function item:on_created()

  self:set_shadow("small")
  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
  self:set_sound_when_picked("items/get_small_item_pick_"..math.random(0,1))
  self:set_sound_when_brandished("items/get_minor_item")
end

function item:on_obtaining(variant, savegame_variable)

  self:get_game():add_life(12)
end