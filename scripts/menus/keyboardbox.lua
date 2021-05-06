-- Dialog showing a keyboard to ask for user input.

local keyboardbox_menu = {}

local language_manager = require("scripts/language_manager")
local game_manager = require("scripts/game_manager")
local audio_manager = require("scripts/audio_manager")

-----------
-- Utils --
-----------

-- Get the string length in chars (and not in bytes as does string.len()).
local function get_string_char_len(s)

  local len_bytes = string.len(s)
  local len_char = 0
  for i = 1, len_bytes do
    local current_char = s:sub(i, i)
    local byte = current_char:byte()
    if byte >= 192 and byte < 224 then
      -- The first byte is 110xxxxx: the character is stored with two bytes (utf-8).
      -- Ignore the first byte.
    else
      -- Count this byte as a char.
      len_char = len_char + 1
    end
  end

  return len_char

end

-- Tells if the last character is a multi-byte character.
local function is_last_char_special(s)

  local len_bytes = string.len(s)
  local i = 1
  while i < len_bytes do
    local current_char = s:sub(i, i)
    local byte = current_char:byte()
    if byte >= 192 and byte < 224 then
      if i == len_bytes - 1 then
        return true
      end
      i = i + 2 -- Skip a byte.
    else
      i = i + 1      
    end
  end

  return false

end

-- Check if a game currently exists and is started.
local function is_game_started()

  if sol.main.game ~= nil then
    if sol.main.game:is_started() then
      return true
    end
  end

  return false

end

----------------
-- Initialize --
----------------

-- Initialize all the menu's features.
function keyboardbox_menu:on_started()

  -- Fix the font shift (issue with some fonts)
  self.font_y_shift = 0

  -- Elements positions relative to self.surface.
  self.textfield_x = 60
  self.textfield_y = 30
  self.keys_y = 54
  self.keys_x = 15
  
  -- Get fonts.
  local menu_font, menu_font_size = language_manager:get_menu_font()
  self.menu_font = menu_font
  self.menu_font_size = menu_font_size
  self.text_color = { 115, 59, 22 }
  self.text_color_light = { 177, 146, 116 }

  -- Create static surfaces.
  self.frame_img = sol.surface.create("menus/keyboardbox/keyboardbox_frame.png")
  self.frame_w, self.frame_h = self.frame_img:get_size()

  local keys_img = sol.surface.create("menus/keyboardbox/keyboardbox_keys.png")
  keys_img:draw(self.frame_img, self.keys_x, self.keys_y)

  self.surface = sol.surface.create(self.frame_w, self.frame_h)
  
  -- Prepare all different symbols.
  self:initialize_symbols()
  
  -- Prepare keyboard layouts.
  self:initialize_layouts()
  
  -- Prepare texts.
  self.title_text = sol.text_surface.create{
    color = self.text_color,
    horizontal_alignment = "center",
    font = self.menu_font,
    font_size = self.menu_font_size,
  }
  
  self.textfield_text = sol.text_surface.create{
    color = self.text_color,
    horizontal_alignment = "center",
    font = self.menu_font,
    font_size = self.menu_font_size,
  }
  
  -- Create sprites.
  self.textfield_sprite = sol.sprite.create("menus/keyboardbox/keyboardbox_textfield")
  self.textfield_sprite:set_animation("default")
  self.cursor_sprite = sol.sprite.create("menus/keyboardbox/keyboardbox_cursor")
  self.textfield_cursor_sprite = sol.sprite.create("menus/keyboardbox/keyboardbox_textfield_cursor")

  -- Callback when the menu is done.
  self.callback = function(result)
  end
  
  -- Custom commands effects
  local game = sol.main.game
  if game ~= nil then
    if game.set_custom_command_effect ~= nil then
        game:set_custom_command_effect("action", "return")
        game:set_custom_command_effect("attack", nil)
    end
  end
  
  -- Current state.
  self.letter_case = "upper"
  self.layout_page = "main"
  
  -- Run the menu.
  self:set_result("")
  self.min_result_size = 1
  self.max_result_size = 6
  self.cursor_position = 13
  self:update_cursor()
  self.begun = true
  self.finished = false

  self.surface:fade_in(10)
  
end

-- Initialize the keyboard layouts.
function keyboardbox_menu:initialize_layouts()

  local keyboard_layout_main_lower = {
    "-", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "erase",
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
    "shift", "special", " ", "cancel", "accept",
  }
  local keyboard_layout_main_upper = {
    "-", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "erase",
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
    "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "shift", "special", " ", "cancel", "accept",
  }
  local keyboard_layout_special_lower = {
    "à", "á", "â", "ã", "ä", "å", "æ", "è", "é", "ê", "ë", "erase",
    "ç", "đ", "ì", "í", "î", "ï", "ñ", "ò", "ó", "ô", "õ", "ö", "ø",
    "ù", "ú", "û", "ü", "ý", "œ", "ß", "&", "@", "'", "$", "€", "£", 
    "shift", "main", " ", "cancel", "accept",
  }
  local keyboard_layout_special_upper = {
    "À", "Á", "Â", "Ã", "Ä", "Å", "Æ", "È", "É", "Ê", "Ë", "erase",
    "Ç", "Đ", "Ì", "Í", "Î", "Ï", "Ñ", "Ò", "Ó", "Ô", "Õ", "Ö", "Ø",
    "Ù", "Ú", "Û", "Ü", "Ý", "Œ", "SS", "&", "@", "'", "$", "€", "£", 
    "shift", "main", " ", "cancel", "accept",
  }

  local lower_main = {
    map = keyboard_layout_main_lower,
    surface = nil,
  }
  local lower_special = {
    map = keyboard_layout_special_lower,
    surface = nil,
  }
  local upper_main = {
    map = keyboard_layout_main_upper,
    surface = nil,
  }
  local upper_special = {
    map = keyboard_layout_special_upper,
    surface = nil,
  }

  local lower_pages = {}
  lower_pages["main"] = lower_main
  lower_pages["special"] = lower_special
  local upper_pages = {}
  upper_pages["main"] = upper_main
  upper_pages["special"] = upper_special

  self.keyboard_layouts = {}
  self.keyboard_layouts["lower"] = lower_pages
  self.keyboard_layouts["upper"] = upper_pages

  local cursor_sprite_sizes = { "normal", "special", "double", "long", }
  local keyboard_layout_keys = {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    2, 2, 4, 2, 2,
  }

  -- Compute position for each key (useful to draw letters and cursor).
  self.keyboard_layout_geometries = {}
  local key_spacing = 2
  for i = 1, #keyboard_layout_keys do
    local key_type = keyboard_layout_keys[i]
    local key_cursor_type = cursor_sprite_sizes[key_type]

    local key_x = 0
    local key_y = 0
    if i <= 12 then
      key_x = self.keys_x + (i - 1) * (16 + key_spacing)
      key_y = self.keys_y
    elseif i >= 13 and i <= 25 then
      key_x = self.keys_x + (i - 1 - 12) * (16 + key_spacing)
      key_y = self.keys_y + 16 + key_spacing
    elseif i >= 26 and i <= 38 then
      key_x = self.keys_x + (i - 1 - 25) * (16 + key_spacing)
      key_y = self.keys_y + 2 * (16 + key_spacing)
    elseif i == 39 then
      key_x = 33
      key_y = 108
    elseif i == 40 then
      key_x = 60
      key_y = 108
    elseif i == 41 then
      key_x = 87
      key_y = 108
    elseif i == 42 then
      key_x = 177
      key_y = 108
    elseif i == 43 then
      key_x = 204
      key_y = 108
    end
    
    self.keyboard_layout_geometries[i] = {
      x = key_x,
      y = key_y,
      cursor_size = key_cursor_type,
    }
  end

  -- Prepare keyboard layouts surfaces.
  for layout_case, layout_pages in pairs(self.keyboard_layouts) do
    for _, layout_page in pairs(layout_pages) do
      -- Create the layout's surface.
      layout_page.surface = sol.surface.create(self.frame_w, self.frame_h)
      
      -- References for quick access.
      local map = layout_page.map
      local surface = layout_page.surface

      -- Draw all the symbols on the surface.
      for i = 1, #self.keyboard_layout_geometries do
        local layout_item_content = map[i]
        local layout_item_geometry = self.keyboard_layout_geometries[i]

        -- Check if the key is a letter or a special key.
        local symbol_surface = self.symbols[layout_item_content]
        if symbol_surface == nil then
          -- It's a letter.
          local letter_text = sol.text_surface.create{
            color = self.text_color,
            horizontal_alignment = "center",
            font = self.menu_font,
            font_size = self.menu_font_size,
            text = layout_item_content
          }

          local letter_x = layout_item_geometry.x + 8
          local letter_y = layout_item_geometry.y + 8 + self.font_y_shift

          -- Draw the letter at the correct place.
          letter_text:draw(surface, letter_x, letter_y)
        else
          -- It's a special key.
          
          local symbol_x = layout_item_geometry.x
          local symbol_y = layout_item_geometry.y

          -- Special case for the erase key.
          if layout_item_content == "erase" then
            symbol_x = symbol_x + 4 
          end

          -- Draw the special symbol at the correct place.
          local symbol_state = "off"
          if layout_item_content == "shift" and layout_case == "upper" then
            symbol_state = "on"
          end
          
          symbol_surface[symbol_state]:draw(surface, symbol_x, symbol_y)
        end
      end
    end
  end

end

-- Initialize the symbols not drawn with the font.
function keyboardbox_menu:initialize_symbols()

  local symbols_img = sol.surface.create("menus/keyboardbox/keyboardbox_symbols.png")
  self.symbols = {}
  local symbol_names = {"main", "special", "shift", "cancel", "accept", "erase" }

  for i = 1, #symbol_names do
    local symbol_surface_off = sol.surface.create(25, 16)
    local symbol_surface_on = sol.surface.create(25, 16)
    local surface_y = (i - 1) * 16
    symbols_img:draw_region(0, surface_y, 25, 16, symbol_surface_off)
    symbols_img:draw_region(25, surface_y, 25, 16, symbol_surface_on)
    local symbol_name = symbol_names[i]
    self.symbols[symbol_name] = {}
    self.symbols[symbol_name]["on"] = symbol_surface_on
    self.symbols[symbol_name]["off"] = symbol_surface_off
  end

end


----------
-- Draw --
----------

-- Draw the menu.
function keyboardbox_menu:on_draw(dst_surface)
  
  -- Dark surface.
  self:draw_dark_surface(dst_surface)
  
  -- Frame.
  self.frame_img:draw(self.surface, 0, 0)
  
  -- Title.
  self.title_text:draw(self.surface, self.frame_w / 2, 16 + self.font_y_shift)
  
  -- Text field.
  self:draw_textfield(self.surface)
  
  -- Current keyboard layout.
  self:draw_keyboard_layout(self.surface)
  
  -- Cursor.
  self:draw_cursor(self.surface)
  
  -- dst_surface may be larger: draw this menu at the center.
  local width, height = dst_surface:get_size()
  self.surface:draw(dst_surface, (width - self.frame_w) / 2, (height - self.frame_h) / 2)

end

-- Update the dark surface if necessary.
function keyboardbox_menu:update_dark_surface(width, height)

  -- Check if the surface needs to be updated
  if self.dark_surface ~= nil then
    local dark_surface_w, dark_surface_h = self.dark_surface:get_size()
    if width ~= dark_surface_w or height ~= dark_surface_h then
      self.dark_surface = nil
    end
  end

  -- (Re)create the surface if necessary.
  if self.dark_surface == nil then
    self.dark_surface = sol.surface.create(width, height)
    self.dark_surface:fill_color({112, 112, 112})
    self.dark_surface:set_blend_mode("multiply")
    self.dark_surface:fade_in(10)
  end

end

-- Draw a dark surface above below screen.
function keyboardbox_menu:draw_dark_surface(dst_surface)

  local width, height = dst_surface:get_size()
  self:update_dark_surface(width, height)
  self.dark_surface:draw(dst_surface, 0, 0)

end

-- Draw the cursor.
function keyboardbox_menu:draw_cursor(dst_surface)

  -- Check if the position is valid.
  if self.cursor_position > 0 then
    -- Draw the cursor sprite.
    self.cursor_sprite:draw(dst_surface, self.cursor_x, self.cursor_y)
  end

end

-- Draw the textfield and its content.
function keyboardbox_menu:draw_textfield(dst_surface)
  local frame_center_x = self.frame_w / 2
  
  -- Field.
  self.textfield_sprite:draw(self.surface, frame_center_x, 38)

  -- Text.
  self.textfield_text:draw(self.surface, frame_center_x, 38 + self.font_y_shift)
  
  -- Cursor.
  if not self.finished and self.begun then
    local textfield_text_w, textfield_text_h = self.textfield_text:get_size()
    self.textfield_cursor_sprite:draw(self.surface, frame_center_x + textfield_text_w / 2, 38)
  end

end


------------
-- Cursor --
------------

-- Change the cursor position.
function keyboardbox_menu:set_cursor_position(position)

  if position ~= self.cursor_position then
    self.cursor_position = position
    self:update_cursor()
  end

end

-- Update the cursor (change x, y and sprite according to position).
function keyboardbox_menu:update_cursor()

  if self.cursor_position > 0 then
    local item_geometry = self.keyboard_layout_geometries[self.cursor_position]
    
    -- Update coordinates.
    self.cursor_x = item_geometry.x - 4
    self.cursor_y = item_geometry.y - 4
    
    -- Update the animation.
    self.cursor_sprite:set_animation(item_geometry.cursor_size)
  else
    -- Update coordinates to make the cursor not visible.
    self.cursor_x = -999
    self.cursor_y = -999

    -- Update the animation.    
    self.cursor_sprite:set_animation("none")
  end

  -- Restart the animation.
  self.cursor_sprite:set_frame(0)

end

-- Move the cursor according to its current location.
function keyboardbox_menu:move_cursor(key)

  local new_cursor_position = self:get_cursor_next_position(self.cursor_position, key)

  self:set_cursor_position(new_cursor_position)
  audio_manager:play_sound("menus/menu_cursor")

  -- Always handle the key.
  return true

end

-- Get the curor's next valid position.
function keyboardbox_menu:get_cursor_next_position(current_position, key)

  local next_position = current_position

  if current_position >= 1 and current_position <= 12 then
    if key == "up" then
      if current_position >= 1 and current_position <= 2 then
        next_position = 39
      elseif current_position == 3 or current_position == 4 then
        next_position = 40
      elseif current_position >= 5 and current_position <= 9 then
        next_position = 41
      elseif current_position == 10 then
        next_position = 42
      elseif current_position >= 11 and current_position <= 12 then
        next_position = 43
      end
    elseif key == "left" then
      if current_position == 1 then
      next_position = 12        
      else
        next_position = current_position - 1
      end
    elseif key == "right" then
      if current_position == 12 then
        next_position = 1
      else
        next_position = current_position + 1
      end
    elseif key== "down" then
      next_position = current_position + 12
    end
  elseif current_position >= 13 and current_position <= 25 then
    if key == "up" then
      if current_position == 25 then
        next_position = 12
      else
        next_position = current_position - 12        
      end
    elseif key == "left" then
      if current_position == 13 then      
        next_position = 25
      else
        next_position = current_position - 1        
      end
    elseif key == "right" then
      if current_position == 25 then
        next_position = 13
      else
        next_position = current_position + 1
      end
    elseif key== "down" then
      next_position = current_position + 13
    end
  elseif current_position >= 26 and current_position <= 38 then
    if key == "up" then
        next_position = current_position - 13
    elseif key == "left" then
      if current_position == 26 then      
        next_position = 38
      else
        next_position = current_position - 1        
      end
    elseif key == "right" then
      if current_position == 38 then
        next_position = 26
      else
        next_position = current_position + 1
      end
    elseif key== "down" then
      if current_position >= 26 and current_position <= 27 then
        next_position = 39
      elseif current_position >= 28 and current_position <= 29 then
        next_position = 40
      elseif current_position >= 30 and current_position <= 34 then
        next_position = 41
      elseif current_position == 35 then
        next_position = 42
      elseif current_position >= 36 and current_position <= 38 then
        next_position = 43
      end
    end
  elseif current_position >= 39 and current_position <= 43 then
    if key == "up" then
      if current_position == 39 then 
        next_position = 27
      elseif current_position == 40 then
        next_position = 29
      elseif current_position == 41 then
        next_position = 32
      elseif current_position == 42 then
        next_position = 35
      elseif current_position == 43 then
        next_position = 36
      end
    elseif key == "left" then
      if current_position == 39 then
        next_position = 43
      else
        next_position = current_position - 1        
      end
    elseif key == "right" then
      if current_position == 43 then
        next_position = 39
      else
        next_position = current_position + 1
      end
    elseif key== "down" then
      if current_position == 39 then 
        next_position = 2
      elseif current_position == 40 then
        next_position = 4
      elseif current_position == 41 then
        next_position = 7
      elseif current_position == 42 then
        next_position = 10
      elseif current_position == 43 then
        next_position = 11
      end
    end
  else
    next_position = 13 -- Default position.
  end

  return next_position

end

-- Press the key at the cursor.
function keyboardbox_menu:validate_cursor()

  -- Check if the key is a letter or a special key.
  local keyboard_layout = self:get_keyboard_layout()
  if keyboard_layout == nil then
    audio_manager:play_sound("misc/error")
    return
  end

  local layout_item_content = keyboard_layout.map[self.cursor_position]
  local symbol_surface = self.symbols[layout_item_content]
  if symbol_surface == nil then
    -- Add a character.
    self:add_letter(layout_item_content)
  else
    if layout_item_content == "erase" then
      -- Erase last character.
      self:erase()
    elseif layout_item_content == "shift" then
      -- Switch between lowercase and uppercase layouts.
      self:shift()
    elseif layout_item_content == "main" or layout_item_content == "special" then
      -- Switch between main and special layouts.
      self:set_layout(layout_item_content)
    elseif layout_item_content == "cancel" then
      -- Cancel this menu.
      self:reject()
    elseif layout_item_content == "accept" then
      -- Accepts this menu.
      self:accept()
    else
      audio_manager:play_sound("misc/error")
    end
  end

end


---------------------
-- Keyboard layout --
---------------------

-- Get the current keyboard layout.
function keyboardbox_menu:get_keyboard_layout()

  local current_layout = nil
  local layout_pages = self.keyboard_layouts[self.letter_case]
  if layout_pages ~= nil then
    local layout_page = layout_pages[self.layout_page]
    if layout_page ~= nil then
      current_layout = layout_page
    end
  end

  return current_layout

end

-- Draw current keyboard layout.
function keyboardbox_menu:draw_keyboard_layout(dst_surface)
  
  -- Get current layout.
  local current_layout = self:get_keyboard_layout()

  -- Draw this current layout.
  if current_layout ~= nil then
    current_layout.surface:draw(self.surface, 0, 0)
  end

end


--------------
-- Commands --
--------------

-- Change the displayed text in the textfield.
function keyboardbox_menu:set_result(result)

  self.result = result
  self.textfield_text:set_text(result)

end

-- Add the character to the result.
function keyboardbox_menu:add_letter(letter)

  if get_string_char_len(self.result) < self.max_result_size then
    self:set_result(self.result..letter)
    self.textfield_cursor_sprite:set_frame(0)
    audio_manager:play_sound("menus/menu_select")
  else
    self.textfield_cursor_sprite:set_frame(0)
    audio_manager:play_sound("misc/error")
  end

end

-- Erase the result's last character.
function keyboardbox_menu:erase()

  if get_string_char_len(self.result) > 0 then
    local remove_count = 1
    if is_last_char_special(self.result) then
      remove_count = 2
    end

    self:set_result(string.sub(self.result, 1, string.len(self.result) - remove_count))
    self.textfield_cursor_sprite:set_frame(0)
    audio_manager:play_sound("menus/menu_select")

  else
    self.textfield_cursor_sprite:set_frame(0)
    audio_manager:play_sound("misc/error")
  end

end

-- Switch the keyboard to upper or lower.
function keyboardbox_menu:shift()

  if self.letter_case == "upper" then
    self.letter_case = "lower"
  elseif self.letter_case == "lower" then
    self.letter_case = "upper"
  else
    self.letter_case = "lower" -- By default    
  end

  audio_manager:play_sound("misc/error")

end

-- Switch the keyboard page.
function keyboardbox_menu:set_layout(layout)

  self.layout_page = layout
  audio_manager:play_sound("misc/error")

end

-- Hander player input when there is no lauched game yet.
function keyboardbox_menu:on_key_pressed(key)

  if not is_game_started() then
    if self.begun and self.finished then
      return true
    end
    
    -- Escape: cancel the dialog (same as choosing No).
    if key == "escape" then
      self:reject()
    -- Left/right/up/down: moves the cursor.
    elseif key == "left" or key == "right" or key == "up" or key == "down" then
      self:move_cursor(key)
    elseif key == "backspace" then
      self:erase()      
    -- Space/Return: validate the button at the cursor.
    elseif key == "space" or key == "return" then
      self:validate_cursor()
    end
  end

  -- Don't propagate the event to anything below the dialog box.
  return true

end

-- Accept the keyboardbox if possible.
function keyboardbox_menu:accept()

  local char_lenght = get_string_char_len(self.result)
  if char_lenght >= self.min_result_size and char_lenght <= self.max_result_size then
    self.finished = true
    audio_manager:play_sound("menus/menu_select")
    self.textfield_cursor_sprite:set_paused(true)
    self.cursor_sprite:set_paused(true)

    sol.timer.start(self, 300, function()
      audio_manager:play_sound("menus/menu_select")
      self.textfield_sprite:set_animation("confirm")
      
      sol.timer.start(self, 700, function()
        self.textfield_sprite:set_paused(true)
        self.textfield_sprite:set_frame(0)

        sol.timer.start(self, 300, function()         
          self:done()
          self:close()
        end)
      end)
    end)
  else
    audio_manager:play_sound("misc/error")
  end

end

-- Rejects the keyboardbox.
function keyboardbox_menu:reject()
  
  self.finished = true
  audio_manager:play_sound("menus/menu_select")
  self.textfield_cursor_sprite:set_paused(true)
  self.cursor_sprite:set_paused(true)
  
  sol.timer.start(self, 300, function()
    self.result = ""
    self:done()
    self:close()
  end)

end

-- Calls the callback when the keyboardbox is done.
function keyboardbox_menu:done()

  if self.callback ~= nil then
    self.callback(self.result)
  end

end

-- Close this dialog with a fade out.
function keyboardbox_menu:close()
  audio_manager:play_sound("menus/pause_menu_close")
  
  local delay = 10
  if self.dark_surface ~= nil then
    self.dark_surface:fade_out(delay)
  end

  self.surface:fade_out(delay, function()
    sol.menu.stop(self)
  end)
end

-- Show the messagebox with the text in parameter.
function keyboardbox_menu:show(context, title, default_input, min_characters, max_characters, callback)

  -- Show the menu.
  sol.menu.start(context, self, true)
  audio_manager:play_sound("menus/menu_select")

  -- Title.
  self.title_text:set_text(title)

  -- Default input (generally and empty string).
  self:set_result(default_input)
  self.min_result_size = min_characters
  self.max_result_size = max_characters

  -- Callback to call when the keyboardbox is closed.
  self.callback = callback

  -- Default cursor position: first key of the second line (A).
  self.layout_page = "main"
  self.letter_case = "upper"
  self:set_cursor_position(13)

  -- Block cursors for a few milliseconds.
  self.begun = false
  self.finished = false
  self.cursor_sprite:set_paused(true)
  self.textfield_cursor_sprite:set_paused(true)

  sol.timer.start(self, 400, function()
    self.begun = true
    self.cursor_sprite:set_paused(false)
    self.textfield_cursor_sprite:set_paused(false)
  end)
end

-------------------

-- Return the menu.
return keyboardbox_menu
