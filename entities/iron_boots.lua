-- Tunic
local item = ...
local hero = item:get_hero()

function item:on_created()

  self:set_savegame_variable("possession_iron_boots")
	self:set_assignable(true)

end

function item:on_obtained(variant, savegame_variable)

  -- Give the built-in ability "tunic", but only after the treasure sequence is done.
  self:get_game():set_ability("tunic", 1)

end

function item:on_using()
	self:get_game():set_ability("tunic", 1)
	self:get_game():set_value("tunic_equipped", 1)
	self:get_map():get_hero():unfreeze()
end

hero_meta:register_event("on_position_changed", function(hero)
    local map = hero:get_map()
    local x, y, z = hero:get_center_position()
    if z + 1 > map:get_max_layer() then oz = z else oz = z + 1 end
    local over_hero_ground = map:get_ground(x, y, oz)
    if over_hero_ground == "deep_water" then
      hero:set_walking_speed(40)
    else return end
end)