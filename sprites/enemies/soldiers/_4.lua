local item = ...

function item:on_created()

  self:set_can_disappear(true)

end

function item:on_started()

end

function item:on_obtaining(variant, savegame_variable)

  self:get_game():get_item("golden_leaves_counter"):add_amount(1)

end

