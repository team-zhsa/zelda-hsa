local submenu = require("scripts/menus/map/map_submenu")
local map_submenu = submenu:new()
local max_floors_displayed = 7
local map_shown = false
local waypoint_positions = require("scripts/menus/map/waypoint_config")
local map_areas_config = require("scripts/menus/map/map_areas_config")

-------------------
-- COMMON EVENTS --
-------------------

function map_submenu:on_started()
	submenu.on_started(self)
	self.game:set_hud_enabled(false)

	-- Common to dungeons and outside areas.
	self.hero_head_sprite = sol.sprite.create("menus/map/hero_head")
	self.hero_head_sprite:set_animation("tunic" .. self.game:get_ability("tunic"))
	self.waypoint_sprite = sol.sprite.create("menus/map/map_waypoint")
	self.waypoint_sprite:set_animation("blinking")
	self.up_arrow_sprite = sol.sprite.create("menus/arrow")
	self.up_arrow_sprite:set_direction(1)
	self.down_arrow_sprite = sol.sprite.create("menus/arrow")
	self.down_arrow_sprite:set_direction(3)
	self.left_arrow_sprite = sol.sprite.create("menus/arrow")
	self.left_arrow_sprite:set_direction(2)
	self.right_arrow_sprite = sol.sprite.create("menus/arrow")
	self.right_arrow_sprite:set_direction(0)
	self.map_cursor_img = sol.surface.create("menus/map/map_cursor.png")

	self.dungeon = self.game:get_dungeon()
	if self.dungeon == nil then
		-- Not in a dungeon: show a world map.
		self.world_map_background_img = sol.surface.create("menus/map/world_map_background.png")

	-- Absolute coordinates (relative to the real world): we set the hero position to the map's coordinates.
	local hero_absolute_x, hero_absolute_y = self.game:get_map():get_location()
	local waypoint_absolute_x = waypoint_positions[self.game:get_value("main_quest_step")].x
	local waypoint_absolute_y = waypoint_positions[self.game:get_value("main_quest_step")].y
	local map_width, map_height = self.game:get_map():get_size()

	if self.game:is_in_outside_world() then -- What maps are outside? Set the hero's position to his actual position.
		local hero_map_x, hero_map_y = self.game:get_map():get_entity("hero"):get_position()
		hero_absolute_x = hero_absolute_x + hero_map_x
		hero_absolute_y = hero_absolute_y + hero_map_y
		waypoint_absolute_x = waypoint_absolute_x
		waypoint_absolute_y = waypoint_absolute_y
	end
	if self.game:is_in_inside_world() then -- What maps are inside? Keep the hero's position to the map's position.
		local hero_map_x, hero_map_y = self.game:get_map():get_entity("hero"):get_position()
		hero_absolute_x = hero_absolute_x
		hero_absolute_y = hero_absolute_y
		waypoint_absolute_x = waypoint_absolute_x
		waypoint_absolute_y = waypoint_absolute_y
	end

	self.world_minimap_movement = nil
	self.world_minimap_visible_xy = {x = 0, y = 0, product = 0}
	self.current_map_hovered = {x = 1, y = 1}
	self.current_map_index = {x = 1, y = 1}

	self.zoom_mode = "full"
	self.world_minimap_img = sol.surface.create("menus/map/"..self.zoom_mode.."_hyrule_world_map.png")
	local box_x, box_y = self.world_map_background_img:get_size()
	box_x, box_y = 87, 70

	if self.game:get_item("world_map"):get_variant() > 0 then
		if self.game:is_in_outside_world() or self.game:is_in_inside_world() then
			if self.zoom_mode ~= "small" then
				map_shown = true
				-- Add room for scrolling on the lower right edge.
				self.outside_world_size = {width = 15360 + 1536, height = 12960 + 1536}
				self.outside_world_minimap_size = {width = 960 + 96, height = 810 + 96}
				local offset_x, offset_y = 96, 96
				self.box_offset_x, self.box_offset_y = 30, 54
				local scale_x, scale_y = self.outside_world_minimap_size.width / self.outside_world_size.width, 
																 self.outside_world_minimap_size.height / self.outside_world_size.height
				-- Set the apparent position by multiplying the real position by the map/world size ratio
				local hero_minimap_x = math.floor((hero_absolute_x + 1280) * scale_x)
				local hero_minimap_y = math.floor((hero_absolute_y + 720) * scale_y)
				local waypoint_minimap_x = math.floor((waypoint_absolute_x + 1280) * scale_x)
				local waypoint_minimap_y = math.floor((waypoint_absolute_y + 720) * scale_y)
				-- Offset the position because the map is offsetted from the world (clouds) by 88 pixels
				self.hero_x = hero_minimap_x + (hero_absolute_x / map_width) + offset_x - 8
				self.hero_y = hero_minimap_y + (hero_absolute_y / map_height) + offset_y - 16
				self.waypoint_x = waypoint_minimap_x + (waypoint_absolute_x / map_width) + offset_x - 8
				self.waypoint_y = waypoint_minimap_y + (waypoint_absolute_y / map_height) + offset_y - 16
				self.world_minimap_visible_xy.x = math.min(self.outside_world_minimap_size.width,
																					math.max(0, self.hero_x - offset_x - box_x + self.box_offset_x))
				self.world_minimap_visible_xy.y = math.min(self.outside_world_minimap_size.height,
																					math.max(0, self.hero_y - offset_y - box_y + self.box_offset_y))
			else
				map_shown = true      -- If in Hyrule with World Map, then show the map.
				self.outside_world_size = {width = 15360 + 1408, height = 12960 + 1120}
				self.outside_world_minimap_size = {width = 256, height = 226}
				local offset_x, offset_y = 24 + 60, 24 + 33
				self.box_offset_x, self.box_offset_y = 42, 25
				local scale_x, scale_y = self.outside_world_minimap_size.width / self.outside_world_size.width, 
																	self.outside_world_minimap_size.height / self.outside_world_size.height
				-- Set the apparent position by multiplying the real position by the map/world size ratio
				local hero_minimap_x = math.floor((hero_absolute_x + 1280) * scale_x)
				local hero_minimap_y = math.floor((hero_absolute_y + 720) * scale_y)
				local waypoint_minimap_x = math.floor((waypoint_absolute_x + 1280) * scale_x)
				local waypoint_minimap_y = math.floor((waypoint_absolute_y + 720) * scale_y)
				-- Offset the position because the map is offsetted from the world (clouds) by 88 pixels
				self.hero_x = hero_minimap_x + (hero_absolute_x / map_width) + offset_x - 8
				self.hero_y = hero_minimap_y + (hero_absolute_y / map_height) + offset_y + 16
				self.waypoint_x = waypoint_minimap_x + (waypoint_absolute_x / map_width) + offset_x - 8
				self.waypoint_y = waypoint_minimap_y + (waypoint_absolute_y / map_height) + offset_y + 16
				self.world_minimap_visible_xy.x = math.min(self.outside_world_minimap_size.width,
																					math.max(0, self.hero_x - offset_x - box_x + self.box_offset_x))
				self.world_minimap_visible_xy.y = math.min(self.outside_world_minimap_size.height,
																					math.max(0, self.hero_y - offset_y - box_y + self.box_offset_y))
			end
		end
	else
		-- if World Map not in inventory, show clouds in map screen
		map_shown = false
		self.world_map_background_img = sol.surface.create("menus/map/world_map_background.png")
		self.world_minimap_img = sol.surface.create("menus/map/world_map_clouds.png")
		self.world_minimap_visible_xy.y = 0
		self.world_minimap_visible_xy.x = 0
	end

	else
		-- In a dungeon.
		self.dungeon_index = self.game:get_dungeon_index()

		-- Caption text.
		self:set_caption("map.caption.dungeon_name_" .. self.dungeon_index)

		-- Item icons.
		self.dungeon_map_background_img = sol.surface.create("menus/map/dungeon_map_background.png")
		self.dungeon_map_grid_img = sol.surface.create("menus/map/dungeon_map_grid.png")
		self.dungeon_map_icons_img = sol.surface.create("menus/map/dungeon_map_icons.png")
		self.small_keys_text = sol.text_surface.create{
			font = "white_digits",
			horizontal_alignment = "right",
			vertical_alignment = "top",
			text = self.game:get_num_small_keys()
		}

		-- Floors.
		self.dungeon_floors_img = sol.surface.create("floors.png", true)
		self.hero_floor = self.game:get_map():get_floor()
		self.nb_floors = self.dungeon.highest_floor - self.dungeon.lowest_floor + 1
		self.nb_floors_displayed = math.min(max_floors_displayed, self.nb_floors)
		if self.hero_floor == nil then
			-- The hero is not on a known floor of the dungeon.
			self.highest_floor_displayed = self.dungeon.highest_floor
			self.selected_floor = self.dungeon.lowest_floor
		else
			-- The hero is on a known floor.
			self.selected_floor = self.hero_floor
			if self.nb_floors <= max_floors_displayed then
				self.highest_floor_displayed = self.dungeon.highest_floor
			elseif self.hero_floor >= self.dungeon.highest_floor - 2 then
				self.highest_floor_displayed = self.dungeon.highest_floor
			elseif self.hero_floor <= self.dungeon.lowest_floor + 2 then
				self.highest_floor_displayed = self.dungeon.lowest_floor + max_floors_displayed - 1
			else
				self.highest_floor_displayed = self.hero_floor + 3
			end
		end

		-- Minimap.
		self.dungeon_map_img = sol.surface.create(120, 120)
		self.dungeon_map_spr = sol.sprite.create(
			"menus/map/dungeon_maps/map_" .. self.dungeon_index)
		self:load_dungeon_map_image()
	end

end

function map_submenu:on_finished()
	self.game:set_hud_enabled(true)
	sol.menu.stop(self)
end

-- Called when drawn
function map_submenu:on_draw(dst_surface)

	self:draw_background(dst_surface)

	if not self.game:is_in_dungeon() then
		self:draw_world_map(dst_surface)
	else
		self:draw_dungeon_map(dst_surface)
	end
	self:draw_caption(dst_surface)
	
	self:draw_save_dialog_if_any(dst_surface)
end

----------------
-- WORLD MAPS --
----------------

function map_submenu:draw_world_map(dst_surface)
	local width, height = dst_surface:get_size()
	local center_x, center_y = width / 2, height / 2

	-- Draw the minimap.
	self.world_minimap_img:draw_region(
		self.world_minimap_visible_xy.x,
		self.world_minimap_visible_xy.y,
		182, 148,
		dst_surface,
		center_x - 87, center_y - 70)

	if map_shown then

		-- Draw the hero's position and the waypoint's position.
		local hero_visible_x = self.hero_x - self.world_minimap_visible_xy.x
		local hero_visible_y = self.hero_y - self.world_minimap_visible_xy.y + 16
		local waypoint_position_visible_x = self.waypoint_x - self.world_minimap_visible_xy.x
		local waypoint_position_visible_y = self.waypoint_y - self.world_minimap_visible_xy.y + 16
		if (hero_visible_x >= center_x - 87 and hero_visible_x <= center_x + 87)
		and (hero_visible_y >= center_y - 70  and hero_visible_y <= center_y + 70) then
			-- Makes the hero icon invisible when it is out of bounds.
			self.hero_head_sprite:draw(dst_surface, hero_visible_x, hero_visible_y)
		end
		if (waypoint_position_visible_x >= center_x - 87 and waypoint_position_visible_x <= center_x + 87)
		and (waypoint_position_visible_y >= center_y - 70 and waypoint_position_visible_y <= center_y + 70) then
			-- Makes the waypoint icon invisible when it is out of bounds.
			self.waypoint_sprite:draw(dst_surface, waypoint_position_visible_x, waypoint_position_visible_y)
		end

		-- Draw background image
		self.world_map_background_img:draw(dst_surface, center_x - 95, center_y - 78)

		-- Draw the arrows.
		if self.world_minimap_visible_xy.y > 28 then
			self.up_arrow_sprite:draw(dst_surface, center_x - 40, center_y - 85)
			self.up_arrow_sprite:draw(dst_surface, center_x + 24, center_y - 85)
		end
		
		if self.world_minimap_visible_xy.y < self.outside_world_minimap_size.height - 71 then
			self.down_arrow_sprite:draw(dst_surface, center_x - 40, center_y + 109)
			self.down_arrow_sprite:draw(dst_surface, center_x + 24, center_y + 109)
		end

		if self.world_minimap_visible_xy.x > 11 then
			self.left_arrow_sprite:draw(dst_surface, center_x - 103, center_y - 48)
			self.left_arrow_sprite:draw(dst_surface, center_x - 103, center_y + 32)
		end
		
		if self.world_minimap_visible_xy.x < self.outside_world_minimap_size.width - 88 then
			self.right_arrow_sprite:draw(dst_surface, center_x + 94, center_y - 48)
			self.right_arrow_sprite:draw(dst_surface, center_x + 94, center_y + 32)
		end
	else
		self.world_map_background_img:draw(dst_surface, center_x - 95, center_y - 78)
	end

	-- Set the caption according to the currently visible area.
	local box_x, box_y = self.world_map_background_img:get_size()
	box_x, box_y = ((box_x - 16) / 2) + 8 , ((box_y - 16) / 2) + 8
	self.current_map_hovered.x = math.ceil((self.world_minimap_visible_xy.x + box_x - 100))
	self.current_map_hovered.y = math.ceil((self.world_minimap_visible_xy.y + box_y - 100))
	--print("VISIBLE"..self.world_minimap_visible_xy.x.. " ".. self.world_minimap_visible_xy.y)
	--print("HOVER"..self.current_map_hovered.x.. " ".. self.current_map_hovered.y)
	self.current_map_index.x = math.floor(self.current_map_hovered.x / 80) + 1
	if self.current_map_index.x == -1 then self.current_map_index.x = 0 end
		self.current_map_index.y = math.floor(self.current_map_hovered.y / 90) + 1
	if self.current_map_index.y == -1 then self.current_map_index.y = 0 end
	--print(self.current_map_index.x, self.current_map_index.y)
	if map_shown then
		self:set_caption(map_areas_config[self.current_map_index.x][self.current_map_index.y].key)
	else self:set_caption("map.title") end
	self.map_cursor_img:draw(dst_surface, center_x - 87, center_y - 70)
end

------------------
-- DUNGEON MAPS --
------------------

function map_submenu:draw_dungeon_map(dst_surface)
	local width, height = dst_surface:get_size()
	local center_x, center_y = width / 2, height / 2
	local map_box_x, map_box_y = center_x - 12, center_y - 68
	local map_box_center_x, map_box_center_y = map_box_x + 60, map_box_y + 60
	local dungeon_map_w, dungeon_map_h = self.dungeon.minimap_width, self.dungeon.minimap_height
	local dungeon_map_center_x, dungeon_map_center_y = dungeon_map_w / 2, dungeon_map_h / 2

	-- Background.
	self.dungeon_map_background_img:draw(dst_surface, center_x - 116, center_y - 76)
	self.dungeon_map_grid_img:draw(dst_surface, map_box_x, map_box_y)

	-- Items.
	self:draw_dungeon_items(dst_surface)

	-- Floors.
	self:draw_dungeon_floors(dst_surface)

	-- The map itself.
	if self.hero_point_sprite ~= nil
			and self.selected_floor == self.hero_floor then
		self.hero_point_sprite:draw(self.dungeon_map_img, self.hero_x, self.hero_y)
	end
	self.dungeon_map_img:draw(dst_surface,
	map_box_x + 20,-- dungeon_map_center_x,
	map_box_y + 28)-- dungeon_map_center_y)
end

function map_submenu:draw_dungeon_items(dst_surface)
	local width, height = dst_surface:get_size()
	local center_x, center_y = width / 2, height / 2
	local item_box_x, item_box_y = center_x - 109, center_y + 40
	-- Map.
	if self.game:has_dungeon_map() then
		self.dungeon_map_icons_img:draw_region(
		0, 0, 16, 16,
		dst_surface,
		item_box_x + 2, item_box_y + 4)
	end

	-- Compass.
	if self.game:has_dungeon_compass() then
		self.dungeon_map_icons_img:draw_region(
		16, 0, 16, 16,
		dst_surface,
		item_box_x + 22, item_box_y + 4)
	end

	-- Big key.
	if self.game:has_dungeon_big_key() then
		self.dungeon_map_icons_img:draw_region(
		32, 0, 16, 16,
		dst_surface,
		item_box_x + 42, item_box_y + 4)
	end

	-- Silver key.
	if self.game:has_dungeon_silver_key() then
		self.dungeon_map_icons_img:draw_region(
		0, 16, 16, 16,
		dst_surface,
		item_box_x + 2, item_box_y + 26)
	end

	-- Green key.
	if self.game:has_dungeon_green_key() then
		self.dungeon_map_icons_img:draw_region(
		16, 16, 16, 16,
		dst_surface,
		item_box_x + 22, item_box_y + 26)
	end

	-- Blue key.
	if self.game:has_dungeon_blue_key() then
		self.dungeon_map_icons_img:draw_region(
		32, 16, 16, 16,
		dst_surface,
		item_box_x + 42, item_box_y + 26)
	end

	-- Red key.
	if self.game:has_dungeon_red_key() then
		self.dungeon_map_icons_img:draw_region(
		48, 16, 16, 16,
		dst_surface,
		item_box_x + 62, item_box_y + 26)
	end

	-- Boss key.
	if self.game:has_dungeon_boss_key() then
		-- self.dungeon_map_icons_img:draw_region(51, 0, 16, 16, dst_surface, 107, 168)
	end

	-- Small keys.
	self.dungeon_map_icons_img:draw_region(48, 0, 8, 16,
	dst_surface,
	item_box_x + 62, item_box_y + 4)
	self.small_keys_text:draw(dst_surface, item_box_x + 80, item_box_y + 8)
end

function map_submenu:draw_dungeon_floors(dst_surface)
	
	-- Draw some floors.
	local width, height = dst_surface:get_size()
	local center_x, center_y = width / 2, height / 2
	local src_x = 96
	local src_y = (22 - self.highest_floor_displayed) * 12
	local src_width = 32
	local src_height = self.nb_floors_displayed * 12 + 1
	local dst_x = center_x - 84
	local dst_y = (center_y - 68) + (max_floors_displayed + 1 - self.nb_floors_displayed) * 6
	local old_dst_y = dst_y

	self.dungeon_floors_img:draw_region(src_x, src_y, src_width, src_height,
			dst_surface, dst_x, dst_y)

	-- Draw the current floor with other colors.
	src_x = 64
	src_y = (22 - self.selected_floor) * 12
	src_height = 13
	dst_y = old_dst_y + (self.highest_floor_displayed - self.selected_floor) * 12
	self.dungeon_floors_img:draw_region(src_x, src_y, src_width, src_height,
			dst_surface, dst_x, dst_y)

	-- Draw the hero's icon if any.
	local lowest_floor_displayed = self.highest_floor_displayed - self.nb_floors_displayed + 1
	if self.hero_floor ~= nil
			and self.hero_floor >= lowest_floor_displayed
			and self.hero_floor <= self.highest_floor_displayed then
		dst_x = center_x - 94
		dst_y = old_dst_y + (self.highest_floor_displayed - self.hero_floor) * 12
		self.hero_head_sprite:draw(dst_surface, dst_x, dst_y + 4)
	end

	-- Draw the boss icon if any.
	local boss = self.dungeon.boss
	if self.game:has_dungeon_compass()
			and boss ~= nil
			and boss.floor ~= nil
			and boss.floor >= lowest_floor_displayed
			and boss.floor <= self.highest_floor_displayed then
		dst_x = center_x - 94
		dst_y = old_dst_y + (self.highest_floor_displayed - boss.floor) * 12 + 3
		self.dungeon_map_icons_img:draw_region(78, 0, 8, 8, dst_surface, 113, dst_y)
	end

	-- Draw the arrows.
	if lowest_floor_displayed > self.dungeon.lowest_floor then
		self.down_arrow_sprite:draw(dst_surface, center_x - 76, center_y + 30)
	end

	if self.highest_floor_displayed < self.dungeon.highest_floor then
		self.up_arrow_sprite:draw(dst_surface, center_x - 76, center_y - 62)
	end
end

-- Converts x,y relative to the real floor into coordinates relative
-- to the dungeon minimap.
function map_submenu:to_dungeon_minimap_coordinates(x, y)

	local scale_x, scale_y = self.dungeon.minimap_width / self.dungeon.floor_width,
	 self.dungeon.minimap_height / self.dungeon.floor_height
	 -- The minimap is a grid of 10*10 rooms. -- = map size / dungeon size
	local minimap_x = 0
	local minimap_y = -15
	local minimap_width = 112
	local minimap_height = 112

	x = x * scale_x
	y = y * scale_y
	return x, y
end

-- Rebuilds the minimap of the current floor of the dungeon.
function map_submenu:load_dungeon_map_image()

	self.dungeon_map_img:clear()

	local floor_animation = tostring(self.selected_floor)
	self.dungeon_map_spr:set_animation(floor_animation)

	if self.game:has_dungeon_map() then
		-- Load the image of this floor.
		self.dungeon_map_spr:set_direction(0) -- background
		self.dungeon_map_spr:draw(self.dungeon_map_img)
	end

	-- For each rooms:
	for i = 1, self.dungeon_map_spr:get_num_directions() - 1 do
		-- If the room is explored.
		if self.game:has_explored_dungeon_room(
			self.dungeon_index, self.selected_floor, i
		) then
			-- Load the image of the room.
			self.dungeon_map_spr:set_direction(i)
			self.dungeon_map_spr:draw(self.dungeon_map_img)
		end
	end

	if self.game:has_dungeon_compass() then
		-- Hero.
		self.hero_point_sprite = sol.sprite.create("menus/map/hero_point")

		local hero_absolute_x, hero_absolute_y = self.game:get_map():get_location()
		local hero_map_x, hero_map_y = self.game:get_map():get_entity("hero"):get_position()
		hero_absolute_x = hero_absolute_x + hero_map_x
		hero_absolute_y = hero_absolute_y + hero_map_y

		self.hero_x, self.hero_y = self:to_dungeon_minimap_coordinates(
				hero_absolute_x, hero_absolute_y)
		self.hero_x = self.hero_x - 1

		-- Boss.
		local boss = self.dungeon.boss
		if boss ~= nil
				and boss.floor == self.selected_floor
				and boss.savegame_variable ~= nil
				and not self.game:get_value(boss.savegame_variable) then
			-- Boss coordinates are already relative to its floor.
			local dst_x, dst_y = self:to_dungeon_minimap_coordinates(boss.x, boss.y)
			dst_x = dst_x - 4
			dst_y = dst_y - 4
			self.dungeon_map_icons_img:draw_region(56, 0, 8, 8,
					self.dungeon_map_img, dst_x, dst_y)
		end

		-- Chests.
		if self.dungeon.chests == nil then
			-- Lazily load the chest information.
			self:load_chests()
		end
		for _, chest in ipairs(self.dungeon.chests) do

			if chest.floor == self.selected_floor
					and chest.savegame_variable ~= nil
					and not self.game:get_value(chest.savegame_variable) then
					-- Chests coordinates are already relative to its floor.
				local dst_x, dst_y = self:to_dungeon_minimap_coordinates(chest.x, chest.y)
				dst_y = dst_y - 1
				if chest.big then
					dst_x = dst_x - 3
					self.dungeon_map_icons_img:draw_region(56, 13, 6, 4,
					self.dungeon_map_img, dst_x, dst_y)
				else
					dst_x = dst_x - 2
					self.dungeon_map_icons_img:draw_region(56, 9, 4, 4,
					self.dungeon_map_img, dst_x, dst_y)
				end
			end
		end
	end
end

-- Parses all map data files of the current dungeon in order to determine the
-- position of its chests.
function map_submenu:load_chests()

	local dungeon = self.dungeon
	dungeon.chests = {}
	local current_floor, current_map_x, current_map_y

	-- Here is the magic: set up a special environment to load map data files.
	local environment = {

		properties = function(map_properties)
			-- Remember the floor and the map location
			-- to be used for subsequent chests.
			current_floor = map_properties.floor
			current_map_x = map_properties.x
			current_map_y = map_properties.y
		end,

		chest = function(chest_properties)
			-- Get the info about this chest and store it into the dungeon table.
			if current_floor ~= nil then
				dungeon.chests[#dungeon.chests + 1] = {
					floor = current_floor,
					x = current_map_x + chest_properties.x,
					y = current_map_y + chest_properties.y,
					big = (chest_properties.sprite == "entities/big_chest"),
					savegame_variable = chest_properties.treasure_savegame_variable,
				}
			end
		end,
	}

	-- Make any other function a no-op (tile(), enemy(), block(), etc.).
	setmetatable(environment, {
		__index = function()
			return function() end
		end
	})

	for _, map_id in ipairs(self.dungeon.maps) do

		-- Load the map data file as Lua.
		local chunk = sol.main.load_file("maps/" .. map_id .. ".dat")

		-- Apply our special environment (with functions properties() and chest()).
		setfenv(chunk, environment)

		-- Run it.
		chunk()
	end

	-- Cleanup temporary value.
end

--------------------
-- COMMAND EVENTS --
--------------------

function map_submenu:on_command_pressed(command)
  local handled = submenu.on_command_pressed(self, command)
  if not handled then
    if self.dungeon then
      handled = self:dungeon_on_command_pressed(command)
    elseif not self.game:is_in_dungeon() and self.game:get_item("world_map"):get_variant() > 0 then
			-- Move the outside world minimap.
			if map_shown then
				handled = self:world_on_command_pressed(command)
			end
    end
  end
  return handled
end

function map_submenu:world_on_command_pressed(command)

	local border_reached
	--[[if self.zoom_mode ~= "small" then
		border_reached = (self.world_minimap_visible_xy.x == 9
		or self.world_minimap_visible_xy.x == self.outside_world_minimap_size.width - 87
		or self.world_minimap_visible_xy.y == 26
		or self.world_minimap_visible_xy.y == self.outside_world_minimap_size.height - 70)
	else
		border_reached = (self.world_minimap_visible_xy.x <= 24
		or self.world_minimap_visible_xy.x >= self.outside_world_minimap_size.width - 25 + 24
		or self.world_minimap_visible_xy.y <= 24
		or self.world_minimap_visible_xy.y >= self.outside_world_minimap_size.height - 25 + 24)
	end--]]

	local handled = false
	if command == "left" then
		handled = true
		if self.world_minimap_visible_xy.x > 9 then
			local angle = math.pi
			if self.world_minimap_movement ~= nil then
				self.world_minimap_movement:stop()	
			end
			local movement = sol.movement.create("straight")
				movement:set_speed(172)
				movement:set_angle(angle)
				local submenu = self

			function movement:on_position_changed()
				-- Stop the movement when the key is not pressed.
				if not submenu.game:is_command_pressed("left") then
					self:stop()
					submenu.world_minimap_movement = nil
				end
				-- Stop the movement when map borders reached.
				if (submenu.world_minimap_visible_xy.x == 9
				or submenu.world_minimap_visible_xy.x == submenu.outside_world_minimap_size.width - 87
				or submenu.world_minimap_visible_xy.y == 26
				or submenu.world_minimap_visible_xy.y == submenu.outside_world_minimap_size.height - 70) then
					self:stop()
					if submenu.world_minimap_visible_xy.x == 9 then submenu.world_minimap_visible_xy.x = 10 end
					if submenu.world_minimap_visible_xy.y == 26 then submenu.world_minimap_visible_xy.y = 27 end
					if submenu.world_minimap_visible_xy.x == submenu.outside_world_minimap_size.width - 87 then
						submenu.world_minimap_visible_xy.x = submenu.outside_world_minimap_size.width - 88 end
					if submenu.world_minimap_visible_xy.y == submenu.outside_world_minimap_size.height - 70 then
						submenu.world_minimap_visible_xy.y = submenu.outside_world_minimap_size.height - 71 end
					submenu.world_minimap_movement = nil
				end
			end
			movement:start(self.world_minimap_visible_xy)
			self.world_minimap_movement = movement
		end
	elseif command == "right" then
		handled = true
		if self.world_minimap_visible_xy.x < self.outside_world_minimap_size.width - 87 then
			local angle = 0
			if self.world_minimap_movement ~= nil then
				self.world_minimap_movement:stop()
			end
			local movement = sol.movement.create("straight")
			movement:set_speed(172)
			movement:set_angle(angle)
			local submenu = self

			function movement:on_position_changed()
			-- Stop the movement when the key is not pressed.
			if not submenu.game:is_command_pressed("right") then
				self:stop()
				submenu.world_minimap_movement = nil
				end

				-- Stop the movement when map borders reached.
				if (submenu.world_minimap_visible_xy.x == 9
				or submenu.world_minimap_visible_xy.x == submenu.outside_world_minimap_size.width - 87
				or submenu.world_minimap_visible_xy.y == 26
				or submenu.world_minimap_visible_xy.y == submenu.outside_world_minimap_size.height - 70) then
					self:stop()
				if submenu.world_minimap_visible_xy.x == 9 then submenu.world_minimap_visible_xy.x = 10 end
				if submenu.world_minimap_visible_xy.y == 26 then submenu.world_minimap_visible_xy.y = 27 end
				if submenu.world_minimap_visible_xy.x == submenu.outside_world_minimap_size.width - 87 then
					submenu.world_minimap_visible_xy.x = submenu.outside_world_minimap_size.width - 88 end
				if submenu.world_minimap_visible_xy.y == submenu.outside_world_minimap_size.height - 70 then
					submenu.world_minimap_visible_xy.y = submenu.outside_world_minimap_size.height - 71 end
					submenu.world_minimap_movement = nil
				end
			end
			movement:start(self.world_minimap_visible_xy)
			self.world_minimap_movement = movement
		end
	elseif command == "up" then
		handled = true
		if self.world_minimap_visible_xy.y > 26 then
			local angle = math.pi / 2

			if self.world_minimap_movement ~= nil then
				self.world_minimap_movement:stop()
			end
			local movement = sol.movement.create("straight")
			movement:set_speed(172)
			movement:set_angle(angle)
			local submenu = self

			function movement:on_position_changed()
				if not submenu.game:is_command_pressed("up")  then
					self:stop()
					submenu.world_minimap_movement = nil
				end

				-- Stop the movement when map borders reached.
				if (submenu.world_minimap_visible_xy.x == 9
				or submenu.world_minimap_visible_xy.x == submenu.outside_world_minimap_size.width - 87
				or submenu.world_minimap_visible_xy.y == 26
				or submenu.world_minimap_visible_xy.y == submenu.outside_world_minimap_size.height - 70) then
					self:stop()
				if submenu.world_minimap_visible_xy.x == 9 then submenu.world_minimap_visible_xy.x = 10 end
				if submenu.world_minimap_visible_xy.y == 26 then submenu.world_minimap_visible_xy.y = 27 end
				if submenu.world_minimap_visible_xy.x == submenu.outside_world_minimap_size.width - 87 then
					submenu.world_minimap_visible_xy.x = submenu.outside_world_minimap_size.width - 88 end
				if submenu.world_minimap_visible_xy.y == submenu.outside_world_minimap_size.height - 70 then
					submenu.world_minimap_visible_xy.y = submenu.outside_world_minimap_size.height - 71 end
					submenu.world_minimap_movement = nil
				end
			end
			movement:start(self.world_minimap_visible_xy)
			self.world_minimap_movement = movement
		end
	elseif command == "down" then
		handled = true
		if self.world_minimap_visible_xy.y > 0 then
			local angle =  3 * math.pi / 2

			if self.world_minimap_movement ~= nil then
				self.world_minimap_movement:stop()
			end

			local movement = sol.movement.create("straight")
			movement:set_speed(172)
			movement:set_angle(angle)
			local submenu = self

			function movement:on_position_changed()
				if not submenu.game:is_command_pressed("down")  then
					self:stop()
					submenu.world_minimap_movement = nil
				end

				-- Stop the movement when map borders reached.
				if (submenu.world_minimap_visible_xy.x == 9
				or submenu.world_minimap_visible_xy.x == submenu.outside_world_minimap_size.width - 87
				or submenu.world_minimap_visible_xy.y == 26
				or submenu.world_minimap_visible_xy.y == submenu.outside_world_minimap_size.height - 70) then
					self:stop()
					if submenu.world_minimap_visible_xy.x == 9 then submenu.world_minimap_visible_xy.x = 10 end
					if submenu.world_minimap_visible_xy.y == 26 then submenu.world_minimap_visible_xy.y = 27 end
					if submenu.world_minimap_visible_xy.x == submenu.outside_world_minimap_size.width - 87 then
						submenu.world_minimap_visible_xy.x = submenu.outside_world_minimap_size.width - 88 end
					if submenu.world_minimap_visible_xy.y == submenu.outside_world_minimap_size.height - 70 then
						submenu.world_minimap_visible_xy.y = submenu.outside_world_minimap_size.height - 71 end
						submenu.world_minimap_movement = nil
				end
			end
			
			movement:start(self.world_minimap_visible_xy)
			self.world_minimap_movement = movement

		end
	end
	return handled
end

function map_submenu:dungeon_on_command_pressed(command)
	local handled = false
	if commmand == "left" then
	elseif command == "right" then
	elseif command == "up" then
		-- We are in a dungeon: select another floor.
		local new_selected_floor
		if command == "up" then
			new_selected_floor = self.selected_floor + 1
		end
		if new_selected_floor >= self.dungeon.lowest_floor
				and new_selected_floor <= self.dungeon.highest_floor then
			-- The new floor is valid.
			sol.audio.play_sound("menus/cursor")
			self.hero_head_sprite:set_frame(0)
			self.selected_floor = new_selected_floor
			if self.selected_floor <= self.highest_floor_displayed - 7 then
				self.highest_floor_displayed = self.highest_floor_displayed - 1
			elseif self.selected_floor > self.highest_floor_displayed then
				self.highest_floor_displayed = self.highest_floor_displayed + 1
			end
			self:load_dungeon_map_image()
		end
		handled = true
	elseif command == "down" then
		-- We are in a dungeon: select another floor.
		local new_selected_floor
		if command == "down" then
			new_selected_floor = self.selected_floor - 1
		end
		if new_selected_floor >= self.dungeon.lowest_floor
				and new_selected_floor <= self.dungeon.highest_floor then
			-- The new floor is valid.
			sol.audio.play_sound("menus/cursor")
			self.hero_head_sprite:set_frame(0)
			self.selected_floor = new_selected_floor
			if self.selected_floor <= self.highest_floor_displayed - 7 then
				self.highest_floor_displayed = self.highest_floor_displayed - 1
			elseif self.selected_floor > self.highest_floor_displayed then
				self.highest_floor_displayed = self.highest_floor_displayed + 1
			end
			self:load_dungeon_map_image()
		end
		handled = true
	end
	return handled
end


return map_submenu