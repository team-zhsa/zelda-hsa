--[[ Author: The Unknown, License: CC-BY-NC-SA
Usage: local timer_manager = require("scripts/maps/timer_manager")
Functions:
	timer_manager:start_timer(context, duration,hud_type ("countdown" or "chronometer" or nil), callback)
	timer_manager:stop_all_timers(context)

This script will create a customisable timer. An optional HUD can be displyed to show the remaining seconds.
--]] 

local timer_manager = {}
local language_manager = require("scripts/language_manager")
local timer_calls = 0
local chronometer_value
local chronometer_surface = sol.text_surface.create({
	horizontal_alignment = "center",
	vertical_alignment = "middle", 
	font = "green_digits",
})
local chronometer_menu = {}

function timer_manager:start_timer(context, duration, hud_type, callback)
	timer_calls = 0

	if hud_type == "countdown" then
		chronometer_value = math.floor(duration / 1000) - timer_calls
	elseif hud_type == "chronometer" then
		chronometer_value = timer_calls
	end

	if hud_type == "countdown" or hud_type == "chronometer" then
		sol.menu.start(context, chronometer_menu, true)
		-- Show how many seconds are left/have passed.
		chronometer_surface:set_text(chronometer_value)
	elseif not (hud_type == "countdown" or hud_type == "chronometer") then
		-- No HUD shown
	end

	sol.timer.start(context, duration, function()
		sol.menu.stop(chronometer_menu)
		if callback ~= nil then callback() end
	end)

	sol.timer.start(context, 1000, function()
    sol.audio.play_sound("menus/danger")
    timer_calls = timer_calls + 1
		-- Update the chronometer value
		if hud_type == "countdown" then
			chronometer_value = math.ceil(duration / 1000) - timer_calls
		elseif hud_type == "chronometer" then
			chronometer_value = timer_calls
		end
		if hud_type == "countdown" or hud_type == "chronometer" then
			chronometer_surface:set_text(chronometer_value)
		end
    return timer_calls < math.floor(duration / 1000)
  end)

end

function chronometer_menu:on_draw(dst_surface)
	local screen_width, screen_height = dst_surface:get_size()
	chronometer_surface:set_xy(screen_width / 2, screen_height - 10)
	chronometer_surface:draw(dst_surface)
end

return timer_manager