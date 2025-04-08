local submenu = require("scripts/menus/pause/pause_submenu")
local audio_manager = require("scripts/audio_manager")

local quest_submenu = submenu:new()
local item_names_static_left = {
  "instrument_1",
  "instrument_2",
  "instrument_3",
  "instrument_4",
  "magnifying_lens",
  "instrument_5",
  "instrument_6",
  "instrument_7",
  "instrument_8",
}
local item_names_static_right = {
  "tail_key",
  "slim_key",
  "angler_key",
  "face_key",
  "bird_key",
}
local item_names_static_bottom = {
  "seashells_counter",
  "photos_counter",
  "golden_leaves_counter",
}

function quest_submenu:on_started()

  submenu.on_started(self)
    
  -- Set title
  self:set_title(sol.language.get_string("quest_status.title"))

  -- Initialize the menu.
  self.cursor_sprite = sol.sprite.create("menus/pause/cursor")
  self.hearts = sol.surface.create("menus/pause/quest/pieces_of_heart.png")
  self.counters = {}
  self.sprites_static_left = {}
  self.sprites_static_right = {}
  self.sprites_static_bottom = {}

  -- Initialize the cursor.
  local index = self.game:get_value("pause_inventory_last_item_index") or 0
  local row = math.floor(index / 7)
  local column = index % 7
  self:set_cursor_position(row, column)

  -- Load Items.
  for i,item_name in ipairs(item_names_static_left) do
    local item = self.game:get_item(item_name)
    local variant = item:get_variant()
    self.sprites_static_left[i] = sol.sprite.create("entities/items")
    self.sprites_static_left[i]:set_animation(item_name)
  end
  for i,item_name in ipairs(item_names_static_right) do
    local item = self.game:get_item(item_name)
    local variant = item:get_variant()
    self.sprites_static_right[i] = sol.sprite.create("entities/items")
    self.sprites_static_right[i]:set_animation(item_name)
  end
  for i,item_name in ipairs(item_names_static_bottom) do
    local item = self.game:get_item(item_name)
    local variant = item:get_variant()
    self.sprites_static_bottom[i] = sol.sprite.create("entities/items")
    self.sprites_static_bottom[i]:set_animation(item_name)
    if item:has_amount() then
      -- Show a counter in this case.
      local amount = item:get_amount()
      local maximum = item:get_max_amount()
      self.counters[i] = sol.text_surface.create{
        horizontal_alignment = "center",
        vertical_alignment = "top",
        text = item:get_amount(),
        font = (amount == maximum) and "green_digits" or "white_digits",
      }
    end
  end
end

function quest_submenu:on_finished()
  -- Nothing.
end

function quest_submenu:on_draw(dst_surface)

  local cell_size = 28
  local cell_spacing = 4

  local width, height = dst_surface:get_size()
  local center_x = width / 2
  local center_y = height / 2
  local menu_x, menu_y = center_x - self.width / 2, center_y - self.height / 2

  -- Draw the background.
  self:draw_background(dst_surface)
  
  -- Draw the cursor caption.
  self:draw_caption(dst_surface)

  -- Draw each inventory static item left.
  local y = menu_y + 84
  local k = 0
  for i = 0, 2 do
    local x = menu_x + 64
    for j = 0, 2 do
      if x == 1 and x == 1 then
        x = x + 1
      end
      k = k + 1
      if item_names_static_left[k] ~= nil then
        local item = self.game:get_item(item_names_static_left[k])
        if item and item:get_variant() > 0 then
          -- The player has this item: draw it.
          if item_names_static_left[k] == "magnifying_lens" then
            self.sprites_static_left[k]:set_direction(item:get_variant() - 1)
          else
            self.sprites_static_left[k]:set_direction(item:get_variant())
          end
          self.sprites_static_left[k]:draw(dst_surface, x, y)
        end
      end
      x = x + 32
    end
    y = y + 32
  end
  
  -- Draw each inventory static item right.
  for i, item_name in ipairs(item_names_static_right) do
        local item = self.game:get_item(item_name)
        local x = menu_x
        local y = menu_y
        if item:get_variant() > 0 then
          -- The player has this item: draw it.
          if i == 1 then
            x = menu_x + 192
            y = menu_y + 116
          elseif i == 2 then
            x = menu_x + 224
            y = menu_y + 84
          elseif i == 3 then
            x = menu_x + 256
            y = menu_y + 116
          elseif i == 4 then
            x = menu_x + 224
            y = menu_y + 148
          elseif i == 5 then
            x = menu_x + 224
            y = menu_y + 116
          end
          self.sprites_static_right[i]:set_direction(item:get_variant() - 1)
          self.sprites_static_right[i]:draw(dst_surface, x, y)
        end
  end

  -- Draw each inventory static item bottom.
  local x = menu_x + 64
  local y = menu_y + 178
  local k = 0
  for i = 0, 2 do
    k = k + 1
    if item_names_static_bottom[k] ~= nil then
      local item = self.game:get_item(item_names_static_bottom[k])
      --if item:get_variant() > 0 then
        -- The player has this item: draw it.
        if self.counters[k] ~= nil then
          if item:get_amount() > 0 then
            self.sprites_static_bottom[k]:set_direction(item:get_variant() )
            self.sprites_static_bottom[k]:draw(dst_surface, x, y)
            self.counters[k]:draw(dst_surface, x + 8, y)
          end
        else
          self.sprites_static_bottom[k]:set_direction(item:get_variant() )
          self.sprites_static_bottom[k]:draw(dst_surface, x, y)
        end
      --end
    end
    x = x + 32
  end

  -- Pieces of heart.
  local num_pieces_of_heart = self.game:get_item("piece_of_heart"):get_num_pieces_of_heart()
  local pieces_of_heart_w = 28
  local pieces_of_heart_x = pieces_of_heart_w * num_pieces_of_heart
  self.hearts:draw_region(
    pieces_of_heart_x, 0,                 -- region position in image
    pieces_of_heart_w, pieces_of_heart_w, -- region size in image
    dst_surface,                          -- destination surface
    menu_x + 146, menu_y + 160            -- position in destination surface
  )
  
  -- Draw cursor only when the save dialog is not displayed.
  if not self.dialog_opened then
    self.cursor_sprite:draw(dst_surface, menu_x + 64 + 32 * self.cursor_column, menu_y + 79 + 32 * self.cursor_row)
  end

end

function quest_submenu:on_command_pressed(command)
  
  local handled = submenu.on_command_pressed(self, command)

  if not handled then

    if command == "action" then
      if self.game:get_command_effect("action") == nil and self.game:get_custom_command_effect("action") == "info" then
        handled = true
        self:show_info_message()
      end

    elseif command == "left" then
      if self.cursor_column == 0 then
        self:previous_submenu()
      else
        audio_manager:play_sound("menus/menu_cursor")
        if self.cursor_column == 5 and  self.cursor_row == 0 then
          self:set_cursor_position(self.cursor_row, self.cursor_column - 3)
        elseif self.cursor_column == 4 and  self.cursor_row == 1 then
          self:set_cursor_position(self.cursor_row, self.cursor_column - 2)
        elseif self.cursor_column == 5 and  self.cursor_row == 2 then
          self:set_cursor_position(self.cursor_row, self.cursor_column - 3)
        else
          self:set_cursor_position(self.cursor_row, self.cursor_column - 1)
        end
      end
      handled = true

    elseif command == "right" then
      if self.cursor_column == 6
          or self.cursor_column == 5 and  self.cursor_row == 0
          or self.cursor_column == 5 and  self.cursor_row == 2 
          or self.cursor_column == 3 and  self.cursor_row == 3  then
        self:next_submenu()
      else
        audio_manager:play_sound("menus/menu_cursor")
        if self.cursor_column == 2 and  self.cursor_row == 0 then
          self:set_cursor_position(self.cursor_row, self.cursor_column + 3)
        elseif self.cursor_column == 2 and  self.cursor_row == 1 then
          self:set_cursor_position(self.cursor_row, self.cursor_column + 2)
        elseif self.cursor_column == 2 and  self.cursor_row == 2 then
          self:set_cursor_position(self.cursor_row, self.cursor_column + 3)
        else
          self:set_cursor_position(self.cursor_row, self.cursor_column + 1)
        end
      end
      handled = true

    elseif command == "up" then
      if self.cursor_column ~= 3 and self.cursor_column ~= 4 and self.cursor_column ~= 6 then
        audio_manager:play_sound("menus/menu_cursor")
        if self.cursor_column == 5 and  self.cursor_row == 0 then
          self:set_cursor_position((self.cursor_row + 2) % 4, self.cursor_column)
        else
          self:set_cursor_position((self.cursor_row + 3) % 4, self.cursor_column)
        end
      end
      handled = true

    elseif command == "down" then
      if self.cursor_column ~= 3 and self.cursor_column ~= 4 and self.cursor_column ~= 6 then
        audio_manager:play_sound("menus/menu_cursor")
        if self.cursor_column == 5 and  self.cursor_row == 2 then
          self:set_cursor_position((self.cursor_row - 2) % 4, self.cursor_column)
        else
          self:set_cursor_position((self.cursor_row + 1) % 4, self.cursor_column)
        end
      end
      handled = true
    end
  end

  return handled

end

-- Shows a message describing the item currently selected.
-- The player is supposed to have this item.
function quest_submenu:show_info_message()

  local item_name = self:get_item_name(self.cursor_row, self.cursor_column)
  local game = self.game
  local map = game:get_map()
  local dialog_id = false
  if item_name == "piece_of_heart" then
    dialog_id =  "scripts.menus.pause_inventory.piece_of_heart.1" 
  elseif item_name == "seashells_counter" then
    local item = item_name and self.game:get_item(item_name) or nil
    if item:get_amount() > 0 then
      dialog_id =  "scripts.menus.pause_inventory.seashells_counter.1" 
    end
  elseif item_name == "photos_counter" then
    local item = item_name and self.game:get_item(item_name) or nil
    if item:get_amount() > 0 then
      dialog_id =  "scripts.menus.pause_inventory.photos_counter.1" 
    end
  elseif item_name == "golden_leaves_counter" then
    local item = item_name and self.game:get_item(item_name) or nil
    if item:get_amount() > 0 then
      dialog_id =  "scripts.menus.pause_inventory.golden_leaves_counter.1" 
    end
  else
    local variant = self.game:get_item(item_name):get_variant()
    dialog_id = "scripts.menus.pause_inventory." .. item_name .. "." .. variant
  end
  if dialog_id then
    self:show_info_dialog(dialog_id, function()
      self:set_cursor_position(self.cursor_row, self.cursor_column)
    end)
  end
end

function quest_submenu:set_cursor_position(row, column)

  self.cursor_row = row
  self.cursor_column = column
  local index
  local item_name
  self.game:set_value("pause_inventory_last_item_index", index)

  -- Update the caption text and the action icon.
  local item_name = self:get_item_name(row, column)
  if item_name =="piece_of_heart" then
      local num_pieces_of_heart = self.game:get_item("piece_of_heart"):get_num_pieces_of_heart()
      self:set_caption_key("inventory.caption.item.piece_of_heart."..num_pieces_of_heart)
      self.game:set_custom_command_effect("action", "info")
  elseif item_name =="seashells_counter" then
    local item = item_name and self.game:get_item(item_name) or nil
    if item:get_amount() > 0 then
      self:set_caption_key("inventory.caption.item.seashells_counter.1")
      self.game:set_custom_command_effect("action", "info")
    else
      self:set_caption_key(nil)
      self.game:set_custom_command_effect("action", nil)
    end
  elseif item_name =="photos_counter" then
    local item = item_name and self.game:get_item(item_name) or nil
    if item:get_amount() > 0 then
      self:set_caption_key("inventory.caption.item.photos_counter.1")
      self.game:set_custom_command_effect("action", "info")
    else
      self:set_caption_key(nil)
      self.game:set_custom_command_effect("action", nil)
    end
  elseif item_name =="golden_leaves_counter" then
    local item = item_name and self.game:get_item(item_name) or nil
    if item:get_amount() > 0 then
      self:set_caption_key("inventory.caption.item.golden_leaves_counter.1")
      self.game:set_custom_command_effect("action", "info")
    else
      self:set_caption_key(nil)
      self.game:set_custom_command_effect("action", nil)
    end
  else
    local item = item_name and self.game:get_item(item_name) or nil
    local variant = item and item:get_variant()
    local item_icon_opacity = 128
    if variant > 0 then
      self:set_caption_key("inventory.caption.item." .. item_name .. "." .. variant)
      self.game:set_custom_command_effect("action", "info")
      if item:is_assignable() then
        self.game:set_hud_mode("normal")
      else
        self.game:set_hud_mode("pause")
      end
    else
      self:set_caption_key(nil)
      self.game:set_custom_command_effect("action", nil)
      self.game:set_hud_mode("pause")
    end
  end
end

function quest_submenu:get_item_name(row, column)

    if column < 3 and row < 3 then
      index = row * 3 + column
      item_name = item_names_static_left[index + 1]
    elseif column == 5 and row == 0 then
      item_name = "slim_key"
    elseif column == 4 and row == 1 then
      item_name = "tail_key"
    elseif column == 5 and row == 1 then
      item_name = "bird_key"
    elseif column == 6 and row == 1 then
      item_name = "angler_key"
    elseif column == 5 and row == 2 then
      item_name = "face_key"
    elseif column == 3 and row == 3 then
      item_name = "piece_of_heart"
    else 
      index = column
      item_name = item_names_static_bottom[index + 1]
    end

  return item_name
end

return quest_submenu