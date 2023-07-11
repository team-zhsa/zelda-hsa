-- A ground of pikes where the hero is hurt when walking on it.

local ground_spikes = ...

local allowed_states = {
  ["carrying"] = true,
  ["free"] = true,
  ["pulling"] = true,
  ["pushing"] = true,
  ["running"] = true,
  ["swimming"] = true,
  ["sword loading"] = true,
  ["sword spin attack"] = true,
  ["sword swinging"] = true,
  ["sword tapping"] = true,
}

function ground_spikes:on_created()

  ground_spikes:set_traversable_by(true)
  ground_spikes:set_drawn_in_y_order(false)
  ground_spikes:set_modified_ground("traversable")

end

ground_spikes:add_collision_test("center", function(ground_spikes, entity)

  if entity:get_type() ~= "hero" then
    return
  end

  local hero = entity

  if hero:is_invincible() then
    return
  end

  local current_state = hero:get_state()
  if not allowed_states[current_state] then
    return
  end

	entity:get_game():remove_life(3)
  hero:start_hurt(1)
end)