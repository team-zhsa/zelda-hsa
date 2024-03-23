local item = ...

function item:on_created()
  self:set_savegame_variable("possession_goron_amber")
  self:set_amount_savegame_variable("amount_goron_amber")
  self:set_max_amount(8)
  self:set_assignable(false)
  self:set_brandish_when_picked(true)
  self:set_sound_when_brandished("items/sidequest_major_item")
end

function item:on_obtaining(variant, savegame_variable)

  self:add_amount(1)

end

function item:on_obtained(variant, savegame_variable)
  if self:get_amount(8) then
    self:get_game():start_dialog("_treasure.divine_ore.all_ores_obtained")
  end
end