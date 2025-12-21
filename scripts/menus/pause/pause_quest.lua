local submenu = require("scripts/menus/pause/pause_submenu")
local language_manager = require("scripts/language_manager")
local text_fx_helper = require("scripts/text_fx_helper")
local quest_submenu = submenu:new()

local item_names_static_top = {
	"crystal_1",
	"crystal_7",
	"rupee_bag",
}
local item_names_static_left = {
	"crystal_2",
	"crystal_2", -- Triforce
	"crystal_6",
	"crystal_3",
	"crystal_4",
	"crystal_5",
	"pendant_1",
	"pendant_2",
	"pendant_3",
}
local item_names_static_right = {
	"monster_gut",
	"monster_claw",
	"monster_horn",
	"monster_tail",
	"goron_amber",
	"divine_ore",
}

local item_names_static_bottom = {
	"world_map",
	"world_map",
	"world_map",
}

local cell_size = 28
local cell_spacing = 4
local max_row, max_column = 4,7
local grid_coords_x, grid_coords_y = -120,-60
local sprite_origin_x, sprite_origin_y = 8,16
local cursor_origin_x, cursor_origin_y = 9,12
local cursor_sound = "menus/cursor"
local assign_sound = "throw"
local menu_name = "quest"

function quest_submenu:on_started()
	self.quest_items_surface = sol.surface.create(320, 240)
	submenu.on_started(self)
	self.cursor_sprite = sol.sprite.create("menus/pause/pause_cursor")
	self.hearts = sol.surface.create("menus/pause/quest/pieces_of_heart.png")
	self.counters = {}
	self.sprites_static_left = {}
	self.sprites_static_right = {}
	self.sprites_static_top = {}
	self.sprites_static_bottom = {}
	self.caption_text_keys = {}

	 local item_sprite = sol.sprite.create("entities/items")

	-- Set the title.
	self:set_title(sol.language.get_string("quest_status.title"))

	-- initialise the cursor.
	local index = self.game:get_value("pause_inventory_last_item_index") or 0
	local row = index % max_row
	local column = index % max_column
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
	for i,item_name in ipairs(item_names_static_top) do
		local item = self.game:get_item(item_name)
		local variant = item:get_variant()
		self.sprites_static_top[i] = sol.sprite.create("entities/items")
		self.sprites_static_top[i]:set_animation(item_name)
	end
	for i,item_name in ipairs(item_names_static_bottom) do
		local item = self.game:get_item(item_name)
		local variant = item:get_variant()
		self.sprites_static_bottom[i] = sol.sprite.create("entities/items")
		self.sprites_static_bottom[i]:set_animation(item_name)
	end
end

function quest_submenu:on_finished()
	-- Nothing.
end
-- #255
function quest_submenu:on_draw(dst_surface)

	local width, height = dst_surface:get_size()
	local center_x, center_y = width / 2, height / 2

	-- Draw the background.
	self:draw_background(dst_surface)
	
	-- Draw the cursor caption.
	self:draw_caption(dst_surface)
	self:draw_infos_text(dst_surface)

	-- Draw each inventory static item left.
	local x = center_x + grid_coords_x + sprite_origin_x
	local y = center_y + grid_coords_y + sprite_origin_y
	local k = 0

	for i = 0, 2 do
		for j = 0, 2 do
			k = k + 1
			local item = self.game:get_item(item_names_static_left[k])
			if item:get_variant() > 0 then
				-- The player has this item: draw it.
				if item_names_static_left[k] == "magnifying_lens" then
					self.sprites_static_left[k]:set_direction(item:get_variant() - 1)
				else
					self.sprites_static_left[k]:set_direction(item:get_variant() - 1)
				end
				self.sprites_static_left[k]:draw(dst_surface, x, y)
			end
			x = x + cell_size + cell_spacing
		end
		y = y + cell_size + cell_spacing
	end
	
	-- Draw each inventory static item right.
	local x = center_x + grid_coords_x + sprite_origin_x + 5 * (cell_size + cell_spacing)
	local y = center_y + grid_coords_y + sprite_origin_y
  local k = 0
  for i = 0, 2 do
		for j = 0, 2 do
			k = k + 1
			if item_names_static_right[k] ~= nil then
				local item = self.game:get_item(item_names_static_right[k])
				if item:get_variant() > 0 then
					-- The player has this item: draw it.
					if self.counters[k] ~= nil then
						if item:get_amount() > 0 then
							self.sprites_static_right[k]:set_direction(item:get_variant() - 1)
							self.sprites_static_right[k]:draw(dst_surface, x, y)
							self.counters[k]:draw(dst_surface, x + 8, y)
						end
					else
						self.sprites_static_right[k]:set_direction(item:get_variant() - 1)
						self.sprites_static_right[k]:draw(dst_surface, x, y)
					end
				end
			end
			x = x + cell_size + cell_spacing
		end
		y = y + cell_size + cell_spacing
  end

	-- Draw each inventory static item top.
	local x = center_x + grid_coords_x + sprite_origin_x 
	local y = center_y + grid_coords_y + sprite_origin_y + 3 * (cell_size + cell_spacing)
	local k = 0
	for i = 0, 2 do
		k = k + 1
		if item_names_static_top[k] ~= nil then
			local item = self.game:get_item(item_names_static_top[k])
			if item:get_variant() > 0 then
				-- The player has this item: draw it.
					x = center_x + grid_coords_x + sprite_origin_x + i * (cell_size + cell_spacing)
				self.sprites_static_top[k]:set_direction(item:get_variant() - 1)
				self.sprites_static_top[k]:draw(dst_surface, x, y)
			end
		end
		x = x + cell_size + cell_spacing
	end

	-- Draw each inventory static item bottom.
	local x = center_x + grid_coords_x + sprite_origin_x + 5 * (cell_size + cell_spacing)
	local y = center_y + grid_coords_y + sprite_origin_y + 3 * (cell_size + cell_spacing)
	local k = 0
	for i = 0, 2 do
		k = k + 1
		if item_names_static_top[k] ~= nil then
			local item = self.game:get_item(item_names_static_top[k])
			if item:get_variant() > 0 then
				-- The player has this item: draw it.
					x = center_x + grid_coords_x + sprite_origin_x + i * (cell_size + cell_spacing)
				self.sprites_static_top[k]:set_direction(item:get_variant() - 1)
				self.sprites_static_top[k]:draw(dst_surface, x, y)
			end
		end
		x = x + cell_size + cell_spacing
	end

	-- Pieces of heart.
	local num_pieces_of_heart = self.game:get_item("piece_of_heart"):get_num_pieces_of_heart()
	local pieces_of_heart_w = 28
	local pieces_of_heart_x = pieces_of_heart_w * num_pieces_of_heart
	self.hearts:draw_region(
		pieces_of_heart_x, 0,                 -- region position in image
		pieces_of_heart_w, pieces_of_heart_w, -- region size in image
		dst_surface,                          -- destination surface
		center_x - 13, center_y + 47          -- position in destination surface -- TODO check
	)
	
-- Game time.
	local menu_font, menu_font_size = language_manager:get_menu_font()
	self.chronometer_txt = sol.text_surface.create({
		horizontal_alignment = "center",
		vertical_alignment = "bottom",
		font = menu_font,
		font_size = menu_font_size,
		color = { 224, 224, 224 },
		text_stroke_color = { 115, 59, 22 },
		text = self.game:get_time_played_string()
	})
	
	sol.timer.start(self.game, 1000, function()
		self.chronometer_txt:set_text(self.game:get_time_played_string())
		return true  -- Repeat the timer.
	end)

	-- Draw cursor only when the save dialog is not displayed.
	if self.save_dialog_state == 0 then
		self.cursor_sprite:draw(dst_surface,
		center_x + grid_coords_x + cursor_origin_x + (cell_size + cell_spacing) * self.cursor_column,
		center_y + grid_coords_y + cursor_origin_y + (cell_size + cell_spacing) * self.cursor_row)
	end

	-- Draw save dialog if necessary.
	self:draw_save_dialog_if_any(dst_surface)
end

function quest_submenu:on_command_pressed(command)
	
	local handled = submenu.on_command_pressed(self, command)

	if not handled then

		if command == "action" then
			if self.game:get_command_effect("action") == nil and self.game:get_custom_command_effect("action") == "info" then
				self:show_info_message()
				handled = true
			end

		elseif command == "left" then
			if self.cursor_column == 0 then
				self:previous_submenu()
			else
				sol.audio.play_sound("menus/cursor")
				if self.cursor_column == 2 and self.cursor_row == 0 then
					self:set_cursor_position(self.cursor_row, self.cursor_column - 2)
				elseif self.cursor_column == 5 and self.cursor_row == 0 then
					self:set_cursor_position(self.cursor_row, self.cursor_column - 3)
				elseif self.cursor_column == 4 and self.cursor_row == 1 then
					self:set_cursor_position(self.cursor_row, self.cursor_column - 2)
				elseif self.cursor_column == 4 and self.cursor_row == 2 then
					self:set_cursor_position(self.cursor_row, self.cursor_column - 2)
				else
					self:set_cursor_position(self.cursor_row, self.cursor_column - 1)
				end
			end
			handled = true

		elseif command == "right" then
			if self.cursor_column == 5 and self.cursor_row == 0
					or self.cursor_column == max_column - 1 and  self.cursor_row == 1
					or self.cursor_column == max_column - 1 and  self.cursor_row == 2 
					or self.cursor_column == max_column - 1 and  self.cursor_row == 3  then
				self:next_submenu()
			else
				sol.audio.play_sound("menus/cursor")
				if self.cursor_column == 0 and self.cursor_row == 0 then
					self:set_cursor_position(self.cursor_row, self.cursor_column + 2)
				elseif self.cursor_column == 2 and self.cursor_row == 0 then
					self:set_cursor_position(self.cursor_row, self.cursor_column + 3)
				elseif self.cursor_column == 2 and self.cursor_row == 1 then
					self:set_cursor_position(self.cursor_row, self.cursor_column + 2)
				elseif self.cursor_column == 2 and self.cursor_row == 2 then
					self:set_cursor_position(self.cursor_row, self.cursor_column + 2)
				else
					self:set_cursor_position(self.cursor_row, self.cursor_column + 1)
				end
			end
			handled = true

		elseif command == "up" then
			if self.cursor_column ~= 3 then
				sol.audio.play_sound("menus/cursor")
				if self.cursor_column == 1 and self.cursor_row == 1
					or self.cursor_column == 4 and self.cursor_row == 1
					or self.cursor_column == 6 and self.cursor_row == 1 then
					self:set_cursor_position((self.cursor_row + 2) % max_row, self.cursor_column)
				else
					self:set_cursor_position((self.cursor_row + 3) % max_row, self.cursor_column)
				end
			end
			handled = true

		elseif command == "down" then
			if self.cursor_column ~= 3 then
				sol.audio.play_sound("menus/cursor")
				if self.cursor_column == 1 and self.cursor_row == max_row - 1
					or self.cursor_column == 4 and self.cursor_row == max_row - 1
					or self.cursor_column == 6 and self.cursor_row == max_row - 1 then
					self:set_cursor_position((self.cursor_row - 2) % max_row, self.cursor_column)
				else
					self:set_cursor_position((self.cursor_row + 1) % max_row, self.cursor_column)
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
	self.game:set_custom_command_effect("action", nil)
	self.game:set_custom_command_effect("attack", nil)
	if item_name == "piece_of_heart" then
		dialog_id =  "scripts.menus.pause_inventory.piece_of_heart.1" 
	elseif item_name == "monster_claw_counter" then
		local item = item_name and self.game:get_item(item_name) or nil
		if item:get_amount() > 0 then
			dialog_id =  "scripts.menus.pause_inventory.monster_claw_counter.1" 
		end
	elseif item_name == "monster_gut_counter" then
		local item = item_name and self.game:get_item(item_name) or nil
		if item:get_amount() > 0 then
			dialog_id =  "scripts.menus.pause_inventory.monster_gut_counter.1" 
		end
	elseif item_name == "monster_horn_counter" then
		local item = item_name and self.game:get_item(item_name) or nil
		if item:get_amount() > 0 then
			dialog_id =  "scripts.menus.pause_inventory.monster_horn_counter.1" 
		end
	elseif item_name == "monster_tail_counter" then
		local item = item_name and self.game:get_item(item_name) or nil
		if item:get_amount() > 0 then
			dialog_id =  "scripts.menus.pause_inventory.monster_tail_counter.1" 
		end
	elseif item_name == "goron_amber_counter" then
		local item = item_name and self.game:get_item(item_name) or nil
		if item:get_amount() > 0 then
			dialog_id =  "scripts.menus.pause_inventory.goron_amber_counter.1" 
		end
	else
		local variant = self.game:get_item(item_name):get_variant()
		dialog_id = "scripts.menus.pause_inventory." .. item_name .. "." .. variant
	end
	if dialog_id then
		game:start_dialog(dialog_id, function()
			self.game:set_custom_command_effect("action", "info")
			self.game:set_custom_command_effect("attack", "save")
		 -- game:set_dialog_position("auto")  -- Back to automatic position.
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
			--[[
	elseif item_name =="goron_amber" then
		local item = item_name and self.game:get_item(item_name) or nil
		if item:get_amount() > 0 then
			self:set_caption_key("inventory.caption.item.goron_amber.1")
			self.game:set_custom_command_effect("action", "info")
		end
	elseif item_name =="monster_claw_counter" then
		local item = item_name and self.game:get_item(item_name) or nil
		if item:get_amount() > 0 then
			self:set_caption_key("inventory.caption.item.monster_claw_counter.1")
			self.game:set_custom_command_effect("action", "info")
		end
	elseif item_name =="monster_gut_counter" then
		local item = item_name and self.game:get_item(item_name) or nil
		if item:get_amount() > 0 then
			self:set_caption_key("inventory.caption.item.monster_gut_counter.1")
			self.game:set_custom_command_effect("action", "info")
	 end
	elseif item_name =="monster_horn_counter" then
		local item = item_name and self.game:get_item(item_name) or nil
		if item:get_amount() > 0 then
			self:set_caption_key("inventory.caption.item.monster_horn_counter.1")
			self.game:set_custom_command_effect("action", "info")
	 end
	elseif item_name =="monster_tail_counter" then
		local item = item_name and self.game:get_item(item_name) or nil
		if item:get_amount() > 0 then
			self:set_caption_key("inventory.caption.item.monster_tail_counter.1")
			self.game:set_custom_command_effect("action", "info")
	 end--]]
	else
		local item = item_name and self.game:get_item(item_name) or nil
		local variant = item and item:get_variant()
		local item_icon_opacity = 128
		if variant > 0 then
		self:set_caption_key("inventory.caption.item." .. item_name .. "." .. variant)
		self:set_infos_key("scripts.menus.pause_inventory." .. item_name .. "." .. variant)
			self.game:set_custom_command_effect("action", "info")
			if item:is_assignable() then
				self.game:set_hud_mode("normal")
			else
				self.game:set_hud_mode("pause")
			end
		else
		self:set_caption(nil)
		self:set_infos_text(nil)
			self.game:set_custom_command_effect("action", nil)
			self.game:set_hud_mode("pause")
		end
	end
end

function quest_submenu:get_item_name(row, column)

		if column < 3 and row > 0 then
			index = ((row + 2) % 3) * 3 + column
			item_name = item_names_static_left[index + 1]
		elseif column > 3 and (row > 0 and row < 3) then
			index = ((row + 2) % 3) * 3 + ((column + 2) % 3)
			item_name = item_names_static_right[index + 1]
		elseif column == 0 and row == 0 then
			item_name = "crystal_1"
		elseif column == 2 and row == 0 then
			item_name = "crystal_7"
		elseif column == 5 and row == 0 then
			item_name = "rupee_bag"
		elseif column == 3 and row == 3 then
			item_name = "piece_of_heart"
		elseif column == 4 and row == 3 then
			item_name = "world_map"
		elseif column == 5 and row == 3 then
			item_name = "world_map"
		elseif column == 6 and row == 3 then
			item_name = "world_map"
		end

	return item_name
end

return quest_submenu