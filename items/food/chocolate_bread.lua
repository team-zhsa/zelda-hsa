local item = ...

function item:on_created()
  self:set_savegame_variable("possession_chocolate_bread")
  self:set_amount_savegame_variable("amount_chocolate_bread")
  self:set_brandish_when_picked(false)
  self:set_sound_when_picked("common/get_small_item1")
  self:set_sound_when_brandished("common/chest_minor_item")
  self:set_assignable(true)
  self:set_max_amount(256)
end

function item:on_using()

  if self:get_amount() == 0 then
    sol.audio.play_sound("wrong")
  else
    self:remove_amount(1)
    self:get_game():add_life(6)
  end
  self:set_finished()
end

function item:on_obtaining(variant, savegame_variable)

  self:add_amount(1)
end