





------------------------------
-- Phase "choose your name" --
------------------------------
function savegame_menu:init_phase_choose_name()

  self.phase = "choose_name"
  self.title_text:set_text_key("selection_menu.phase.choose_name")
  self.cursor_sprite:set_animation("letters")
  self.player_name = ""
  local font, font_size = language_manager:get_menu_font()
  self.player_name_text = sol.text_surface.create{
    font = font,
    font_size = font_size,
  }
  self.letter_cursor = { x = 0, y = 0 }
  self.letters_img = sol.surface.create("menus/selection_menu_letters.png")
  self.name_arrow_sprite = sol.sprite.create("menus/arrow")
  self.name_arrow_sprite:set_direction(0)
  self.can_add_letter_player_name = true
end

function savegame_menu:key_pressed_phase_choose_name(key)

  local handled = false
  local finished = false
  if key == "return" then
    -- Directly validate the name.
    finished = self:validate_player_name()
    handled = true

  elseif key == "space" or key == "c" then

    if self.can_add_letter_player_name then
      -- Choose a letter
      finished = self:add_letter_player_name()
      self.player_name_text:set_text(self.player_name)
      self.can_add_letter_player_name = false
      sol.timer.start(self, 300, function()
        self.can_add_letter_player_name = true
      end)
      handled = true
    end
  end

  if finished then
    self:init_phase_select_file()
  end

  return handled
end

function savegame_menu:joypad_button_pressed_phase_choose_name(button)

  return self:key_pressed_phase_choose_name("space")
end

function savegame_menu:direction_pressed_phase_choose_name(direction8)

  local handled = true
  if direction8 == 0 then  -- Right.
    sol.audio.play_sound("menus/cursor")
    self.letter_cursor.x = (self.letter_cursor.x + 1) % 13

  elseif direction8 == 2 then  -- Up.
    sol.audio.play_sound("menus/cursor")
    self.letter_cursor.y = (self.letter_cursor.y + 4) % 5

  elseif direction8 == 4 then  -- Left.
    sol.audio.play_sound("menus/cursor")
    self.letter_cursor.x = (self.letter_cursor.x + 12) % 13

  elseif direction8 == 6 then  -- Down.
    sol.audio.play_sound("menus/cursor")
    self.letter_cursor.y = (self.letter_cursor.y + 1) % 5

  else
    handled = false
  end
  return handled
end

function savegame_menu:draw_phase_choose_name()

  -- Letter cursor.
  self.cursor_sprite:draw(self.surface,
      51 + 16 * self.letter_cursor.x,
      55 + 18 * self.letter_cursor.y)

  -- Name and letters.
  self.name_arrow_sprite:draw(self.surface, 57, 38)
  self.player_name_text:draw(self.surface, 67, 47)
  self.letters_img:draw(self.surface, 57, 60)
end

function savegame_menu:add_letter_player_name()

  local size = self.player_name:len()
  local letter_cursor = self.letter_cursor
  local letter_to_add = nil
  local finished = false

  if letter_cursor.y == 0 then  -- Uppercase letter from A to M.
    letter_to_add = string.char(string.byte("A") + letter_cursor.x)

  elseif letter_cursor.y == 1 then  -- Uppercase letter from N to Z.
    letter_to_add = string.char(string.byte("N") + letter_cursor.x)

  elseif letter_cursor.y == 2 then  -- Lowercase letter from a to m.
    letter_to_add = string.char(string.byte("a") + letter_cursor.x)

  elseif letter_cursor.y == 3 then  -- Lowercase letter from n to z.
    letter_to_add = string.char(string.byte("n") + letter_cursor.x)

  elseif letter_cursor.y == 4 then  -- Digit or special command.
    if letter_cursor.x <= 9 then
      -- Digit.
      letter_to_add = string.char(string.byte("0") + letter_cursor.x)
    else
      -- Special command.

      if letter_cursor.x == 10 then  -- Remove the last letter.
        if size == 0 then
          sol.audio.play_sound("common/wrong")
        else
          sol.audio.play_sound("menus/danger")
          self.player_name = self.player_name:sub(1, size - 1)
        end

      elseif letter_cursor.x == 11 then  -- Validate the choice.
        finished = self:validate_player_name()

      elseif letter_cursor.x == 12 then  -- Cancel.
        sol.audio.play_sound("menus/danger")
        finished = true
      end
    end
  end

  if letter_to_add ~= nil then
    -- A letter was selected.
    if size < 6 then
      sol.audio.play_sound("menus/danger")
      self.player_name = self.player_name .. letter_to_add
    else
      sol.audio.play_sound("common/wrong")
    end
  end

  return finished
end

function savegame_menu:validate_player_name()

  if self.player_name:len() == 0 then
    sol.audio.play_sound("common/wrong")
    return false
  end

  sol.audio.play_sound("menus/select")
  if self.player_name:lower() == "zelda" or self.player_name:lower() == "ju" or self.player_name:lower() == "lucifer" or self.player_name:lower() == "linkff" or self.player_name:lower() == "salade verte" then
    sol.audio.play_music("cutscenes/credits")
  end
  if self.player_name:lower() == "moyse" then
    sol.audio.play_music("cutscenes/savegames")
  end

  local savegame = self.slots[self.cursor_position].savegame
  savegame:set_value("player_name", self.player_name)
  savegame:save()
  self:read_savegames()
  return true
end
