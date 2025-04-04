local item = ...
local magic_needed = 5
item.somaria_block = nil  -- The block created if any.

function item:on_created()
	item:set_sound_when_brandished("items/get_major_item")
  item:set_savegame_variable("possession_somaria_cane")
  item:set_assignable(true)
end

function item:on_using()
  local game = item:get_game()
  local map = game:get_map()
  local hero = map:get_hero()
  local direction = hero:get_direction()
  hero:set_animation("rod")

  -- Give the hero the animation of using the wind rod.
  local x, y, layer = hero:get_position()
  local somaria_cane = map:create_custom_entity({
    x = x,
    y = y,
    layer = layer,
    width = 16,
    height = 16,
    direction = direction,
    sprite = "hero/item/rods/somaria_cane",
  })

  -- Shoot wind if there is enough magic.
  if game:get_magic() >= magic_needed then
    sol.audio.play_sound("items/cane")
    sol.audio.play_sound("menus/magic_bar")
    game:remove_magic(magic_needed)

    local x, y, layer = self:get_block_position_from_hero()
    if self.somaria_block == nil or not self.somaria_block:exists() then
      -- Create the Somaria block.
      self.somaria_block = map:create_block{
        name = "somaria_block",
        x = x,
        y = y,
        layer = layer,
        sprite = "entities/somaria_block",
        pushable = true,
        pullable = true,
        maximum_moves = 2  -- Infinite moves.
      }
      self.created = true
    else
      -- Reuse the old one.
      local old_x, old_y, old_layer = self.somaria_block:get_position()
      if x ~= old_x or y ~= old_y or layer ~= old_layer then
        self.somaria_block:set_position(x, y, layer)
      end
    end
  else
    if self.somaria_block ~= nil and self.somaria_block:get_position() ~= -100 then
      -- Remove the previous block.
      sol.audio.play_sound("items/cane")
      self.somaria_block:set_position(-100, 0)
    else
      sol.audio.play_sound("common/wrong")
    end
  end

  -- Make sure that the wind rod stays on the hero.
  -- Even if he is using this item, he can move
  -- because of holes or wind.
  sol.timer.start(somaria_cane, 10, function()
    somaria_cane:set_position(hero:get_position())
    return true
  end)

  -- Remove the wind rod and restore control after a delay.
  sol.timer.start(hero, 300, function()
    somaria_cane:remove()
    item:set_finished()
  end)
end

-- Called when the current map changes.
function item:on_map_changed()
  -- No more Somaria block on the new map.
  self.somaria_block = nil
end

function item:get_block_position_from_hero()
  -- Compute a position
  local hero = self:get_map():get_entity("hero")
  local x, y, layer = hero:get_position()
  local direction = hero:get_direction()
  if direction == 0 then
    x = x + 21
  elseif direction == 1 then
    y = y - 21
  elseif direction == 2 then
    x = x - 21
  elseif direction == 3 then
    y = y + 21
  end
  -- Snap the center of the block to the 8*8 grid.
  x = (x + 4) - (x + 4) % 8
  y = (y - 1) - (y - 1) % 8 + 5
  return x, y, layer
end

function item:on_obtained(variant, savegame_variable)
  -- Give the magic bar if necessary.
  local magic_bar = self:get_game():get_item("magic_bar")
  if not magic_bar:has_variant() then
    magic_bar:set_variant(1)
  end
end