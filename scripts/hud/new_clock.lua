-- The magic bar shown in the game screen.

local audio_manager = require("scripts/audio_manager")

local new_clock_builder = {}

function new_clock_builder:new(game, config)

	local new_clock = {}

	new_clock.dst_x = config.x - 12
	new_clock.dst_y = config.y - 6
	new_clock.surface = sol.surface.create(48, 48)
	new_clock.new_clock_img = sol.surface.create("hud/new_clock.png")
	new_clock.container_sprite = sol.sprite.create("hud/new_clock")
	new_clock.container_sprite:set_animation("bar")
	new_clock.cursor_sprite = sol.sprite.create("hud/new_clock")
	new_clock.cursor_sprite:set_animation("cursor")
	new_clock.time_of_day_sprite = sol.sprite.create("hud/new_clock")
	new_clock.time_of_day_sprite:set_animation("time_of_day")
	new_clock.time_displayed = game:get_value("hour_of_day")
	new_clock.time_text = sol.text_surface.create({font = "white_digits", horizontal_alignment = "right", text = new_clock.time_displayed})
	new_clock.max_magic_displayed = 0

	-- Checks whether the view displays the correct info
	-- and updates it if necessary.
	function new_clock:check()

		local time = game:get_value("hour_of_day")
		-- Current time.
		if time ~= new_clock.time_displayed then
			local increment
			if time < new_clock.time_displayed then
				increment = -1
			elseif time > new_clock.time_displayed then
				increment = 1
			end
			if increment ~= 0 then
				new_clock.time_displayed = new_clock.time_displayed + increment
				
			end
			new_clock.time_text:set_text(new_clock.time_displayed)
			if game:get_value("time_of_day") == "day" then
				new_clock.time_of_day_sprite:set_direction(1)
			else
				new_clock.time_of_day_sprite:set_direction(3)
			end
		end
		-- Schedule the next check.
		sol.timer.start(new_clock, 10, function()
			new_clock:check()
		end)
	end

	function new_clock:get_surface()
		return new_clock.surface
	end

	function new_clock:on_draw(dst_surface)

		local x, y = new_clock.dst_x, new_clock.dst_y
		local width, height = dst_surface:get_size()
		if x < 0 then
			x = width + x
		end
		if y < 0 then
			y = height + y
		end

		-- Container
		new_clock.container_sprite:draw(dst_surface, x, y)

		-- Cursor, text and icon
		new_clock.time_text:draw(dst_surface, x - 21, y - 1)
		new_clock.cursor_sprite:draw(dst_surface, (x + 2 * new_clock.time_displayed) - 20, y)
		new_clock.time_of_day_sprite:draw(dst_surface, x + 31, y)

	end

	function new_clock:on_started()
		new_clock:check()
	end

	return new_clock
end

return new_clock_builder
