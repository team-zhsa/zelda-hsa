local item = ...


function item:on_created()

  self:set_savegame_variable("possession_sword")
  self:set_sound_when_picked(nil)
  item:set_sound_when_brandished("common/big_item")
end

function item:on_variant_changed(variant)
  -- The possession state of the sword determines the built-in ability "sword".
  self:get_game():set_ability("sword", variant)
end

item:register_event("on_using", function()
	item:shoot()
end)

function item:shoot()
	print("Beam")
	local map = item:get_map()
  local hero = map:get_hero()
  local direction = hero:get_direction()
  local x, y, layer = hero:get_center_position()
	  local beam = map:create_custom_entity({
    model = "sword_beam",
    x = x,
    y = y + 3,
    layer = layer,
    width = 8,
    height = 8,
    direction = direction,
  })
	sol.audio.play_sound("boss_fireball")
	hero:unfreeze()
  local angle = direction * math.pi / 2
  local movement = sol.movement.create("straight")
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(beam)
end

