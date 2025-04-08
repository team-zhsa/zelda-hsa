-- ♡ Copying is an act of love. Please copy and share.


--Usage :
--local end_credits = require("scripts/menus/credits")

--sol.menu.start(game, end_credits)
-- Game credits. Plays at the end of the game.

local end_credits = {}
local text_fx_helper = require("scripts/text_fx_helper")

-- https://stackoverflow.com/a/8316375/8811886
function build_array(...)
  local arr = {}
  for v in ... do
    arr[#arr + 1] = v
  end
  return arr
end


-- Called when the menu is started
function end_credits:on_started()
  local lh = 16 -- line height in pixels
  local speed = 12 -- scroll speed in px/s (set it to 8)

  -- Credits dialog
  self.dialog = sol.language.get_dialog("scripts.menus.credits")

  -- Break dialog text into a table of lines
  local lines = self.dialog.text
  lines = lines:gsub("\r\n", "\n"):gsub("\r", "\n")
  lines = build_array(lines:gmatch("([^\n]*)\n"))


  -- Box where the credits go
  self.credits_surface = sol.surface.create(
    400, -- center the surface on the screen --def 320
    (#lines * lh) -- surface is large enough to hold all lines
      + 240 -- surface scrolls in from the bottom, so has a padding top equal to the screen size
      + 16 -- room for 8px top and bottom padding
  )
  
  self.credits_surface:set_shader(sol.shader.create("flickering_transparent"))
  
  -- Loop through all dialog lines and draw them
  for i, line in ipairs(lines) do
    local line_surface =  sol.text_surface.create({horizontal_alignment="center", font="capital", font_size=11, text=line})

    -- Draw the given line
    line_surface:draw(
      self.credits_surface,
      120, -- left padding
      i * lh -- bump it down by line number and line height
        + 8 -- top padding for whole box
    )
  end

  -- Animate the text box upwards
  local m = sol.movement.create("straight")
  m:set_angle(math.pi / 2)
  m:set_speed(speed)
  m:start(self.credits_surface)

  function m:on_position_changed()
    local credits_surface = end_credits.credits_surface
    local x, y = credits_surface:get_xy()
    local w, h = credits_surface:get_size()

    --log(string.format("Credits text box: (%d, %d)  ;;  y+h = %d", x, y, y+h))

    if y + h < 0 then
      -- Credits are out of view, end the menu
      print("Credits animation finished.")
      self:stop()
      sol.menu.stop(end_credits)
    end
  end

end


-- Called each frame
function end_credits:on_draw(dst_surface)
  --dst_surface:clear()
  self.credits_surface:draw(dst_surface, 44, 144)
end


return end_credits