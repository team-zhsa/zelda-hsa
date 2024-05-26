local team_logo_menu = {}

-- Team logo
local team_logo_sprite = sol.sprite.create("menus/title_screen/logo_zeldahsa")
local logo_width, logo_height = team_logo_sprite:get_size()
local logo_surface = sol.surface.create(320, 256)
local width, height = logo_surface:get_size()
local center_x, center_y = width / 2, height / 2
local can_skip_menu = false
local phase

local presented_by_text = sol.text_surface.create{
	horizontal_alignment = "center",
	vertical_alignment = "middle",
	color = {235, 174, 0},
	font = "ega",
	font_size = 16,
	text_key = "title_screen.presented_by",
}

-- Red stripe
local red_stripe = sol.surface.create(320, 16)

red_stripe:fill_color{186, 39, 28}
local scale_delta = 0.05
local scale_max = 0.05
local scale_timer = 20
local scale_x, scale_y = 1, 1

function team_logo_menu:on_draw(dst_surface)
	logo_surface:clear()
	red_stripe:draw(logo_surface)
	team_logo_sprite:draw(logo_surface)
	presented_by_text:draw(logo_surface)
	logo_surface:draw(dst_surface)
end

function team_logo_menu:on_started()
  can_skip_menu = false
	phase = 0
	team_logo_sprite:set_opacity(0)
	red_stripe:set_opacity(0)
	presented_by_text:set_opacity(0)
	-- Preload sounds
	sol.audio.preload_sounds()
	presented_by_text:set_xy(center_x, center_y - 40)
	presented_by_text:fade_in(20)
	sol.timer.start(team_logo_menu, 500, function()
		team_logo_menu:animate_red_stripe()
	end)
end

function team_logo_menu:animate_red_stripe()
	phase = 1
	red_stripe:set_xy(0, center_y - 16)
	red_stripe:fade_in()
	red_stripe:set_transformation_origin(center_x + 17, center_y)
	sol.timer.start(team_logo_menu, 200, function()
		sol.timer.start(team_logo_menu, scale_timer, function()
			scale_x = scale_x - scale_delta
			red_stripe:set_scale(scale_x, scale_y)
			return scale_x > scale_max
		end)
		sol.timer.start(team_logo_menu, 800, function()
			team_logo_menu:appear_logo()
		end)
	end)

	sol.audio.play_sound("items/sword_shown")
end

function team_logo_menu:appear_logo()
	phase = 2
	red_stripe:set_opacity(0)
	team_logo_sprite:set_opacity(255)
	team_logo_sprite:set_xy(center_x, center_y)
	team_logo_sprite:set_animation("closed")
	sol.timer.start(team_logo_menu, 400, function()
		team_logo_menu:expand_logo()
	end)
end

function team_logo_menu:expand_logo()
	phase = 3
	team_logo_sprite:set_frame(0)
	team_logo_sprite:set_animation("opening")
	sol.audio.play_sound("menus/title/presented_by")
  sol.timer.start(team_logo_menu, 2000, function()
    can_skip_menu = true
    -- Quit menu
    team_logo_menu:try_skip_menu()
  end)
end

local fade_delay = 40
-- Try to skip the menu: only possible after small delay
function team_logo_menu:try_skip_menu()
  -- The menu is already quitting itself
  if is_skipping then
    return true
  end

  -- The menu can quit itself
  if can_skip_menu then
    -- Prevent multiple fade_out animations
    is_skipping = true

		logo_surface:fade_out(fade_delay)
    -- Start another timer to quit the menu after the fade-out.
    sol.timer.start(team_logo_menu, fade_delay + 700, function()
      -- Quit menu
      sol.menu.stop(team_logo_menu)
    end)
  end
  return true
end

-- Key pressed: skip menu or quit Solarus.
function team_logo_menu:on_key_pressed(key)
  if key == "return" or key == "space" then
    return team_logo_menu:try_skip_menu()
  elseif key == "escape" then
    sol.main.exit()
    return true
  end
end

-- Mouse pressed: skip menu.
function team_logo_menu:on_mouse_pressed(button, x, y)
  if button == "left" or button == "right" then
    return team_logo_menu:try_skip_menu()
  end
end

-- Joypad pressed: skip menu.
function team_logo_menu:on_joypad_button_pressed(button)
  if button == 1 then
    return team_logo_menu:try_skip_menu()
  end
end


return team_logo_menu

