local submenu = require("scripts/menus/pause/pause_submenu")
local inventory_submenu = submenu:new()
local item_names_assignable_top = { -- top
  "song_1_forest",
	"song_2_fire",
  "song_3_water",
  "song_4_spirit",
	"song_5_lorule",
  "song_8_shadow",
  "song_10_zelda",
	"song_11_time",
  "song_12_secret",
	"song_13_light",
	"song_14_storms",
	"song_15_sun",
	"song_6_epona",
		"_placeholder",
}

local item_names_assignable_bottom = { -- bottom
	"_placeholder",										
	"_placeholder",
		"_placeholder",										
	"_placeholder",
		"_placeholder",										
	"_placeholder",
}

local item_names_static = {
	"_placeholder",										
	"_placeholder",
	"_placeholder",										
	"_placeholder",
}

local cell_size = 28
local cell_spacing = 4
local max_row, max_column = 3,7
local min_row_top, min_column_top = 0, 1
local max_row_top, max_column_top = 1, 7
local min_row_bottom, min_column_bottom = 2, 1
local max_row_bottom, max_column_bottom = 3, 3
local grid_coords_x, grid_coords_y = -120,-60
local sprite_origin_x, sprite_origin_y = 8,16
local cursor_origin_x, cursor_origin_y = 9,12
local cursor_sound = "menus/cursor"
local assign_sound = "throw"
local menu_name = "ocarina"
local digits_font = "green_digits" or "white_digits"

function inventory_submenu:on_started()
	submenu.on_started(self)
	self.cursor_sprite = sol.sprite.create("menus/pause/pause_cursor")
	self.sprites_assignables_top = {}
	self.sprites_assignables_bottom = {}
	self.sprites_static = {}
	self.captions = {}
	self.counters_top = {}
	self.counters_bottom = {}
	self.menu_ocarina = true

	-- Set the title.
	self:set_title(sol.language.get_string("inventory.title_"..menu_name))

	-- Initialise the cursor
	local index = self.game:get_value("pause_inventory_last_item_index") or 0
	local row = index % max_row
	local column = index % max_column
	self:set_cursor_position(row, column)

	-- Load Items
	for i,item_name in ipairs(item_names_assignable_top) do
		local item = self.game:get_item(item_name)
		local variant = item:get_variant()
		self.sprites_assignables_top[i] = sol.sprite.create("entities/items")
		self.sprites_assignables_top[i]:set_animation(item_name)
		if item:has_amount() then
			-- Show a counter in this case.
			local amount = item:get_amount()
			local maximum = item:get_max_amount()
			self.counters_top[i] = sol.text_surface.create{
				horizontal_alignment = "center",
				vertical_alignment = "top",
				text = item:get_amount(),
				font = (amount == maximum) and digits_font,
			}
		end
	end

	for i,item_name in ipairs(item_names_assignable_bottom) do
		local item = self.game:get_item(item_name)
		local variant = item:get_variant()
		self.sprites_assignables_bottom[i] = sol.sprite.create("entities/items")
		self.sprites_assignables_bottom[i]:set_animation(item_name)
		if item:has_amount() then
			-- Show a counter in this case.
			local amount = item:get_amount()
			local maximum = item:get_max_amount()
			self.counters_bottom[i] = sol.text_surface.create{
				horizontal_alignment = "center",
				vertical_alignment = "top",
				text = item:get_amount(),
				font = (amount == maximum) and digits_font,
			}
		end
	end

	for i,item_name in ipairs(item_names_static) do
		local item = self.game:get_item(item_name)
		local variant = item:get_variant()
		self.sprites_static[i] = sol.sprite.create("entities/items")
		self.sprites_static[i]:set_animation(item_name)
	end
end

function inventory_submenu:on_finished()
	if inventory_submenu:is_assigning_item() then
		inventory_submenu:finish_assigning_item()
	end
	-- Nothing.
end
-- #255
function inventory_submenu:on_draw(dst_surface)

	local width, height = dst_surface:get_size()
	local center_x, center_y = width / 2, height / 2

	-- Draw the background.
	self:draw_background(dst_surface)
	
	-- Draw the cursor caption.
	self:draw_caption(dst_surface)
	self:draw_infos_text(dst_surface)

	-- Draw each inventory static item.
	local x = center_x + grid_coords_x + sprite_origin_x
	local y = center_y + grid_coords_y + sprite_origin_y
	local k = 0

	for j = 0, max_row do
		k = k + 1
		local item = self.game:get_item(item_names_static[k])
		if item:get_variant() > 0 then
			-- The player has this item: draw it.
			self.sprites_static[k]:set_direction(item:get_variant() - 1)
			self.sprites_static[k]:draw(dst_surface, x, y)
		end
		-- Next item position (they are on the same column).
		y = y + cell_size + cell_spacing
	end

	-- Draw each inventory assignable item.
	local x = center_x + grid_coords_x + sprite_origin_x
	local y = center_y + grid_coords_y + sprite_origin_y + min_row_top * (cell_size + cell_spacing)
	local k = 0

	for j = min_row_top, max_row_top do
		local x = center_x + grid_coords_x + sprite_origin_x + min_column_top * (cell_size + cell_spacing)
		for i = min_column_top, max_column_top do
			k = k + 1
			if item_names_assignable_top[k] ~= nil then
				local item = self.game:get_item(item_names_assignable_top[k])
				if item:get_variant() >= 1 then
					-- The player has this item: draw it.
					self.sprites_assignables_top[k]:set_direction(item:get_variant() - 1)
					self.sprites_assignables_top[k]:draw(dst_surface, x, y)
					if self.counters_top[k] ~= nil then
						self.counters_top[k]:draw(dst_surface, x, y)
					end
				end
			end
			x = x + cell_size + cell_spacing
		end
		y = y + cell_size + cell_spacing
	end
	
	local x = center_x + grid_coords_x + sprite_origin_x
	local y = center_y + grid_coords_y + sprite_origin_y + min_row_bottom * (cell_size + cell_spacing)
	local k = 0
	for j = min_row_bottom, max_row_bottom do
		local x = center_x + grid_coords_x + sprite_origin_x + min_column_bottom * (cell_size + cell_spacing)
		for i = min_column_bottom, max_column_bottom do
			k = k + 1
			if item_names_assignable_bottom[k] ~= nil then
				local item = self.game:get_item(item_names_assignable_bottom[k])
				if item:get_variant() >= 1 then
					-- The player has this item: draw it.
					self.sprites_assignables_bottom[k]:set_direction(item:get_variant() - 1)
					self.sprites_assignables_bottom[k]:draw(dst_surface, x, y)
					if self.counters_bottom[k] ~= nil then
						self.counters_bottom[k]:draw(dst_surface, x, y)
					end
				end
			end
			x = x + cell_size + cell_spacing
		end
		y = y + cell_size + cell_spacing
	end

	-- Draw cursor only when the save dialog is not displayed.
	if self.save_dialog_state == 0 then
		self.cursor_sprite:draw(dst_surface,
		center_x + grid_coords_x + cursor_origin_x + (cell_size + cell_spacing) * self.cursor_column,
		center_y + grid_coords_y + cursor_origin_y + (cell_size + cell_spacing) * self.cursor_row)
	end

	-- Draw the item being assigned if any.
	if self:is_assigning_item() then
		self.item_assigned_sprite:draw(dst_surface)
	end

	-- Draw the save dialog if necessary.
	self:draw_save_dialog_if_any(dst_surface)
end

-- CURSOR MOVEMENTS
function inventory_submenu:on_command_pressed(command)
	
	local handled = submenu.on_command_pressed(self, command)

	if not handled then

		if command == "action"  then
			if self.game:get_command_effect("action") == nil and self.game:get_custom_command_effect("action") == "info" then
				--self:show_info_message()
				handled = true
			end

		elseif command == "item_1" then
			if self:is_item_selected() or (self.cursor_row == 0 and self.cursor_column > 4)  then
				self:assign_item(1)
				handled = true
			end
		elseif command == "item_2" then
			if self:is_item_selected()  or (self.cursor_row == 0 and self.cursor_column > 4) then
				self:assign_item(2)
				handled = true
			end
		elseif command == "left"  then
			if self.cursor_column == 0
			 then
				self:previous_submenu()
			else
				sol.audio.play_sound(cursor_sound)
				self:set_cursor_position(self.cursor_row, self.cursor_column - 1)
			end
			handled = true

		elseif command == "right"  then
			local limit = max_column
			if self.cursor_column == limit
				or (self.cursor_column == max_column_top and self.cursor_row < max_row_top + 1)
			 then
				self:next_submenu()
			elseif 
				(self.cursor_column < max_column_top and self.cursor_row < max_row_top + 1)
				or (self.cursor_column < max_column_bottom and self.cursor_row > min_row_bottom - 1)
				then
				sol.audio.play_sound(cursor_sound)
				self:set_cursor_position(self.cursor_row, self.cursor_column + 1)			
			end
			handled = true

		elseif command == "up" and self.cursor_column < max_column + 1 then
			sol.audio.play_sound(cursor_sound)
			self:set_cursor_position((self.cursor_row - 1) % (max_row + 1), self.cursor_column)
			handled = true

		elseif command == "down" then
			if (self.cursor_column < max_column_bottom + 1)
			or (self.cursor_column < max_column_top + 1 and self.cursor_row < max_row_top)
			then
				sol.audio.play_sound(cursor_sound)
				self:set_cursor_position((self.cursor_row + 1) % (max_row + 1), self.cursor_column)
				handled = true
			end
		end
	end

	return handled

end

-- Shows a message describing the item currently selected.
-- The player is supposed to have this item.
function inventory_submenu:show_info_message()

	local item_name = self:get_item_name(self.cursor_row, self.cursor_column)
	local variant = self.game:get_item(item_name):get_variant()
	local game = self.game
	local map = game:get_map()


	self.game:set_custom_command_effect("action", nil)
	self.game:set_custom_command_effect("attack", nil)
	game:start_dialog("scripts.menus.pause_inventory." .. item_name .. "." .. variant, function()
		self.game:set_custom_command_effect("action", "info")
		self.game:set_custom_command_effect("attack", "save")
	end)

end

function inventory_submenu:set_cursor_position(row, column)

	self.cursor_row = row
	self.cursor_column = column
	local index
	local item_name
	self.game:set_value("pause_inventory_last_item_index", index)

	-- Update the caption text and the action icon.
	local item_name = self:get_item_name(row, column)
	local item = item_name and self.game:get_item(item_name) or nil
	local variant = item and item:get_variant()
	local item_icon_opacity = 128
	if variant > 0 then
		self:set_caption_key("inventory.caption.item." .. item_name .. "." .. variant)
		self:set_infos_key("scripts.menus.pause_inventory." .. item_name .. "." .. variant)
		self.game:set_custom_command_effect("action", "info")
    if item:is_assignable() then
      self.game:set_hud_mode("pause_assign")
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

function inventory_submenu:get_item_name(row, column)

	if (column > 0 and column < max_column_top + 1) and (row==0 or row == 1) then
			index = row * (max_column_top) + column - 1
			item_name = item_names_assignable_top[index + 1]
	elseif (column > 0 and column < max_column_bottom + 1) and (row==2 or row == 3) then
			index = (row - 2) * (max_column_bottom) + column - 1
			item_name = item_names_assignable_bottom[index + 1]
		elseif column == 0 then
			index = row 
			item_name = item_names_static[index + 1]
	end

	return item_name

end

function inventory_submenu:is_item_selected()

	local item_name = self:get_item_name(self.cursor_row, self.cursor_column)

	return self.game:get_item(item_name):get_variant() > 0

end


-- Assigns the selected item to a slot (1 or 2).
-- The operation does not take effect immediately: the item picture is thrown to
-- its destination icon, then the assignment is done.
-- Nothing is done if the item is not assignable.
function inventory_submenu:assign_item(slot)

	local item_name = self:get_item_name(self.cursor_row, self.cursor_column)
	local item = self.game:get_item(item_name)
	local assignable = false

	-- If this item is not assignable, do nothing.
	if not item:is_assignable() then
		return
	end
	-- If another item is being assigned, finish it immediately.
	if self:is_assigning_item() then
		self:finish_assigning_item()
	end
		assignable = true

	if assignable then
		-- Memorize this item.
			self.item_assigned = item
			self.item_assigned_sprite = sol.sprite.create("entities/items")
			self.item_assigned_sprite:set_animation(item_name)
			self.item_assigned_sprite:set_direction(item:get_variant() - 1)
			self.item_assigned_destination = slot

			-- Play the sound.
			sol.audio.play_sound(assign_sound)

			local screen_w, screen_h = sol.video.get_quest_size()
			local center_x, center_y = screen_w / 2, screen_h / 2

			-- Compute the movement.

			local x1 = center_x + grid_coords_x + cursor_origin_x + (cell_size + cell_spacing) * self.cursor_column
			local y1 = center_y + grid_coords_y + cursor_origin_y + (cell_size + cell_spacing) * self.cursor_row

			local x2 = (slot == 1) and (screen_w - 76) or (screen_w - 28) + 16
			local y2 = 4 + 16

			self.item_assigned_sprite:set_xy(x1, y1)
			local movement = sol.movement.create("target")
			movement:set_target(x2, y2)
			movement:set_speed(300)
			movement:start(self.item_assigned_sprite, function()
				self:finish_assigning_item()
			end)
	end

end

-- Returns whether an item is currently being thrown to an icon.
function inventory_submenu:is_assigning_item()

	return self.item_assigned_sprite ~= nil

end

-- Stops assigning the item right now.
-- This function is called when we want to assign the item without
-- waiting for its throwing movement to end, for example when the inventory submenu
-- is being closed.
function inventory_submenu:finish_assigning_item()

	-- If the item to assign is already assigned to the other icon, switch both items.
	local slot = self.item_assigned_destination
	local current_item = self.game:get_item_assigned(slot)
	local other_item = self.game:get_item_assigned(3 - slot)

	if other_item == self.item_assigned then
		self.game:set_item_assigned(3 - slot, current_item)
	end
	self.game:set_item_assigned(slot, self.item_assigned)

	self.item_assigned_sprite:stop_movement()
	self.item_assigned_sprite = nil
	self.item_assigned = nil

end


return inventory_submenu