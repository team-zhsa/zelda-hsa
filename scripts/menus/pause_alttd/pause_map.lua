local submenu = require("scripts/menus/pause/pause_submenu")
local audio_manager = require("scripts/audio_manager")

local map_submenu = submenu:new()

function map_submenu:on_started()

  -- Call parent.
  submenu.on_started(self)
      
  -- Set title
  self:set_title(sol.language.get_string("map.title"))

  -- Build map according to the hero's position.
  self.dungeon = self.game:get_dungeon()
  if self.dungeon then
    -- The hero is inside a dungeon.
    self.dungeon_index = self.game:get_dungeon_index()
    self:build_dungeon_map()
  else
    -- The hero is on the world map.
    self:build_world_map()
    -- Get the previously saved cursor_position
    local cursor_x, cursor_y = self.game:get_value("pause_submenu_map_world_x"), self.game:get_value("pause_submenu_map_world_y")
    self:set_world_map_cursor_position(cursor_x, cursor_y)
  end
 
end

function map_submenu:on_draw(dst_surface)

  -- Draw background.
  self:draw_background(dst_surface)
  
  -- Draw caption.
  self:draw_caption(dst_surface)
    
  -- Draw map.
  if self.dungeon then
     self:draw_dungeon_map(dst_surface)
  else
    self:draw_world_map(dst_surface)
  end

end

function map_submenu:on_finished()
  if self.dungeon then
    -- TODO save floor.
  else
    -- Save cursor pos.
    if self.game then
      if self.world_map_cursor_x ~= -1 then
        self.game:set_value("pause_submenu_map_world_x", self.world_map_cursor_x)
      end
      if self.world_map_cursor_y ~= -1 then
        self.game:set_value("pause_submenu_map_world_y", self.world_map_cursor_y)
      end
    end
  end
end

function map_submenu:on_command_pressed(command)
  
  local handled = submenu.on_command_pressed(self, command)

  if not handled then
    if self.dungeon then
      handled = self:dungeon_map_on_command_pressed(command)
    else
      handled = self:world_map_on_command_pressed(command)
    end
  end

  return handled
end

---------------
-- World map --
---------------

function map_submenu:build_world_map()

  self.world_map_bg = sol.surface.create("menus/pause/map/world/world_map_background.png")
  self.world_map = sol.surface.create("menus/pause/map/world/world_map.png")
  self.world_map_fog = sol.surface.create("menus/pause/map/world/world_map_fog.png")
  self.world_map_grid = sol.surface.create("menus/pause/map/world/world_map_grid.png")
  self.world_map_letters = sol.surface.create("menus/pause/map/world/world_map_letters.png")
  self.world_map_numbers = sol.surface.create("menus/pause/map/world/world_map_numbers.png")
  self.world_map_hero = sol.sprite.create("menus/pause/map/world/world_map_hero")
  self.world_map_cursor = sol.sprite.create("menus/pause/map/world/world_map_cursor")
  self:set_world_map_cursor_position(0, 0)

  -- Save the fog (optimization).
  self.fog = {}
  for i = 0, 15 do
    self.fog[i] = {}
    for j = 0, 15 do
      local saved_discovering = self.game:get_value('map_discovering_'..(j)..'_'..(i))
      if saved_discovering == nil then
        saved_discovering = false
      end
      self.fog[i][j] = not saved_discovering
    end
  end
end

function map_submenu:draw_world_map(dst_surface)

  local width, height = dst_surface:get_size()
  local center_x = width / 2
  local center_y = height / 2
  local menu_x, menu_y =  math.ceil(center_x - self.width / 2), math.ceil(center_y - self.height / 2)

  -- Background.
  local world_map_bg_w, world_map_bg_h = self.world_map_bg:get_size() 
  local world_map_bg_x, world_map_bg_y = math.ceil(menu_x + (self.width - world_map_bg_w) / 2), math.ceil(menu_y + (self.height - world_map_bg_h) / 2 + 8)
  self.world_map_bg:draw(dst_surface, world_map_bg_x, world_map_bg_y)
  
  -- Full map.
  local world_map_w, world_map_h = self.world_map:get_size()
  local world_map_x, world_map_y = math.ceil(world_map_bg_x + (world_map_bg_w - world_map_w) / 2), world_map_bg_y + 2
  self.world_map:draw(dst_surface, world_map_x, world_map_y)

  -- Fog (hide places where the player has not been yet).
  local grid_x, grid_y = world_map_x + 1, world_map_y + 1
  local fog_w, fog_h = self.world_map_fog:get_size()
  local fog_x, fog_y = grid_x, grid_y
  for i = 0, 15 do
    local fog_x = grid_x
    for j = 0, 15 do
      if self.fog[i][j] then
        self.world_map_fog:draw(dst_surface, fog_x, fog_y)
      end
      fog_x = fog_x + fog_w - 1
    end
    fog_y = fog_y + fog_h - 1
  end    

  -- Grid.
  self.world_map_grid:draw(dst_surface, grid_x, grid_y)
  --self.world_map_letters:draw(dst_surface, world_map_x, world_map_y - 7)
  --self.world_map_numbers:draw(dst_surface, world_map_x - 9, world_map_y)

  -- Hero position.
  local map_hero_position_x, map_hero_position_y = self.game:get_value("map_hero_position_x"), self.game:get_value("map_hero_position_y")
  if map_hero_position_x ~= nil and map_hero_position_y ~= nil then
    local x = world_map_x + map_hero_position_x * 8 + 1
    local y = world_map_y + map_hero_position_y * 8 + 1
    self.world_map_hero:draw(dst_surface, x, y)
  end

  -- Cursor.
  if not self.dialog_opened then
    local cursor_x, cursor_y = grid_x + self.world_map_cursor_x * 8, grid_y + self.world_map_cursor_y * 8
    self.world_map_cursor:draw(dst_surface, cursor_x, cursor_y)
  end
end

function map_submenu:world_map_on_command_pressed(command)
  local handled = false

  if command == "left" then
    handled = true
    if self.world_map_cursor_x <= 0 then
      self:previous_submenu()      
    else
      audio_manager:play_sound("menus/menu_cursor")
      self:set_world_map_cursor_position(self.world_map_cursor_x - 1, self.world_map_cursor_y)
    end
  elseif command == "right" then
    handled = true
    if self.world_map_cursor_x >= 16 - 1 then
      self:next_submenu()      
    else
      audio_manager:play_sound("menus/menu_cursor")
      self:set_world_map_cursor_position(self.world_map_cursor_x + 1, self.world_map_cursor_y)
    end  
  elseif command == "up" then
    handled = true
    audio_manager:play_sound("menus/menu_cursor")
    self:set_world_map_cursor_position(self.world_map_cursor_x, (self.world_map_cursor_y - 1) % 16)
  elseif command == "down" then
    handled = true
    audio_manager:play_sound("menus/menu_cursor")
    self:set_world_map_cursor_position(self.world_map_cursor_x, (self.world_map_cursor_y + 1) % 16)
  end

  return handled
end

function map_submenu:set_world_map_cursor_position(cursor_x, cursor_y)
  -- Ensure values are correct.
  if not cursor_x then
    cursor_x = 0
  end
  if not cursor_y then
    cursor_y = 0
  end
  self.world_map_cursor_x = cursor_x % 16
  self.world_map_cursor_y = cursor_y % 16
  
  -- Restart cursor animation.
  self.world_map_cursor:set_animation("normal")
  
  -- Change the action icon.
  self.game:set_custom_command_effect("action", nil)
  
  -- Caption.
  --local letter = 'A'
  --letter = string.char(letter:byte() + self.world_map_cursor_x)
  --local caption_text = letter..(self.world_map_cursor_y + 1)&
  local caption_text = '---'
  if self.game:get_value('map_discovering_'..(self.world_map_cursor_x)..'_'..(self.world_map_cursor_y)) then
    caption_text = sol.language.get_string("map.caption.map_" .. self.world_map_cursor_x .. "_" .. self.world_map_cursor_y)
  end
  self:set_caption(caption_text)
end

-----------------
-- Dungeon map --
-----------------

function map_submenu:build_dungeon_map()

    local width, height = sol.video.get_quest_size()
    local center_x, center_y = width / 2, height / 2
    self.dungeon_map_bg = sol.surface.create("menus/pause/map/dungeon/dungeon_background.png")
    self.sprite_map  = sol.sprite.create("entities/items")
    self.sprite_map:set_animation("map")
    self.sprite_compass  = sol.sprite.create("entities/items")
    self.sprite_compass:set_animation("compass")
    self.sprite_boss_key  = sol.sprite.create("entities/items")
    self.sprite_boss_key:set_animation("boss_key")
    self.sprite_beak_of_stone  = sol.sprite.create("entities/items")
    self.sprite_beak_of_stone:set_animation("beak_of_stone")
    self.sprite_hero_head  = sol.sprite.create("menus/pause/map/dungeon/hero_head")
    self.sprite_hero_point  = sol.sprite.create("menus/pause/map/dungeon/hero_point")
    self.boss_icon_img = sol.surface.create("menus/pause/map/dungeon/boss.png")
    self.chest_icon_img = sol.surface.create("menus/pause/map/dungeon/chest_icon.png")
    self.up_arrow_sprite = sol.sprite.create("menus/pause/arrow")
    self.up_arrow_sprite:set_direction(1)
    self.down_arrow_sprite = sol.sprite.create("menus/pause/arrow")
    self.down_arrow_sprite:set_direction(3)
    self.floors_img = sol.surface.create("floors.png", true)
    self.floors_img:set_xy(center_x - 160, center_y - 120)
    self.hero_floor = self.game:get_map():get_floor()
    self.nb_floors = self.dungeon.highest_floor - self.dungeon.lowest_floor + 1
    self.nb_floors_displayed = math.min(7, self.nb_floors)
    if self.hero_floor == nil then
      -- The hero is not on a known floor of the dungeon.
      self.highest_floor_displayed = self.dungeon.highest_floor
      self.selected_floor = self.dungeon.lowest_floor
    else
      -- The hero is on a known floor.
      self.selected_floor = self.hero_floor
      if self.nb_floors <= 7 then
        self.highest_floor_displayed = self.dungeon.highest_floor
      elseif self.hero_floor >= self.dungeon.highest_floor - 2 then
        self.highest_floor_displayed = self.dungeon.highest_floor
      elseif self.hero_floor <= self.dungeon.lowest_floor + 2 then
        self.highest_floor_displayed = self.dungeon.lowest_floor + 6
      else
        self.highest_floor_displayed = self.hero_floor + 3
      end
    end
    self.up_arrow_sprite:set_xy(center_x - 71, center_y - 31)
    self.down_arrow_sprite:set_xy(center_x - 71, center_y - 64)
    -- rooms
  self.rooms_surface = sol.surface.create(168, 168)
  self.rooms_sprite = sol.sprite.create("menus/dungeon_maps/map_" .. self.dungeon_index)
  self.rooms_compass_sprite = sol.sprite.create("menus/dungeon_maps/map_" .. self.dungeon_index .. "_compass")
  self.rooms_no_map_sprite = sol.sprite.create("menus/dungeon_maps/map_" .. self.dungeon_index .. "_no_map")
  self.rooms_no_map_compass_sprite = sol.sprite.create("menus/dungeon_maps/map_" .. self.dungeon_index .. "_no_map_compass")
end

function map_submenu:draw_dungeon_map(dst_surface)

  local width, height = dst_surface:get_size()
  local center_x, center_y = width / 2, height / 2
  local menu_x, menu_y = center_x - self.width / 2, center_y - self.height / 2
  
  -- Background.
  local dungeon_map_bg_w, dungeon_map_bg_h = self.dungeon_map_bg:get_size() 
  local dungeon_map_bg_x, dungeon_map_bg_y = menu_x + (self.width - dungeon_map_bg_w) / 2, menu_y + (self.height - dungeon_map_bg_h) / 2 + 9
  self.dungeon_map_bg:draw(dst_surface, dungeon_map_bg_x, dungeon_map_bg_y)

  -- Draw items.
  local items_x, items_y = dungeon_map_bg_x, dungeon_map_bg_y + dungeon_map_bg_h - 28
  self:draw_dungeon_map_items(dst_surface, items_x, items_y)
  
  -- Draw floors.
  local floors_x, floors_y = menu_x + 64, menu_y + 60
  self:draw_dungeon_map_floors(dst_surface, floors_x, floors_y)
  
  -- Draw rooms.
  local rooms_x, rooms_y = menu_x + 142, menu_y + 64
  self:draw_dungeon_map_rooms(dst_surface, rooms_x, rooms_y)
  
  -- Draw text
  local caption_text = sol.language.get_string("map.caption.map_dungeon_" .. self.dungeon_index)

  self:set_caption(caption_text)

end

function map_submenu:draw_dungeon_map_items(dst_surface, items_x, items_y)

  items_x = items_x + 12
  items_y = items_y + 18
  local item_count = 4
  local item_width = 16
  local item_spacing = (80 - item_count * item_width) / (item_count - 1)
  
  if self.game:has_dungeon_map() then
    self.sprite_map:draw(dst_surface, items_x, items_y)
  end
  if self.game:has_dungeon_compass() then
    self.sprite_compass:draw(dst_surface, items_x + item_width + item_spacing, items_y)
  end
  if self.game:has_dungeon_boss_key() then
    self.sprite_boss_key:draw(dst_surface, items_x + 2 * (item_width + item_spacing), items_y)
  end
  if self.game:has_dungeon_beak_of_stone() then
    self.sprite_beak_of_stone:draw(dst_surface, items_x + 3 * (item_width + item_spacing), items_y)
  end

end

function map_submenu:draw_dungeon_map_floors(dst_surface, floors_x, floors_y)

  -- Draw all the floors.
  local src_x = 96
  local src_y = (15 - self.highest_floor_displayed) * 12
  local src_width = 32
  local src_height = self.nb_floors_displayed * 12 + 1
  local dst_x = floors_x + 17
  local dst_y = floors_y + (8 - self.nb_floors_displayed) * 6
  local old_dst_y = dst_y
  self.floors_img:draw_region(src_x, src_y, src_width, src_height, dst_surface, dst_x, dst_y)

  -- Draw the current floor with other colors.
  src_x = 64
  src_y = (15 - self.selected_floor) * 12
  src_height = 13
  dst_y = old_dst_y + (self.highest_floor_displayed - self.selected_floor) * 12
  self.floors_img:draw_region(src_x, src_y, src_width, src_height, dst_surface, dst_x, dst_y)
  dst_x = floors_x
  dst_y = old_dst_y + (self.highest_floor_displayed - self.hero_floor) * 12 + 8

  -- Draw the hero head beside the current floor.
  self.sprite_hero_head:draw(dst_surface, dst_x, dst_y - 8)
  -- Show the boss icon near his floor.
  if self.game:has_dungeon_compass() and self.dungeon.boss ~= nil then
    dst_x = 116
    --dst_y = (2 - self.dungeon.boss.floor) * 16 + 72
    dst_y = old_dst_y + (self.highest_floor_displayed - self.dungeon.boss.floor) * 12 + 3
    self.boss_icon_img:draw(dst_surface, dst_x, dst_y)
  end

end

function map_submenu:draw_dungeon_map_rooms(dst_surface, rooms_x, rooms_y)

  self.rooms_surface:clear()
  if self.game:has_dungeon_map() then
    self.rooms_sprite:set_animation(self.selected_floor)
    self.rooms_sprite:set_direction(0)
    self.rooms_sprite:draw(self.rooms_surface)
  end
  for i = 1, self.rooms_sprite:get_num_directions() - 1 do
    -- Set default src_x, src_y
    self.rooms_no_map_sprite:set_animation(self.selected_floor)
    self.rooms_no_map_sprite:set_direction(i)
    local src_x, src_y = self.rooms_no_map_sprite:get_frame_src_xy()
    if  self.game:has_explored_dungeon_room(self.dungeon_index, self.selected_floor, i) then
      if self.game:has_dungeon_map() then
        -- If the room is visited, show it in another color.
        self.rooms_sprite:set_direction(i)
        self.rooms_sprite:draw(self.rooms_surface, src_x, src_y)
      else
        -- If the room is visited, show it in another color.
        self.rooms_no_map_sprite:draw(self.rooms_surface, src_x, src_y)
      end
    end
    if self.game:has_dungeon_compass() and self.game:is_secret_room(self.dungeon_index, self.selected_floor, i) then
      if self.game:has_dungeon_map() then
        self.rooms_compass_sprite:set_animation(self.selected_floor)
        self.rooms_compass_sprite:set_direction(i)
        local src_x, src_y = self.rooms_compass_sprite:get_frame_src_xy()
        self.rooms_compass_sprite:draw(self.rooms_surface, src_x, src_y)
      else
        self.rooms_no_map_compass_sprite:set_animation(self.selected_floor)
        self.rooms_no_map_compass_sprite:set_direction(i)
        local src_x, src_y = self.rooms_no_map_compass_sprite:get_frame_src_xy()
        self.rooms_no_map_compass_sprite:draw(self.rooms_surface, src_x, src_y)
      end
    end
    -- Draw hero if is he this room
    if self.game:has_dungeon_compass() then
      local src_x, src_y = self.rooms_no_map_sprite:get_frame_src_xy()
      local map = self.game:get_map()
      local hero = map:get_hero()
      local x,y = hero:get_position()
      local room_width, room_height = 320, 240  -- TODO don't hardcode these numbers
      local map_width, map_height = map:get_size()
      local num_columns = math.floor(map_width / room_width)
      local column = math.floor(x / room_width)
      local row = math.floor(y / room_height)
      local room = row * num_columns + column + 1
      if self.dungeon.boss.room == i and self.dungeon.boss.floor == self.selected_floor then
        src_y = src_y + 3
        self.boss_icon_img:draw(self.rooms_surface, src_x + 4, src_y)
        src_y = src_y + 2
      end
      if room == i and self.hero_floor == self.selected_floor then
        src_x = src_x + 7
        src_y = src_y + 7
        self.sprite_hero_point:draw(self.rooms_surface, src_x, src_y)
      end
    end
  end
  local offsetX = 0
  local offsetY = 0
  if self.dungeon.cols % 2 ~= 0 then
    offsetX = (8 - self.dungeon.cols) * 8
  end
  if self.dungeon.rows % 2 ~= 0 then
    offsetY = (8 - self.dungeon.rows) * 8
  end
  self.rooms_surface:draw(dst_surface,  offsetX + rooms_x, offsetY + rooms_y)


end

function map_submenu:dungeon_map_on_command_pressed(command)
  local handled = false

  if command == "action" then
    if self.game:get_command_effect("action") == nil and self.game:get_custom_command_effect("action") == "info" then
      handled = true
      self:show_info_message()
    end
  elseif command == "left" then
    handled = true
    self:previous_submenu()
  elseif command == "right" then
    handled = true
    self:next_submenu()
  elseif command == "up" or command == "down" then
    handled = true
    -- Navigate between floors.
    local floor = command == "up" and self.selected_floor + 1 or self.selected_floor - 1
    if floor >= self.dungeon.lowest_floor and floor <= self.dungeon.highest_floor then
      -- The new floor is valid.
      audio_manager:play_sound("menus/menu_cursor")
      self:set_dungeon_floor(floor)
    else
      -- The new floor is invalid.
      audio_manager:play_sound("menus/wrong")            
    end
  end

  return handled
end

function map_submenu:set_dungeon_floor(floor)
  -- Reset animation.
  self.sprite_hero_head:set_frame(0)

  -- Change the floor.
  self.selected_floor = floor
  self:load_dungeon_map_image()
  
  -- Other floors.
  if self.selected_floor <= self.highest_floor_displayed - 7 then
    self.highest_floor_displayed = self.highest_floor_displayed - 1
  elseif self.selected_floor > self.highest_floor_displayed then
    self.highest_floor_displayed = self.highest_floor_displayed + 1
  end

end

-- Rebuilds the minimap of the current floor of the dungeon.
function map_submenu:load_dungeon_map_image()
  -- TODO
end

return map_submenu
