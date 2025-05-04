-- Nintendo copyright disclaimer screen

-- Usage:
-- local copyright_notice = require("menus/copyright_notice")
-- sol.menu.start(copyright_notice)

-----------------------------------------------------------------
local language_manager = require("scripts/language_manager")

local copyright_notice = {}

local can_skip_menu = true

-- GPLv3 logo
local gpl_logo
local gpl_logo_width, gpl_logo_height

local top_margin = 32
local item_margin = 8
local line_spacing = 6
local can_skip_menu = false
local fade_delay = 20
local is_skipping = false

local menu_font, menu_font_size
local made_by_fans_line_1
local made_by_fans_line_2
local solarus_license_line_1
local solarus_license_line_2
local proprietary_line_1
local proprietary_line_2
local proprietary_line_3
local website_line_1
local menu_items

-- Initialize the menu.
function copyright_notice:on_started()

  -- Fix the font shift (issue with some fonts)
  self.font_y_shift = 0

  -- GPLv3 logo
  gpl_logo = sol.surface.create("menus/gplv3_logo.png")
  gpl_logo_width, gpl_logo_height = gpl_logo:get_size()

  -- Fonts info.
  menu_font, menu_font_size = "alttp", 8

  made_by_fans_line_1 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    color = {255, 255, 255},
    font = menu_font,
    font_size = menu_font_size,
    text_key = "copyright_notice.made_by_fans.line_1",
  }
  made_by_fans_line_2 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    color = {255, 255, 255},
    font = menu_font,
    font_size = menu_font_size,
    text_key = "copyright_notice.made_by_fans.line_2",
  }
  solarus_license_line_1 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    color = {255, 255, 255},
    font = menu_font,
    font_size = menu_font_size,
    text_key = "copyright_notice.solarus.line_1",
  }
  solarus_license_line_2 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    color = {255, 255, 255},
    font = menu_font,
    font_size = menu_font_size,
    text_key = "copyright_notice.solarus.line_2",
  }
  proprietary_line_1 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    color = {255, 255, 255},
    font = menu_font,
    font_size = menu_font_size,
    text_key = "copyright_notice.proprietary.line_1",
  }
  proprietary_line_2 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    color = {255, 255, 255},
    font = menu_font,
    font_size = menu_font_size,
    text_key = "copyright_notice.proprietary.line_2",
  }
  proprietary_line_3 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    color = {235, 174, 0},
    font = menu_font,
    font_size = menu_font_size,
    text_key = "copyright_notice.proprietary.line_3",
  }
  website_line_1 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    color = {235, 174, 0},
    font = "alttp",
    font_size = 8,
    text_key = "copyright_notice.website",
  }

  menu_items = {
    made_by_fans_line_1,
    made_by_fans_line_2,
    gpl_logo,
    solarus_license_line_1,
    solarus_license_line_2,
    proprietary_line_1,
    proprietary_line_2,
    proprietary_line_3,
    website_line_1
  }

  can_skip_menu = false

  -- Fade-in everything
  for _, menu_item in pairs(menu_items) do
    menu_item:fade_in(fade_delay)
  end

  -- The player can skip the menu after a short delay
  sol.timer.start(copyright_notice, 300, function()
  --  can_skip_menu = true
  end)

  -- Menu quits itself after a longer delay because of the long text
  sol.timer.start(copyright_notice, 4000, function()
    can_skip_menu = true

    -- Quit menu
    copyright_notice:try_skip_menu()
  end)
end

-- Draws this menu on the quest screen.
function copyright_notice:on_draw(screen)

  -- Get screen size.
  local screen_width, screen_height = screen:get_size()
  local screen_center_x = screen_width /2

  local item_y = top_margin + self.font_y_shift

  -- Draw the "made by fans" text
  made_by_fans_line_1:draw(screen, screen_center_x, item_y)
  item_y = item_y + menu_font_size + line_spacing
  made_by_fans_line_2:draw(screen, screen_center_x, item_y)
  item_y = item_y + menu_font_size + line_spacing

  -- Draw GPLv3 logo
  gpl_logo:draw(screen, (screen_width - gpl_logo_width) / 2, item_y)
  item_y = item_y + gpl_logo_height + 2 * item_margin

  -- Draw Solarus license text
  solarus_license_line_1:draw(screen, screen_center_x, item_y)
  item_y = item_y + menu_font_size + line_spacing
  solarus_license_line_2:draw(screen, screen_center_x, item_y)
  item_y = item_y + menu_font_size + item_margin

  -- Draw TLOZ trademark text
  proprietary_line_1:draw(screen, screen_center_x, item_y + 8)
  item_y = item_y + menu_font_size + line_spacing
  proprietary_line_2:draw(screen, screen_center_x, item_y + 8)
  item_y = item_y + menu_font_size + line_spacing
  proprietary_line_3:draw(screen, screen_center_x, item_y + 24)
  item_y = item_y + menu_font_size + line_spacing
  website_line_1:draw(screen, screen_center_x, item_y + 24)
  item_y = item_y + menu_font_size + line_spacing

end

-- Try to skip the menu: only possible after small delay
function copyright_notice:try_skip_menu()
  -- The menu is already quitting itself
  if is_skipping then
    return true
  end

  -- The menu can quit itself
  if can_skip_menu then
    -- Prevent multiple fade_out animations
    is_skipping = true

    -- Fade-out everything
    for _, menu_item in ipairs(menu_items) do
      menu_item:fade_out(fade_delay)
    end

    -- Start another timer to quit the menu after the fade-out.
    sol.timer.start(copyright_notice, fade_delay + 700, function()
      -- Quit menu
      sol.menu.stop(copyright_notice)
    end)
  end
  return true
end

-- Key pressed: skip menu or quit Solarus.
function copyright_notice:on_key_pressed(key)
  if key == "return" or key == "space" then
    return copyright_notice:try_skip_menu()
  elseif key == "escape" then
    sol.main.exit()
    return true
  end
end

-- Mouse pressed: skip menu.
function copyright_notice:on_mouse_pressed(button, x, y)
  if button == "left" or button == "right" then
    return copyright_notice:try_skip_menu()
  end
end

-- Joypad pressed: skip menu.
function copyright_notice:on_joypad_button_pressed(button)
  if button == 1 then
    return copyright_notice:try_skip_menu()
  end
end

-- Return the menu to the caller
return copyright_notice
