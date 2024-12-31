local item = ...

function item:on_created()
  self:set_savegame_variable("possession_monster_tail")
  self:set_amount_savegame_variable("amount_monster_tail")
  self:set_max_amount(20)
  self:set_assignable(false)
  self:set_shadow("small")
  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
  self:set_sound_when_picked("items/get_small_item_pick_"..math.random(0,1))
  self:set_sound_when_brandished("items/get_sidequest_minor_item")
end

function item:on_obtaining(variant, savegame_variable)

  self:add_amount(1)

end