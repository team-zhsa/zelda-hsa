local item = ...
local game = item:get_game()

local magic_needed = 10
local new_life = 12

function item:on_created()
  item:set_savegame_variable("possession_healing_wand")
  item:set_assignable(true)
end

function item:on_variant_changed(new_variant)
  new_life = new_variant * 12 + 12
	magic_needed = new_variant * magic_needed
end

function item:on_using()
  local map = item:get_map()
  local hero = map:get_hero()
  local direction = hero:get_direction()
  hero:set_animation("reverse_rod")
  -- Give the hero the animation of using the fire rod.
  local x, y, layer = hero:get_position()
  local healing_wand = map:create_custom_entity({
    x = x,
    y = y,
    layer = layer,
    width = 16,
    height = 16,
    direction = direction,
    sprite = "hero/item/rods/healing_wand",
  })

  -- Heal the hero if there is enough magic.
  if game:get_magic() >= magic_needed then
    game:remove_magic(magic_needed)
		game:add_life(new_life)
  end

  -- Make sure that the fire rod stays on the hero.
  -- Even if he is using this item, he can move
  -- because of holes or ice.
  sol.timer.start(healing_wand, 10, function()
    healing_wand:set_position(hero:get_position())
    return true
  end)

  -- Remove the fire rod and restore control after a delay.
  sol.timer.start(hero, 200, function()
    healing_wand:remove()
    item:set_finished()
  end)
end

