-- An icon that shows the inventory item assigned to a slot.

local hud_icon_builder = require("scripts/hud/hud_icon")

local item_icon_builder = {}

function item_icon_builder:new(game, config)

  local item_icon = {}
  item_icon.slot = config.slot or 1

  -- Creates the hud icon delegate.
  item_icon.hud_icon = hud_icon_builder:new(config.x, config.y, config.dialog_x, config.dialog_y, config.pause_x, config.pause_y)
  item_icon.hud_icon:set_background_sprite(sol.sprite.create("hud/item_icon_"..item_icon.slot))
  
  -- Initializes the icon.
  item_icon.item_sprite = sol.sprite.create("entities/items")
  item_icon.item_sprite_w, item_icon.item_sprite_h = item_icon.item_sprite:get_size()
  item_icon.item_displayed = nil
  item_icon.item_variant_displayed = 0
  item_icon.amount_text = sol.text_surface.create{
    horizontal_alignment = "right",
    vertical_alignment = "top"
  }
  item_icon.amount_displayed = nil
  item_icon.max_amount_displayed = nil

  -- The surface used by the icon for the foreground is handled here.
  item_icon.foreground = sol.surface.create(32, 24)
  item_icon.hud_icon:set_foreground(item_icon.foreground)

  -- Draws the icon surface.
  function item_icon:on_draw(dst_surface)
    item_icon.hud_icon:on_draw(dst_surface)
  end

  -- Rebuild the foreground (called only when needed).
  function item_icon:rebuild_foreground()  
  
    -- Clear the surface in all cases to handle the loose of an item.
    item_icon.foreground:clear()  

    if item_icon.item_displayed ~= nil then
      -- Item.
      local foreground_w, foreground_h = item_icon.foreground:get_size()
      item_icon.item_sprite:draw(item_icon.foreground, foreground_w / 2, foreground_h / 2 + 4)

      -- Amount.
      if item_icon.amount_displayed ~= nil then
        item_icon.amount_text:set_text(tostring(item_icon.amount_displayed))

        -- The font color changes according to the amount.
        if item_icon.amount_displayed == item_icon.max_amount_displayed then
          item_icon.amount_text:set_font("green_digits")
        else
          item_icon.amount_text:set_font("white_digits")
        end

        item_icon.amount_text:draw(item_icon.foreground, foreground_w, foreground_h - 8)
      end
    end
  end
  
  -- Returns if the icon is enabled or disabled.
  function item_icon:is_enabled(active)
    return item_icon.hud_icon:is_enabled()
  end

  -- Set if the icon is enabled or disabled.
  function item_icon:set_enabled(enabled)
    item_icon.hud_icon:set_enabled(enabled)
  end
          
  -- Returns if the icon is active or inactive.
  function item_icon:is_active(active)
    return item_icon.hud_icon:is_active()
  end

  -- Set if the icon is active or inactive.
  function item_icon:set_active(active)
    item_icon.hud_icon:set_active(active)
  end

  -- Returns if the icon is transparent or not.
  function item_icon:is_transparent()
    return item_icon.hud_icon:set_transparent()
  end

  -- Sets if the icon is transparent or not.
  function item_icon:set_transparent(transparent)
    item_icon.hud_icon:set_transparent(transparent)
  end

  -- Gets the position of the icon.
  function item_icon:get_dst_position()
    return item_icon.hud_icon:get_dst_position()
  end

  -- Sets the position of the icon.
  function item_icon:set_dst_position(x, y)
    item_icon.hud_icon:set_dst_position(x, y)
  end

  -- Gets the normal position of the icon.
  function item_icon:get_normal_position()
    return item_icon.hud_icon:get_normal_position()
  end

  -- Gets the dialog position of the icon.
  function item_icon:get_dialog_position()
    return item_icon.hud_icon:get_dialog_position()
  end

  -- Gets the pause position of the icon.
  function item_icon:get_pause_position()
    return item_icon.hud_icon:get_pause_position()
  end

  -- Called when the command effect changes.
  function item_icon:on_command_effect_changed(effect)
  end

  -- Checks periodically if the icon needs to be redrawn.
  function item_icon:check()
    local need_rebuild = false

    -- Item assigned.
    local item = game:get_item_assigned(item_icon.slot)
    if item_icon.item_displayed ~= item then
      need_rebuild = true
      item_icon.item_displayed = item
      item_icon.item_variant_displayed = nil
      if item ~= nil then
        item_icon.item_sprite:set_animation(item:get_name())
      end
    end

    if item ~= nil then
      -- Variant of the item.
      local item_variant = item:get_variant()
      if item_icon.item_variant_displayed ~= item_variant then
        need_rebuild = true
        item_icon.item_variant_displayed = item_variant
        item_icon.item_sprite:set_direction(item_variant - 1)
      end

      -- Amount.
      if item:has_amount() then
        local amount = item:get_amount()
        local max_amount = item:get_max_amount()
        if item_icon.amount_displayed ~= amount or item_icon.max_amount_displayed ~= max_amount then
          need_rebuild = true
          item_icon.amount_displayed = amount
          item_icon.max_amount_displayed = max_amount
        end
      elseif item_icon.amount_displayed ~= nil then
        need_rebuild = true
        item_icon.amount_displayed = nil
        item_icon.max_amount_displayed = nil
      end
    elseif item_icon.amount_displayed ~= nil then
      need_rebuild = true
      item_icon.amount_displayed = nil
      item_icon.max_amount_displayed = nil
    end

    -- Redraw the surface only if something has changed.
    if need_rebuild then
      item_icon:rebuild_foreground()
    end

    -- Schedule the next check.
    sol.timer.start(item_icon, 50, function()
      item_icon:check()
    end)
  end
  
  -- Update the surface each time the sprite change.
  function item_icon.item_sprite:on_frame_changed()
    item_icon:rebuild_foreground()
  end

  -- Called when the menu is started.
  function item_icon:on_started()
    item_icon:check()
  end

  -- Returns the menu.
  return item_icon
end

return item_icon_builder
