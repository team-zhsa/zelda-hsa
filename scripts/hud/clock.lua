-- The magic bar shown in the game screen.

local audio_manager = require("scripts/audio_manager")

local clock_builder = {}

function clock_builder:new(game, config)

	local clock = {}

	clock.dst_x = config.x - 12
	clock.dst_y = config.y - 6
	clock.surface = sol.surface.create(48, 48)
	clock.clock_img = sol.surface.create("hud/clock.png")
	clock.container_sprite = sol.sprite.create("hud/clock")
	clock.container_sprite:set_animation("bar")
	clock.cursor_sprite = sol.sprite.create("hud/clock")
	clock.cursor_sprite:set_animation("cursor")
	clock.time_of_day_sprite = sol.sprite.create("hud/clock")
	clock.time_of_day_sprite:set_animation("time_of_day")
	clock.time_displayed = game:get_value("hour_of_day")
	if game:get_value("time_of_day") ~= "night" then
		clock.time_of_day_sprite:set_direction(1)
	else
		clock.time_of_day_sprite:set_direction(3)
	end
	clock.time_text = sol.text_surface.create({font = "white_digits", horizontal_alignment = "right", text = clock.time_displayed})
	clock.max_magic_displayed = 0

	-- Checks whether the view displays the correct info
	-- and updates it if necessary.
	function clock:check()

		local time = game:get_value("hour_of_day")
		-- Current time.
		if time ~= clock.time_displayed then
			local increment
			if time < clock.time_displayed then
				increment = -1
			elseif time > clock.time_displayed then
				increment = 1
			end
			if increment ~= 0 then
				clock.time_displayed = clock.time_displayed + increment
				
			end
			clock.time_text:set_text(clock.time_displayed)
			if game:get_value("time_of_day") ~= "night" then
				clock.time_of_day_sprite:set_direction(1)
			else
				clock.time_of_day_sprite:set_direction(3)
			end
		end
		-- Schedule the next check.
		sol.timer.start(clock, 10, function()
			clock:check()
		end)
	end

	function clock:get_surface()
		return clock.surface
	end

	function clock:on_draw(dst_surface)

		local x, y = clock.dst_x, clock.dst_y
		local width, height = dst_surface:get_size()
		if x < 0 then
			x = width + x
		end
		if y < 0 then
			y = height + y
		end

		-- Container
		clock.container_sprite:draw(dst_surface, x, y)

		-- Cursor, text and icon
		clock.time_text:draw(dst_surface, x - 21, y - 1)
		clock.cursor_sprite:draw(dst_surface, (x + 2 * clock.time_displayed) - 20, y)
		clock.time_of_day_sprite:draw(dst_surface, x + 31, y)

	end

	function clock:on_started()
		clock:check()
	end

	return clock
end

return clock_builder
