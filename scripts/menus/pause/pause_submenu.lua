-- Base class of each submenu.

local submenu = {}

local language_manager = require("scripts/language_manager")
local messagebox = require("scripts/menus/messagebox")
local text_fx_helper = require("scripts/text_fx_helper")
local audio_manager = require("scripts/audio_manager")

function submenu:new(game)

	local o = { game = game }
	setmetatable(o, self)
	self.__index = self
	return o
end

function submenu:on_started()

	sol.menu.bring_to_front(submenu)
	self.background_surfaces = sol.surface.create("menus/pause/pause_submenus.png")
	local img_width, img_height = self.background_surfaces:get_size()
	self.width, self.height = img_width / 4, img_height
	self.title_arrows = sol.surface.create("menus/pause/submenus_arrows.png")
	self.caption_background = sol.surface.create("menus/pause/submenus_caption.png")
	self.caption_background_w, self.caption_background_h = self.caption_background:get_size()
	self.save_dialog_background = sol.surface.create("menus/pause/dialog_background.png")
	self.save_dialog_cursor = sol.sprite.create("menus/pause/dialog_cursor")
	self.save_dialog_cursor_pos = "left"
	self.save_dialog_state = 0
	self.text_color = { 40, 40, 40 }

	-- Fix the font shift (issue with some fonts)
	self.font_y_shift = 0

	-- Dark surface whose goal is to slightly hide the game and better highlight the menu.
	local quest_w, quest_h = sol.video.get_quest_size()
	self.dark_surface = sol.surface.create(quest_w, quest_h)
	self.dark_surface:fill_color({180, 180, 180})
	self.dark_surface:set_blend_mode("multiply")

	local menu_font, menu_font_size = language_manager:get_menu_font()

	-- Create save dialog texts.
	self.question_text_1 = sol.text_surface.create{
		horizontal_alignment = "center",
		vertical_alignment = "middle",
		color = self.text_color,
		font = menu_font,
		font_size = menu_font_size,
	}
	self.question_text_2 = sol.text_surface.create{
		horizontal_alignment = "center",
		vertical_alignment = "middle",
		color = self.text_color,
		font = menu_font,
		font_size = menu_font_size,
	}
	self.answer_text_1 = sol.text_surface.create{
		horizontal_alignment = "center",
		vertical_alignment = "middle",
		color = self.text_color,
		text_key = "save_dialog.yes",
		font = menu_font,
		font_size = menu_font_size,
	}
	self.answer_text_2 = sol.text_surface.create{
		horizontal_alignment = "center",
		vertical_alignment = "middle",
		color = self.text_color,
		text_key = "save_dialog.no",
		font = menu_font,
		font_size = menu_font_size,
	}

	-- Create captions.
	local menu_font, menu_font_size = language_manager:get_menu_font()
	self.font_size = menu_font_size
	self.text_color = { 224, 224, 224 }
	self.text_stroke_color = {52, 52, 140}
	self.caption_text_1 = sol.text_surface.create{
		horizontal_alignment = "center",
		vertical_alignment = "middle",
		font = menu_font,
		font_size = menu_font_size,
		color = self.text_color,
	}
	self.caption_text_2 = sol.text_surface.create{
		horizontal_alignment = "center",
		vertical_alignment = "middle",
		font = menu_font,
		font_size = menu_font_size,
		color = self.text_color,
	}

	-- Create title.
	self.title = ""
	self.title_text = sol.text_surface.create{
		horizontal_alignment = "center",
		vertical_alignment = "middle",
		font = menu_font,
		font_size = menu_font_size,
		color = {224, 224, 224},
	}
	self.title_stroke_color = {72, 72, 72}
	self.title_shadow_color = {40, 40, 40}
	self.title_surface = sol.surface.create(128, 32)

	self.game:set_custom_command_effect("action", nil)
	self.game:set_custom_command_effect("attack", "save")
end

-- Sets the caption text key.
function submenu:set_caption_key(text_key)
	if text_key == nil then
		self:set_caption(nil)
	else
		local text = sol.language.get_string(text_key)
		self:set_caption(text)
	end
end

-- Sets the caption text.
-- The caption text can have one or two lines, with 20 characters maximum for each line.
-- If the text you want to display has two lines, use the '$' character to separate them.
-- A value of nil removes the previous caption if any.
function submenu:set_caption(text)
	if text == nil then
		self.caption_text_1:set_text(nil)
		self.caption_text_2:set_text(nil)
	else
		local line1, line2 = text:match("([^$]+)%$(.*)")
		if line1 == nil then
			-- Only one line.
			self.caption_text_1:set_text(text)
			self.caption_text_2:set_text(nil)
		else
			-- Two lines.
			self.caption_text_1:set_text(line1)
			self.caption_text_2:set_text(line2)
		end
	end
end

-- Draw the caption text previously set.
function submenu:draw_caption(dst_surface)
	-- Draw only if save dialog is not displayed.
	if not self.dialog_opened then
		local width, height = dst_surface:get_size()
		local center_x, center_y = width / 2, height / 2

		-- Draw caption frame (unused).
		local caption_x, caption_y = center_x - self.caption_background_w / 2, center_y + self.height / 2 - self.caption_background_h
		caption_y = math.min(caption_y, height - 8 - self.caption_background_h)
		-- self.caption_background:draw(dst_surface, caption_x, caption_y)
		local caption_center_y = caption_y + self.caption_background_h / 2

		-- Draw caption text.
		if self.caption_text_2:get_text():len() == 0 then
			-- If only one line, center vertically the only line.
			self.caption_text_1:set_xy(center_x, caption_center_y - 2 + self.font_y_shift)
			text_fx_helper:draw_text_with_stroke(dst_surface, self.caption_text_1, self.text_stroke_color)
		else
			-- If two lines.
			local line_spacing = 0 --self.font_size / 2 + 2

			self.caption_text_1:set_xy(center_x, caption_center_y - self.font_size)
			self.caption_text_2:set_xy(center_x, caption_center_y + line_spacing)

			text_fx_helper:draw_text_with_stroke(dst_surface, self.caption_text_1, self.text_stroke_color)
			text_fx_helper:draw_text_with_stroke(dst_surface, self.caption_text_2, self.text_stroke_color)

		end
	end
end


function submenu:next_submenu()

	sol.audio.play_sound("menus/dir_right")
	sol.menu.stop(self)
	local submenus = self.game.pause_submenus
	local submenu_index = self.game:get_value("pause_last_submenu")
	submenu_index = (submenu_index % #submenus) + 1
	self.game:set_value("pause_last_submenu", submenu_index)
	sol.menu.start(self.game.pause_menu, submenus[submenu_index], false)
end

function submenu:previous_submenu()

	sol.audio.play_sound("menus/dir_left")
	sol.menu.stop(self)
	local submenus = self.game.pause_submenus
	local submenu_index = self.game:get_value("pause_last_submenu")
	submenu_index = (submenu_index + #submenus - 2) % #submenus + 1
	self.game:set_value("pause_last_submenu", submenu_index)
	sol.menu.start(self.game.pause_menu, submenus[submenu_index], false)
end

function submenu:on_command_pressed(command)

	local handled = false

	if self.game:is_dialog_enabled() then
		-- Commands will be applied to the dialog box only.
		return false
	end

	if self.save_dialog_state == 0 then
		-- The save dialog is not shown
		if command == "attack" then
			sol.audio.play_sound("common/dialog/message_end")
			self.save_dialog_state = 1
			self.save_dialog_choice = 0
			self.save_dialog_cursor_pos = "left"
			self.question_text_1:set_text_key("save_dialog.save_question_0")
			self.question_text_2:set_text_key("save_dialog.save_question_1")
			self.action_command_effect_saved = self.game:get_custom_command_effect("action")
			self.game:set_custom_command_effect("action", "validate")
			self.attack_command_effect_saved = self.game:get_custom_command_effect("attack")
			self.game:set_custom_command_effect("attack", "validate")
			handled = true
		end
	else
		-- The save dialog is visible.
		if command ~= "pause" then
			handled = true  -- Block all commands on the submenu except pause.
		end

		if command == "left" or command == "right" then
			-- Move the cursor.
			sol.audio.play_sound("cursor")
			if self.save_dialog_choice == 0 then
				self.save_dialog_choice = 1
				self.save_dialog_cursor_pos = "right"
			else
				self.save_dialog_choice = 0
				self.save_dialog_cursor_pos = "left"
			end
		elseif command == "action" or command == "attack" then
			-- Validate a choice.
			if self.save_dialog_state == 1 then
				-- After "Do you want to save?".
				self.save_dialog_state = 2
				if self.save_dialog_choice == 0 then
					self.game:set_value("savegame_version", "1.17")
					self.game:set_value("time_saved", os.date("%d/%m/%Y %H:%M", os.time()))
					self.game:save()
					sol.audio.play_sound("menus/select")
				else
					sol.audio.play_sound("menus/danger")
				end
				self.question_text_1:set_text_key("save_dialog.continue_question_0")
				self.question_text_2:set_text_key("save_dialog.continue_question_1")
				self.save_dialog_choice = 0
				self.save_dialog_cursor_pos = "left"
			else
				-- After "Do you want to continue?".
				sol.audio.play_sound("menus/select")
				self.save_dialog_state = 0
				self.game:set_custom_command_effect("action", self.action_command_effect_saved)
				self.game:set_custom_command_effect("attack", self.attack_command_effect_saved)
				if self.save_dialog_choice == 1 then
					sol.main.reset()
				end
			end
		end
	end

	return handled
end

function submenu:draw_background(dst_surface)
  local width, height = dst_surface:get_size()
  local center_x = width / 2
  local center_y = height / 2
  local menu_x, menu_y = center_x - self.width / 2, center_y - self.height / 2
	local title_w, title_h = self.title_surface:get_size()
	local title_x, title_y = center_x - title_w / 2, menu_y + 32

	-- Fill the screen with a dark surface.
	self.dark_surface:draw(dst_surface)

	-- Draw the menu GUI window and the title (in the correct language)
	local submenu_index = self.game:get_value("pause_last_submenu")
	local submenu_background_column = ((submenu_index - 1) % 3)
	local submenu_background_row = math.ceil(submenu_index / 3) - 1

	self.background_surfaces:draw_region(
			320 * submenu_background_column, 240 * submenu_background_row,           -- region x, y
			320, 240,                               -- region w, h
			dst_surface,                            -- destination surface
			(width - 320) / 2, (height - 240) / 2   -- pos in destination surface
	)

	
	-- Draw only if save dialog is not displayed.
	if self.save_dialog_state == 0 then
		-- Draw arrows on both sides of the menu title
		self.title_surface:draw(dst_surface, title_x, 32)
		self.title_arrows:draw_region(0, 0, 14, 12, dst_surface, center_x - 71, center_y - 80)
		self.title_arrows:draw_region(14, 0, 14, 12, dst_surface, center_x + 57, center_y - 80)
	end
end

function submenu:draw_save_dialog_if_any(dst_surface)

	if self.save_dialog_state > 0 then
		local width, height = dst_surface:get_size()
		local center_x = width / 2
		local center_y = height / 2
		local frame_w = 224
		local frame_h = 72
		local frame_half_w  = frame_w / 2
		local frame_half_h = frame_h / 2

		-- A dark surface to better highlight the dialog
		self.dark_surface:draw(dst_surface)

		-- Draw the dialog frame.
		self.save_dialog_background:draw(dst_surface, center_x - frame_half_w, center_y - frame_half_h)

		-- Draw the dialog question.
		self.question_text_1:draw(dst_surface, center_x, center_y - 20) -- line 1
		self.question_text_2:draw(dst_surface, center_x, center_y - 8) -- line 2

		-- Draw the dialog answers (yes/no).
		self.answer_text_1:draw(dst_surface, center_x - 56, center_y + 19)
		self.answer_text_2:draw(dst_surface, center_x + 56, center_y + 19)

		-- Draw the dialog cursor.
		if self.save_dialog_cursor_pos == "left" then
			self.save_dialog_cursor:draw(dst_surface, center_x - 80, center_y + 20)
		elseif self.save_dialog_cursor_pos == "right" then
			self.save_dialog_cursor:draw(dst_surface, center_x + 32, center_y + 20)
		end
	end
end

function submenu:set_title(text)
	if text ~= self.title then
		self.title = text
		self:rebuild_title_surface()
	end
end

function submenu:rebuild_title_surface()
	self.title_surface:clear()
	local w, h = self.title_surface:get_size()
	self.title_text:set_text(self.title)
	self.title_text:set_xy(w / 2, h / 2 - 2)
	text_fx_helper:draw_text_with_stroke_and_shadow(self.title_surface, self.title_text, self.title_stroke_color, self.title_shadow_color)
end

return submenu