local submenu = require("scripts/menus/pause/pause_submenu")
local language_manager = require("scripts/language_manager")
local shader_manager = require("scripts/shader_manager")
local text_fx_helper = require("scripts/text_fx_helper")
local effect_manager = require('scripts/maps/effect_manager')
local tft = require('scripts/maps/tft_effect')
local fsa = require('scripts/maps/fsa_effect')
local options_submenu = submenu:new()

function options_submenu:on_started()

  submenu.on_started(self)

  local font, font_size = language_manager:get_menu_font()
  local width, height = sol.video.get_quest_size()
  local center_x, center_y = width / 2, height / 2

  -- Set the title.
  self:set_title(sol.language.get_string("options.title"))

  self.column_color = { 224, 224, 224}
  self.column_stroke_color = { 55, 55, 25}
  self.text_color = { 224, 224, 224 }

  self.shader_effect_list_str = {"fsa", "snes", "tft"}
  self.shader_effect_list = {require('scripts/maps/fsa_effect'), nil, require('scripts/maps/tft_effect')}

  self.shader_effect_label_text = sol.text_surface.create{
    horizontal_alignment = "left",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "selection_menu.options.video_mode",
    color = self.text_color,
  }
  self.shader_effect_label_text:set_xy(center_x - 42, center_y - 55)

  self.shader_effect_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text = sol.video.get_shader(),
    color = self.text_color,
  }
  self.shader_effect_text:set_xy(center_x + 72, center_y - 55)

  self:load_video_mode_texts()

  self.command_column_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "options.commands_column",
    color = self.column_color,
  }
  self.command_column_text:set_xy(center_x - 73, center_y - 32)

  self.keyboard_column_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "options.keyboard_column",
    color = self.column_color,
  }
  self.keyboard_column_text:set_xy(center_x - 4, center_y - 32)

  self.joypad_column_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "options.joypad_column",
    color = self.column_color,
  }
  self.joypad_column_text:set_xy(center_x + 68, center_y - 32)

  self.commands_surface = sol.surface.create(215, 160)
  self.commands_surface:set_xy(center_x - 107, center_y - 18)
  self.commands_highest_visible = 1
  self.commands_visible_y = 0

  self.command_texts = {}
  self.keyboard_texts = {}
  self.joypad_texts = {}
  self.command_names = { "action", "attack", "item_1", "item_2", "pause", "left", "right", "up", "down" }
  
  for i = 1, #self.command_names do

    self.command_texts[i] = sol.text_surface.create{
      horizontal_alignment = "left",
      vertical_alignment = "top",
      font = font,
      font_size = font_size,
      text_key = "options.command." .. self.command_names[i],
      color = self.text_color,
    }

    self.keyboard_texts[i] = sol.text_surface.create{
      horizontal_alignment = "left",
      vertical_alignment = "top",
      font = font,
      font_size = font_size,
      color = self.text_color,
    }

    self.joypad_texts[i] = sol.text_surface.create{
      horizontal_alignment = "left",
      vertical_alignment = "top",
      font = font,
      font_size = font_size,
      color = self.text_color,
    }
  end

  self:load_command_texts()

  self.up_arrow_sprite = sol.sprite.create("menus/arrow")
  self.up_arrow_sprite:set_direction(1)
  self.up_arrow_sprite:set_xy(center_x - 64, center_y - 24)
  self.down_arrow_sprite = sol.sprite.create("menus/arrow")
  self.down_arrow_sprite:set_direction(3)
  self.down_arrow_sprite:set_xy(center_x - 64, center_y + 62)
  self.cursor_sprite = sol.sprite.create("menus/pause/options/cursor")
  self.command_cursor_sprite = sol.sprite.create("menus/pause/options/command_cursor")
  self.cursor_position = nil
  self:set_cursor_position(1)
  self.waiting_for_command = false

  self.game:set_custom_command_effect("action", "change")
end

-- Loads the text displayed for each video mode.
function options_submenu:load_video_mode_texts()
  if self.game:get_value("mode") == "fsa" then self.current_video_mode_index = 1
  elseif self.game:get_value("mode") == "snes" then self.current_video_mode_index = 2
  elseif self.game:get_value("mode") == "tft" then self.current_video_mode_index = 3 end
  self.current_video_mode_index = (((self.current_video_mode_index - 1) % 3) + 1)
  self.shader_effect_text:set_text_key("options.shader_effect."..self.shader_effect_list_str[self.current_video_mode_index])
end

-- Loads the text displayed for each game command, for the
-- keyboard and the joypad.
function options_submenu:load_command_texts()

  self.commands_surface:clear()
  for i = 1, #self.command_names do
    local keyboard_binding = self.game:get_command_keyboard_binding(self.command_names[i])
    local joypad_binding = self.game:get_command_joypad_binding(self.command_names[i])
    self.keyboard_texts[i]:set_text(keyboard_binding:sub(1, 9))
    self.joypad_texts[i]:set_text(joypad_binding:sub(1, 9))

    local y = 16 * i - 14
    self.command_texts[i]:draw(self.commands_surface, 4, y)
    self.keyboard_texts[i]:draw(self.commands_surface, 75, y)
    self.joypad_texts[i]:draw(self.commands_surface, 146, y)
  end
end

function options_submenu:set_cursor_position(position)

  if position ~= self.cursor_position then

    local width, height = sol.video.get_quest_size()

    self.cursor_position = position
    if position == 1 then  -- Video mode.
      self:set_caption_key("options.caption.press_action_change_mode")
      self.cursor_sprite.x = width / 2 + 78 - 2
      self.cursor_sprite.y = height / 2 - 51 + 2
    else  -- Customization of a command.
      self:set_caption_key("options.caption.press_action_customize_key")

      -- Make sure the selected command is visible.
      while position <= self.commands_highest_visible do
        self.commands_highest_visible = self.commands_highest_visible - 1
        self.commands_visible_y = self.commands_visible_y - 16
      end

      while position > self.commands_highest_visible + 5 do
        self.commands_highest_visible = self.commands_highest_visible + 1
        self.commands_visible_y = self.commands_visible_y + 16
      end

      self.cursor_sprite.x = width / 2 - 71
      self.cursor_sprite.y = height / 2 - 32 + 6 + 16 * (position - self.commands_highest_visible)
    end
  end
end

function options_submenu:on_draw(dst_surface)

  -- Draw background.
  self:draw_background(dst_surface)
  
  -- Draw caption.
  self:draw_caption(dst_surface)

  -- Text.
  text_fx_helper:draw_text_with_stroke(dst_surface, self.shader_effect_label_text, self.column_stroke_color)
  self.shader_effect_text:draw(dst_surface)
  text_fx_helper:draw_text_with_stroke(dst_surface, self.command_column_text, self.column_stroke_color)
  text_fx_helper:draw_text_with_stroke(dst_surface, self.keyboard_column_text, self.column_stroke_color)
  text_fx_helper:draw_text_with_stroke(dst_surface, self.joypad_column_text, self.column_stroke_color)
  self.commands_surface:draw_region(0, self.commands_visible_y, 208, 84, dst_surface)
  
  -- Arrows.
  if self.commands_visible_y > 0 then
    self.up_arrow_sprite:draw(dst_surface)
    self.up_arrow_sprite:draw(dst_surface, 115, 0)
  end
  
  if self.commands_visible_y < 60 then
    self.down_arrow_sprite:draw(dst_surface)
    self.down_arrow_sprite:draw(dst_surface, 115, 0)
  end
  
  -- Draw cursor (only when the save dialog is not open).
  if self.save_dialog_state == 0 then
    if self.waiting_for_command then
      -- Cursor when waiting for a command, in both cells (keyboard and joypad).
      self.command_cursor_sprite:draw(dst_surface, self.cursor_sprite.x + 65, self.cursor_sprite.y)
      self.command_cursor_sprite:draw(dst_surface, self.cursor_sprite.x + 141, self.cursor_sprite.y)
    else
      -- Normal cursor.
      self.cursor_sprite:draw(dst_surface, self.cursor_sprite.x, self.cursor_sprite.y)
    end
  end

  -- Draw save dialog if necessary.
  self:draw_save_dialog_if_any(dst_surface)
end

function options_submenu:on_command_pressed(command)

  if self.command_customizing ~= nil then
    -- We are customizing a command: any key pressed should have been handled before.
    error("options_submenu:on_command_pressed() should not called in this state")
  end

  local handled = submenu.on_command_pressed(self, command)
  local screen_w, screen_h = sol.video.get_quest_size()
  local resolution_list_w = {320, 256, 300, 320}
  local resolution_list_h = {240, 224, 240, 180}
  local resolution_list = {"320_240", "256_224", "300_240", "320_180"}
 

  if not handled then
    if command == "left" then
      self:previous_submenu()
      handled = true
    elseif command == "right" then
      self:next_submenu()
      handled = true
    elseif command == "up" then
      sol.audio.play_sound("menus/cursor")
      self:set_cursor_position((self.cursor_position + 8) % 10 + 1)
      handled = true
    elseif command == "down" then
      sol.audio.play_sound("menus/cursor")
      self:set_cursor_position(self.cursor_position % 10 + 1)
      handled = true
    elseif command == "action" then
      if self.cursor_position == 1 then
        -- Change the video mode
        self.current_video_mode_index = (((self.current_video_mode_index + 1) - 1) % 3) + 1
        effect_manager:set_effect(self.game, self.shader_effect_list[self.current_video_mode_index])
        self.game:set_value("mode", self.shader_effect_list_str[self.current_video_mode_index])
        sol.audio.play_sound("menus/option_modify_value")
        self:load_video_mode_texts()
      else
        -- Customize a game command.
        self:set_caption_key("options.caption.press_key")
        self.waiting_for_command = true
        local command_to_customize = self.command_names[self.cursor_position - 1]
        self.game:capture_command_binding(command_to_customize, function()
          self.waiting_for_command = false
          sol.audio.play_sound("menus/option_modify_value")
          self:set_caption_key("options.caption.press_action_customize_key")
          self:load_command_texts()
          -- TODO restore HUD icons.
        end)

        -- TODO grey over HUD icons, make the icon of the command blink.
      end
      handled = true
    end
  end

  return handled
end

return options_submenu