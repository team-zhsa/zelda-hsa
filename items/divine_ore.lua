local item = ...

function item:on_created()

  self:set_shadow("small")
  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
  self:set_sound_when_brandished("common/sidequest_major_item")
end

function item:on_obtaining(variant, savegame_variable)
  if self:get_game():get_item("divine_ore_counter"):get_variant() == 0 then
    self:get_game():get_item("divine_ore_counter"):set_variant(1)
  end
  self:get_game():get_item("divine_ore_counter"):add_amount(1)

end

function item:on_obtained(variant, savegame_variable)
  if self:get_game():get_item("divine_ore_counter"):get_amount(8) then
    self:get_game():start_dialog("_treasure.divine_ore.all_ores_obtained")
  end
end