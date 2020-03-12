local item = ...

function item:on_created()

  self:set_shadow("small")
  self:set_brandish_when_picked(false)
  self:set_sound_when_picked("common/get_small_item1")
  self:set_sound_when_brandished("common/get_small_item1")
end

function item:on_obtaining(variant, savegame_variable)

  self:get_game():add_small_key()
end

