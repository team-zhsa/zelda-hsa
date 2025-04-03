local item = ...

function item:on_created()
  self:set_sound_when_picked("items/get_small_item_pick_"..math.random(0,1))
  self:set_sound_when_brandished("items/get_minor_item")
  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
  self:set_savegame_variable("possession_bomb")

end

function item:on_started()

  -- Disable pickable bombs if the player has no bomb counter.
  -- We cannot do this from on_created() because we don't know if the bomb counter
  -- is already created there.
  self:set_obtainable(self:get_game():has_item("bomb_counter"))

end

function item:on_obtaining(variant, savegame_variable)

  -- Obtaining bombs increases the bombs counter.
  local amounts = {1, 3, 8, 10}
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'bomb'")
  end
  self:get_game():get_item("bomb_counter"):add_amount(amount)

end

