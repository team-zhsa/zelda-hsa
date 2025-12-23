local submenu = require("scripts/menus/pause/pause_submenu")
local inventory_submenu = submenu:new()


local submenu = require("scripts/menus/pause/pause_submenu")
local language_manager = require("scripts/language_manager")
local text_fx_helper = require("scripts/text_fx_helper")
local quest_submenu = submenu:new()

local item_names_top_left = {
	"din_flame",												-- Hero shield
	"farore_quake",												-- Hero shield
	"magic_mirror",												-- Hero shield
	"healing_wand",														-- Bottle
	"nayru_ether",												-- Hero shield
	"magic_cape",												-- Hero shield
	"lens_of_truth",												-- Hero shield
"book_of_mudora",
}

local item_names_middle_left = { -- Ocarina
"din_flame",
"din_flame",
"din_flame",
}


local item_names_bottom_left = { -- Ocarina
-- Row 5
"song_10_zelda",
"song_1_forest",
"song_2_fire",
"song_15_sun",
"song_11_time",
"song_3_water",
-- Row 6 
"song_4_spirit",--
"song_5_lorule",
"song_6_forget",
"song_7_lanayru",
"song_8_shadow",
"song_12_secret",
-- Row 7
"song_9_healing",
"song_14_storms",
"song_13_light",
"song_10_zelda",
"song_10_zelda",
"song_10_zelda",
}

local item_names_top_right = {
	"rod_fire",																-- Bow / Great bow (3 arrows) / light bow (5 arrows)
	"rod_wind",																-- Bow / Great bow (3 arrows) / light bow (5 arrows)
	"rod_light",																-- Fire / ice bow
	"somaria_cane",																-- Fire / ice bow
	"rod_ice",														-- Bottle
	"rod_thunder",																-- Bomb bow
	"rod_darkness",																-- Fire / ice bow
	"rod_doom",																-- Fire / ice bow
}

local item_names_center = { -- Ocarina & magic bar
"magic_bar",
"ocarina",
}

local cell_size = 14
local cell_spacing = 2
local max_row, max_col = 7,14

local min_row_top_left, min_col_top_left = 0, 0
local max_row_top_left, max_col_top_left = 2, 6

local min_row_middle_left, min_col_middle_left = 4, 0
local max_row_middle_left, max_col_middle_left = 4, 5

local min_row_bottom_left, min_col_bottom_left = 5, 0
local max_row_bottom_left, max_col_bottom_left = 7, 5

local min_row_top_right, min_col_top_right = 0, 8
local max_row_top_right, max_col_top_right = 2, 14

local min_row_center, min_col_center = 4, 6
local max_row_center, max_col_center = 6, 6

local piece_of_heart_coords_x, piece_of_heart_coords_y = -64,32
local grid_coords_x, grid_coords_y = -120,-60
local sprite_origin_x, sprite_origin_y = 8,16
local cursor_origin_x, cursor_origin_y = 0,0
local cursor_sound = "menus/cursor"
local assign_sound = "throw"
local menu_name = "magic"
local digits_font_max = "green_digits"
local digits_font = "white_digits"
local item_sprite = "entities/items"

function quest_submenu:on_started()
	submenu.on_started(self)
	self.cursor_sprite = sol.sprite.create("menus/pause/pause_cursor")
	self.cursor_sprite:set_animation("normal")
	self.hearts = sol.surface.create("menus/pause/quest/pieces_of_heart.png")

	self.counters_top_left = {}
	self.counters_middle_left = {}
	self.counters_bottom_left = {}
	self.counters_top_right = {}
	self.counters_center = {}

	self.sprites_top_left = {}
	self.sprites_middle_left = {}
	self.sprites_bottom_left = {}
	self.sprites_top_right = {}
	self.sprites_center = {}

	self.caption_text_keys = {}


	-- Set the title.
	self:set_title(sol.language.get_string("pause.title_"..menu_name))

	-- initialise the cursor.
	local index = self.game:get_value("pause_inventory_last_item_index") or 0
	local row = index % max_row
	local column = index % max_col
	self:set_cursor_position(row, column)

	-- Load Items.
	-- Quest sidebar
	for i,item_name in ipairs(item_names_top_left) do
		local item = self.game:get_item(item_name)
		local variant = item:get_variant()
		self.sprites_top_left[i] = sol.sprite.create(item_sprite)
		self.sprites_top_left[i]:set_animation(item_name)
		if item:has_amount() then
			-- Show a counter in this case.
			local amount = item:get_amount()
			local maximum = item:get_max_amount()
			self.counters_top_left[i] = sol.text_surface.create{
				horizontal_alignment = "center",
				vertical_alignment = "top",
				text = item:get_amount(),
				font = (amount == maximum) and digits_font_max or digits_font,
			}
		end
	end

	for i,item_name in ipairs(item_names_middle_left) do
		local item = self.game:get_item(item_name)
		local variant = item:get_variant()
		self.sprites_middle_left[i] = sol.sprite.create(item_sprite)
		self.sprites_middle_left[i]:set_animation(item_name)
		if item:has_amount() then
			-- Show a counter in this case.
			local amount = item:get_amount()
			local maximum = item:get_max_amount()
			self.counters_middle_left[i] = sol.text_surface.create{
				horizontal_alignment = "center",
				vertical_alignment = "top",
				text = item:get_amount(),
				font = (amount == maximum) and digits_font_max or digits_font,
			}
		end
	end

	for i,item_name in ipairs(item_names_bottom_left) do
		local item = self.game:get_item(item_name)
		local variant = item:get_variant()
		self.sprites_bottom_left[i] = sol.sprite.create("menus/pause/pause_icons")
		self.sprites_bottom_left[i]:set_animation(item_name)
		if item:has_amount() then
			-- Show a counter in this case.
			local amount = item:get_amount()
			local maximum = item:get_max_amount()
			self.counters_bottom_left[i] = sol.text_surface.create{
				horizontal_alignment = "center",
				vertical_alignment = "top",
				text = item:get_amount(),
				font = (amount == maximum) and digits_font_max or digits_font,
				}
			end
		end

		for i,item_name in ipairs(item_names_top_right) do
			local item = self.game:get_item(item_name)
			local variant = item:get_variant()
			self.sprites_top_right[i] = sol.sprite.create(item_sprite)
			self.sprites_top_right[i]:set_animation(item_name)
			if item:has_amount() then
				-- Show a counter in this case.
				local amount = item:get_amount()
				local maximum = item:get_max_amount()
				self.counters_top_right[i] = sol.text_surface.create{
					horizontal_alignment = "center",
					vertical_alignment = "top",
					text = item:get_amount(),
					font = (amount == maximum) and digits_font_max or digits_font,
				}
			end
		end
		
		for i,item_name in ipairs(item_names_center) do
		local item = self.game:get_item(item_name)
		local variant = item:get_variant()
		self.sprites_center[i] = sol.sprite.create(item_sprite)
		self.sprites_center[i]:set_animation(item_name)
		if item:has_amount() then
			-- Show a counter in this case.
			local amount = item:get_amount()
			local maximum = item:get_max_amount()
			self.counters_center[i] = sol.text_surface.create{
				horizontal_alignment = "center",
				vertical_alignment = "top",
				text = item:get_amount(),
				font = (amount == maximum) and digits_font_max or digits_font,
			}
		end
	end

end

function quest_submenu:on_finished()
	if quest_submenu:is_assigning_item() then
		quest_submenu:finish_assigning_item()
	end
	-- Nothing.
end
-- #255

function quest_submenu:draw_items(dst_surface)
	local width, height = dst_surface:get_size()
	local center_x, center_y = width / 2, height / 2
	-- Draw each item
	local y = center_y + grid_coords_y + sprite_origin_y + min_row_top_left * (cell_size + cell_spacing)
	local k = 0
	for j = min_row_top_left/2, max_row_top_left/2 do
		local x = center_x + grid_coords_x + sprite_origin_x + min_col_top_left  * (cell_size + cell_spacing)
		for i = min_col_top_left/2, max_col_top_left/2 do
			k = k + 1
			if item_names_top_left[k] ~= nil then
				local item = self.game:get_item(item_names_top_left[k])
				if item:get_variant() > 0 then
					-- The player has this item: draw it.
					self.sprites_top_left[k]:set_direction(item:get_variant() - 1)
					self.sprites_top_left[k]:draw(dst_surface, x, y)
					if self.counters_top_left[k] ~= nil then
						self.counters_top_left[k]:draw(dst_surface, x + 8, y)
					end
				end
			end
			x = x + 2 * (cell_size + cell_spacing)
		end
		y = y + 2 * (cell_size + cell_spacing)
	end

	-- Draw each item
	local y = center_y + grid_coords_y + sprite_origin_y + min_row_middle_left * (cell_size + cell_spacing)
	local k = 0
	for j = min_row_middle_left, max_row_middle_left do
		local x = center_x + grid_coords_x + sprite_origin_x + min_col_middle_left * (cell_size + cell_spacing)
		for i = min_col_middle_left, max_col_middle_left do
			k = k + 1
			if item_names_middle_left[k] ~= nil then
				local item = self.game:get_item(item_names_middle_left[k])
				if item:get_variant() > 0 then
					-- The player has this item: draw it.
					self.sprites_middle_left[k]:set_direction(item:get_variant() - 1)
					self.sprites_middle_left[k]:draw(dst_surface, x, y)
					if self.counters_middle_left[k] ~= nil then
						self.counters_middle_left[k]:draw(dst_surface, x + 8, y)
					end
				end
			end
			x = x + 2 * (cell_size + cell_spacing)
		end
		y = y + 2 * (cell_size + cell_spacing)
	end
	
	-- Draw each item
	-- x_offset: Shift second row icons to make them less cramped
	-- y_offset: Shift down icons to fit them in the bottom frame
	local x_offset, y_offset = 0, 1
	local y = center_y + grid_coords_y + sprite_origin_y/2 + (min_row_bottom_left + y_offset) * (cell_size + cell_spacing)
	local k = 0
	for j = min_row_bottom_left, max_row_bottom_left do
		if j == 6 then x_offset = 1	else x_offset = 0 end
		local x = center_x + grid_coords_x + sprite_origin_x/2 - 4 + (min_col_bottom_left + 0.5 * x_offset) * (cell_size + cell_spacing)
		for i = min_col_bottom_left, max_col_bottom_left do
			k = k + 1
			if item_names_bottom_left[k] ~= nil then
				local item = self.game:get_item(item_names_bottom_left[k])
				if item:get_variant() > 0 then
					-- The player has this item: draw it.
					self.sprites_bottom_left[k]:set_direction(item:get_variant() - 1)
					self.sprites_bottom_left[k]:draw(dst_surface, x, y)
					if self.counters_bottom_left[k] ~= nil then
						self.counters_bottom_left[k]:draw(dst_surface, x + 8, y)
					end
				end
			end
			x = x + 1 * (cell_size + cell_spacing)
		end
		y = y + 0.5 * (cell_size + cell_spacing)
	end
	
	-- Draw each item
	local y = center_y + grid_coords_y + sprite_origin_y + min_row_top_right * (cell_size + cell_spacing)
	local k = 0
	for j = min_row_top_right/2, max_row_top_right/2 do
		local x = center_x + grid_coords_x + sprite_origin_x + min_col_top_right * (cell_size + cell_spacing)
		for i = min_col_top_right/2, max_col_top_right/2 do
			k = k + 1
			if item_names_top_right[k] ~= nil then
				local item = self.game:get_item(item_names_top_right[k])
				if item:get_variant() > 0 then
					-- The player has this item: draw it.
					self.sprites_top_right[k]:set_direction(item:get_variant() - 1)
					self.sprites_top_right[k]:draw(dst_surface, x, y)
					if self.counters_top_right[k] ~= nil then
						self.counters_top_right[k]:draw(dst_surface, x + 8, y)
					end
				end
			end
			x = x + 2 * (cell_size + cell_spacing)
		end
		y = y + 2 * (cell_size + cell_spacing)
	end

	-- Draw each item
	local y = center_y + grid_coords_y + sprite_origin_y + min_row_center * (cell_size + cell_spacing)
	local k = 0
	for j = min_row_center/2, max_row_center/2 do
		local x = center_x + grid_coords_x + sprite_origin_x + min_col_center * (cell_size + cell_spacing)
		for i = min_col_center/2, max_col_center/2 do
			k = k + 1
			if item_names_center[k] ~= nil then
				local item = self.game:get_item(item_names_center[k])
				if item:get_variant() > 0 then
					-- The player has this item: draw it.
					self.sprites_center[k]:set_direction(item:get_variant() - 1)
					self.sprites_center[k]:draw(dst_surface, x, y)
					if self.counters_center[k] ~= nil then
						self.counters_center[k]:draw(dst_surface, x + 8, y)
					end
				end
			end
			x = x + 2 * (cell_size + cell_spacing)
		end
		y = y + 2 * (cell_size + cell_spacing)
	end

end

function quest_submenu:on_draw(dst_surface)

	local width, height = dst_surface:get_size()
	local center_x, center_y = width / 2, height / 2

	-- Draw the background.
	self:draw_background(dst_surface)
	
	-- Draw the cursor caption.
	self:draw_caption(dst_surface)
	self:draw_title(dst_surface)
	self:draw_infos_text(dst_surface)

	-- Draw items
	self:draw_items(dst_surface)

	-- Draw cursor only when the save dialog is not displayed.
	if self.save_dialog_state == 0 then
		-- If special case (ocarina), draw cursor with an offset instead of real location
		local cursor_x, cursor_y = 0,0
		local cursor_x_offset, cursor_y_offset = 0,0
		if self.cursor_column <= max_col_bottom_left
			and (self.cursor_row >= min_row_bottom_left and self.cursor_row <= max_row_bottom_left) then
				if self.cursor_row == 5 then
					cursor_x_offset= 0
					cursor_y_offset= 1
				elseif self.cursor_row == 6 then
					cursor_x_offset= 0.5
					cursor_y_offset= 0.5
				elseif self.cursor_row == 7 then
					cursor_x_offset= 0
					cursor_y_offset= 0
				end
		else
			cursor_x_offset= 0
			cursor_y_offset= 0
		end
		cursor_x = center_x + grid_coords_x + cursor_origin_x + (cell_size + cell_spacing) * (self.cursor_column + cursor_x_offset)
		cursor_y = center_y + grid_coords_y + cursor_origin_y + (cell_size + cell_spacing) * (self.cursor_row + cursor_y_offset)
			self.cursor_sprite:draw(dst_surface, cursor_x,	cursor_y)
	end

	-- Draw the item being assigned if any.
	if self:is_assigning_item() then
		self.item_assigned_sprite:draw(dst_surface)
	end

	-- Draw save dialog if necessary.
	self:draw_save_dialog_if_any(dst_surface)
end


function quest_submenu:on_command_pressed(command)
	
	local handled = submenu.on_command_pressed(self, command)

	if not handled then

		if command == "action"  then
			if self.game:get_command_effect("action") == nil and self.game:get_custom_command_effect("action") == "info" then
			--	self:show_info_message()
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
			local limit = 0
			if self.cursor_column == limit then
				if self.cursor_row <= max_row_middle_left
				or self.cursor_row == 5 or self.cursor_row == 7 then
					self:previous_submenu()
				elseif self.cursor_row == 6 then -- don't go to previous menu if on row 6
					sol.audio.play_sound(cursor_sound)
					self:set_cursor_position(((self.cursor_row - 1) % (max_row + 1)), math.floor(self.cursor_column/2)*2)					
				end
			else
				if self.cursor_column <= max_col_top_left then -- in left
					if self.cursor_row <= max_row_top_left then -- top or middle left go left 2 (no center because text box)
							sol.audio.play_sound(cursor_sound)
							self:set_cursor_position(self.cursor_row, self.cursor_column - 2)			
					elseif self.cursor_row == min_row_middle_left then -- middle, go left 2
							sol.audio.play_sound(cursor_sound)
							self:set_cursor_position(self.cursor_row, self.cursor_column - 2)		
					else -- bottom left or center
						if self.cursor_column <= max_col_bottom_left then -- bottom left go left 1
							sol.audio.play_sound(cursor_sound)
							self:set_cursor_position(self.cursor_row, self.cursor_column - 1)		
						else -- center
							if self.cursor_row == min_row_middle_left then-- top cell go left 2 to middle left
								sol.audio.play_sound(cursor_sound)
								self:set_cursor_position(self.cursor_row, self.cursor_column - 2)			
							else -- bottom cell go left 1 to bottom left (ocarina)
								sol.audio.play_sound(cursor_sound)
								self:set_cursor_position(self.cursor_row, self.cursor_column - 1)			
							end
						end
					end
				else -- in top right
					sol.audio.play_sound(cursor_sound)
					self:set_cursor_position(self.cursor_row, self.cursor_column - 2)				
				end
			end
			handled = true

		elseif command == "right"  then
			local limit = max_col
			if self.cursor_column == limit then
				self:next_submenu()
			else
				if self.cursor_column <= max_col_top_left then -- in left
					if self.cursor_row <= max_row_top_left then -- top or middle left go right 2 (no center because text box)
							sol.audio.play_sound(cursor_sound)
							self:set_cursor_position(self.cursor_row, self.cursor_column + 2)			
					elseif self.cursor_row == min_row_middle_left then -- middle, go right 2 except for last col
						if self.cursor_column < max_col_middle_left then -- go right one
							sol.audio.play_sound(cursor_sound)
							self:set_cursor_position(self.cursor_row, self.cursor_column + 2)
						end	
					else -- bottom left
						if self.cursor_column < max_col_bottom_left then -- go right one except for last col
							sol.audio.play_sound(cursor_sound)
							self:set_cursor_position(self.cursor_row, self.cursor_column + 1)		
						else
							sol.audio.play_sound(cursor_sound)
							self:set_cursor_position(max_row_center, min_col_center)	--go to center bottom most cell
						end
					end
				else -- in top right
					sol.audio.play_sound(cursor_sound)
					self:set_cursor_position(self.cursor_row, self.cursor_column + 2)				
				end
			end
			handled = true

		elseif command == "up" and self.cursor_column < max_col + 1 then
			if self.cursor_column <= max_col_top_left then -- in left
				if self.cursor_row <= max_row_top_left or (self.cursor_row >= min_row_center and self.cursor_column == min_col_center) then -- top left or center
						sol.audio.play_sound(cursor_sound)
						self:set_cursor_position(((self.cursor_row - 2) % (max_row_center + 2)), self.cursor_column)			
				elseif self.cursor_row == min_row_middle_left then -- middle, go up 2
						sol.audio.play_sound(cursor_sound)
						self:set_cursor_position(((self.cursor_row - 2) % (max_row + 1)), self.cursor_column)		
				elseif self.cursor_row >= min_row_bottom_left then -- bottom left go up 1 except rightmost col (go down left)
						sol.audio.play_sound(cursor_sound)
						self:set_cursor_position(((self.cursor_row - 1) % (max_row + 1)), math.floor(self.cursor_column/2)*2)		
				end
			else -- in top right
				sol.audio.play_sound(cursor_sound)
				self:set_cursor_position(((self.cursor_row - 2) % (max_row_top_right + 2)), self.cursor_column)				
			end
			handled = true

		elseif command == "down" then
			if self.cursor_column <= max_col_top_left then -- in left
				if self.cursor_row <= max_row_top_left or (self.cursor_row >= min_row_center and self.cursor_column == min_col_center) then -- top left or center
						sol.audio.play_sound(cursor_sound)
						self:set_cursor_position(((self.cursor_row + 2) % (max_row_center + 2)), self.cursor_column)			
				elseif self.cursor_row == min_row_middle_left then -- middle, go down one
						sol.audio.play_sound(cursor_sound)
						self:set_cursor_position(((self.cursor_row + 1) % (max_row + 1)), self.cursor_column)		
				elseif self.cursor_row >= min_row_bottom_left then -- bottom left go one down except rightmost col (go down left)
						sol.audio.play_sound(cursor_sound)
						self:set_cursor_position(((self.cursor_row + 1) % (max_row + 1)), math.floor(self.cursor_column/2)*2)		
				end
			else -- in top right
				sol.audio.play_sound(cursor_sound)
				self:set_cursor_position(((self.cursor_row + 2) % (max_row_top_right + 2)), self.cursor_column)				
			end
			handled = true
		end
	end

	print(self.cursor_row, self.cursor_column)
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
		dialog_id =  "menus..pause_inventory.piece_of_heart.1" 
	elseif item_name == "monster_claw_counter" then
		local item = item_name and self.game:get_item(item_name) or nil
		if item:get_amount() > 0 then
			dialog_id =  "menus..pause_inventory.monster_claw_counter.1" 
		end
	elseif item_name == "monster_gut_counter" then
		local item = item_name and self.game:get_item(item_name) or nil
		if item:get_amount() > 0 then
			dialog_id =  "menus..pause_inventory.monster_gut_counter.1" 
		end
	elseif item_name == "monster_horn_counter" then
		local item = item_name and self.game:get_item(item_name) or nil
		if item:get_amount() > 0 then
			dialog_id =  "menus..pause_inventory.monster_horn_counter.1" 
		end
	elseif item_name == "monster_tail_counter" then
		local item = item_name and self.game:get_item(item_name) or nil
		if item:get_amount() > 0 then
			dialog_id =  "menus..pause_inventory.monster_tail_counter.1" 
		end
	elseif item_name == "goron_amber_counter" then
		local item = item_name and self.game:get_item(item_name) or nil
		if item:get_amount() > 0 then
			dialog_id =  "menus..pause_inventory.goron_amber_counter.1" 
		end
	else
		local variant = self.game:get_item(item_name):get_variant()
		dialog_id = "menus..pause_inventory." .. item_name .. "." .. variant
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
	local item = item_name and self.game:get_item(item_name) or nil
	local variant = item and item:get_variant()
	local item_icon_opacity = 128
	if variant > 0 then
	self:set_caption_key("pause.caption.item." .. item_name .. "." .. variant)
	self:set_infos_key("menus..pause_inventory." .. item_name .. "." .. variant)
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

	-- Update the cursor if in ocarina section
	if self.cursor_column <= max_col_bottom_left
		and (self.cursor_row >= min_row_bottom_left and self.cursor_row <= max_row_bottom_left) then
		self.cursor_sprite:set_animation("ocarina")
	else
		self.cursor_sprite:set_animation("normal")
	end

end

function quest_submenu:get_item_name(row, column)

	if column <= max_col_top_left and row <= max_row_top_left then -- top left
		index = ((max_col_top_left-min_col_top_left)/2 + 1) * (row-min_row_top_left)/2 + (column-min_col_top_left)/2
		item_name = item_names_top_left[index + 1]
	elseif column >= min_col_top_right and row <= max_row_top_right  then -- top right
		index = ((max_col_top_right-min_col_top_right)/2 + 1) * (row-min_row_top_right)/2 + (column-min_col_top_right)/2
		item_name = item_names_top_right[index + 1]
	elseif column <= max_col_bottom_left and row >= min_row_bottom_left then -- ocarina
		index = ((max_col_bottom_left-min_col_bottom_left) + 1) * (row-min_row_bottom_left) + (column-min_col_bottom_left)
		item_name = item_names_bottom_left[index + 1]
	elseif column <= max_col_middle_left and row == min_row_middle_left then -- above ocarina
		index = ((max_col_middle_left-min_col_middle_left)/2 + 1) * (row-min_row_middle_left)/2 + (column-min_col_middle_left)/2
		item_name = item_names_middle_left[index + 1]
	else -- center
		index = ((max_col_center-min_col_center)/2 + 1) * (row-min_row_center)/2 + (column-min_col_center)/2
		item_name = item_names_center[index + 1]	
	end

	return item_name
end

function quest_submenu:is_item_selected()

	local item_name = self:get_item_name(self.cursor_row, self.cursor_column)

	return self.game:get_item(item_name):get_variant() > 0

end

-- Assigns the selected item to a slot (1 or 2).
-- The operation does not take effect immediately: the item picture is thrown to
-- its destination icon, then the assignment is done.
-- Nothing is done if the item is not assignable.
function quest_submenu:assign_item(slot)

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
			self.item_assigned_sprite = sol.sprite.create(item_sprite)
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
			movement:set_speed(400)
			movement:start(self.item_assigned_sprite, function()
				self:finish_assigning_item()
			end)
	end

end

-- Returns whether an item is currently being thrown to an icon.
function quest_submenu:is_assigning_item()
	return self.item_assigned_sprite ~= nil
end

-- Stops assigning the item right now.
-- This function is called when we want to assign the item without
-- waiting for its throwing movement to end, for example when the inventory submenu
-- is being closed.
function quest_submenu:finish_assigning_item()

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

return quest_submenu