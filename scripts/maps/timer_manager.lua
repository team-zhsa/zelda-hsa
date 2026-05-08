--[[ Author: The Unknown, License: CC-BY-NC-SA
Usage: local timer_manager = require("scripts/maps/timer_manager")
Functions:
	timer_manager:start_timer(
		context, duration, type ("countdown" or "chronometer" or nil),
		hud_shown(true or false),
		suspended_with_map (true or false),
		callback,
		update_callback)
	timer_manager:stop_all_timers(context)

This script will create a customisable timer. An optional HUD can be displyed to show the remaining seconds.
--]] 

local timer_manager = {}
local language_manager = require("scripts/language_manager")
local timer_calls = 0
local chronometer_value
local chronometer_surface = sol.text_surface.create({
	horizontal_alignment = "right",
	vertical_alignment = "middle", 
	font = "kubasta",
	font_size = 9,
})
local chronometer_menu = {}

function timer_manager:update_chronometer(duration, type, hud_shown)

	if type == "countdown" then
		chronometer_value = math.floor(duration / 1000) - timer_calls
	elseif type == "chronometer" then
		chronometer_value = timer_calls
	end

	if hud_shown == true then
 		local total_seconds = chronometer_value
    local seconds = total_seconds % 60
    local total_minutes = math.floor(total_seconds / 60)
    local minutes = total_minutes % 60
    local formatted = string.format("%02d:%02d", minutes, seconds)
		chronometer_surface:set_text(formatted)
	end

	-- Call a function every update if needed (for minigames, update the playing time value)
	if update_callback ~= nil then
		update_callback()
	end

end

function timer_manager:start_timer(context, duration, type, hud_shown, suspended_with_map, callback, update_callback)
	timer_calls = 0

	-- Set default values
	if type == nil then
		type = "chronometer"
	end
	if hud_shown == nil then
		hud_shown = true
	end
	if suspended_with_map == nil then
		suspended_with_map = true
	end

	if hud_shown == true then
		sol.menu.start(context, chronometer_menu, true)
		sol.timer.start(chronometer_menu, duration, function()
			sol.menu.stop(chronometer_menu)
			if callback ~= nil then callback() end
		end)
	end

	timer_manager:update_chronometer(duration, type, hud_shown, update_callback)

	sol.timer.start(chronometer_menu, 1000, function()
    sol.audio.play_sound("menus/danger")
    timer_calls = timer_calls + 1
		timer_manager:update_chronometer(duration, type, hud_shown, update_callback)
    return timer_calls < math.floor(duration / 1000)
  end)

end

function timer_manager:stop_timer(callback)
	sol.timer.stop_all(chronometer_menu)
	sol.menu.stop(chronometer_menu)
	if callback ~= nil then callback() end
end

function chronometer_menu:on_draw(dst_surface)
	local screen_width, screen_height = dst_surface:get_size()
	chronometer_surface:set_xy(screen_width -8 , screen_height - 20)
	chronometer_surface:draw(dst_surface)
end

return timer_manager