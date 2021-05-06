local item = ...

function item:on_created()

  self:set_shadow("small")
  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
  self:set_sound_when_picked("common/get_small_item0")
end

function item:on_obtaining(variant, savegame_variable)

  local amounts = {1, 5, 20, 50, 100, 200, 500, 1000, 2000}
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'rupee'")
  end
  self:get_game():add_money(amount)
end

