function submenu:create_cursor()
  -- Set the minimum and maximum radius of the rotation
  local minimum, maximum = 10, 12
 
  -- Speed of the animation (1 = slow, 9 = fast)
  local speed = 5
 
  -- Use the rotation system or just the zoom ? (true = use the rotation, false = just the zoom)
  local use_rotation = true
 
  -- Use the fading option
  local use_fade = true
 
  -- Cursor file
  local cursor = sol.surface.create("menus/hero_head.png")
  local cursor_width, cursor_height = cursor:get_size()
 
  -- Determine the region parts depending on use_rotation state
  if not use_rotation then
    cursor_width = cursor_width / 2
    cursor_height = cursor_height / 2
  end
 
  -- Don't touch this
  local count = 0
 
  function submenu:draw_cursor(dst_surface, x, y)
    -- Increment the rotation
    count = (count + speed) % 360
 
    -- Compute the sin and cos of the rotation
    local sin = math.sin(count * math.pi / 180)
    local cos = math.cos(count * math.pi / 180)
 
    -- Compute the zoom scaling
    local offset = minimum + (maximum - minimum) / 2 + (maximum - minimum) / 2 * sin
	
	-- Update the cursor opacity
	if use_fade then
	  cursor:set_opacity(205 - (0.5 + sin) * 100)
	end
	
	-- Not using the rotation system, no rotation
	if not use_rotation then
	  cos, sin = 1, 1
	end
	
	local rotation_w = use_rotation and 0 or cursor_width
	local rotation_h = use_rotation and 0 or cursor_height

	-- Draw the cursors
	-- Upper Right
    cursor:draw_region(rotation_w, 0, cursor_width, cursor_height, dst_surface, x + (sin * offset), y + (cos * -offset))
	
	-- Lower Left
    cursor:draw_region(0, rotation_h, cursor_width, cursor_height, dst_surface, x + (sin * -offset), y + (cos * offset))
	
	-- Lower Right
    cursor:draw_region(rotation_w, rotation_h, cursor_width, cursor_height, dst_surface, x + (cos * offset), y + (sin * offset))
	
	-- Upper Left
    cursor:draw_region(0, 0, cursor_width, cursor_height, dst_surface, x + (cos * -offset), y + (sin * -offset))
  end
end
submenu:create_cursor()