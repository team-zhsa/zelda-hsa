-- Animated Solarus logo by Maxs.

-- You may include this logo in your quest to show that you use Solarus,
-- but this is not mandatory.

-- Example of use:
-- local solarus_logo = require("menus/solarus_logo")
-- sol.menu.start(solarus_logo)
-- function solarus_logo:on_finished()
--   -- Do whatever you want next (show a title screen, start a game...)
-- end
local title_screen = {}
local mode = sol.shader.create("flashing_rgb") -- or sol.shader.create("flashing_rgb")

-- Main surface of the menu.
local surface = sol.surface.create(320, 256)

-- Solarus title sprite.

local title = sol.surface.create("menus/title_screen/title_text.png")

-- Solarus background sprite.
local background = sol.surface.create("menus/title_screen/background_hyrule.png")

-- Sword sprite.
local sword = sol.sprite.create("menus/title_screen/title_sword")
sword:set_animation("sword")

local t = sol.sprite.create("menus/title_triforce")
t:set_animation("triforce")



-- Black square below the sun.
local white = sol.surface.create(320, 256)
white:fill_color{255, 255, 255}

-- Step of the animation.
local animation_step = 0

-- Time handling.
local timer = nil

-------------------------------------------------------------------------------

-- Rebuilds the whole surface of the menu.
local function rebuild_surface()

  surface:clear()
	t:draw(surface, 128, 128)
  -- Draw the black square to partially hide the sun.
  white:draw(surface, 0, 0)
	background:draw(surface)

  -- Draw the sword.
  sword:draw(surface, 52, 128)
  
  -- Draw the title (after step 1).
  if animation_step >= 1 then
    title:draw(surface, 80, 80)
  end
end

-------------------------------------------------------------------------------

-- Starting the menu.
function title_screen:on_started()
	sol.audio.play_music("cutscenes/title_screen", function()
		sol.audio.stop_music()
	end)
	surface:fade_in(100)
  -- initialise or reinitialise the animation.
  animation_step = 0
  timer = nil
  surface:set_opacity(255)
  sword:set_xy(55, -130)
	t:set_xy(60, 60)
  -- Start the animation.
	sol.timer.start(title_screen, 7000, function()
  	title_screen:start_animation()
	end)
  -- Update the surface.
  rebuild_surface()
end

-- Animation step 1.
function title_screen:step1()
  white:draw(surface, 0, 0)
	--surface:set_shader(mode)
	sol.timer.start(title_screen, 1000, function()
		surface:set_shader(sol.shader.create("default"))
	end)
  title:draw(surface)
  animation_step = 1
  sword:stop_movement()
  sword:set_xy(55, 42)
  -- Update the surface.
  rebuild_surface()
end

-- Animation step 2.
function title_screen:step2()
  animation_step = 2
  -- Update the surface.
  rebuild_surface()
  --[[ Start the final timer.
  sol.timer.start(title_screen, 22000, function()
    surface:fade_out()
    sol.timer.start(title_screen, 700, function()
      sol.menu.stop(title_screen)
    end)
  end)--]]
end

-- Run the logo animation.
function title_screen:start_animation()


  -- Move the sword.
  local sword_movement = sol.movement.create("target")
  sword_movement:set_speed(512)
  sword_movement:set_target(55, 42)
  -- Update the surface whenever the sword moves.
  function sword_movement:on_position_changed()
    rebuild_surface()
  end

  -- Start the movements.
    sword_movement:start(sword, function()

      if not sol.menu.is_started(title_screen) then
        -- The menu may have been stopped, but the movement continued.
        return
      end

      -- If the animation step is not greater than 0
      -- (if no key was pressed).
      if animation_step <= 0 then
        -- Start step 1.
        title_screen:step1()
        -- Create the timer for step 2.
        timer = sol.timer.start(title_screen, 3000, function()
          -- If the animation step is not greater than 1
          -- (if no key was pressed).
          if animation_step <= 1 then
            -- Start step 2.
            title_screen:step2()
          end
        end)
      end
    end)
end

-- Draws this menu on the quest screen.
function title_screen:on_draw(dst_surface)

  local width, height = dst_surface:get_size()
  surface:draw(dst_surface, width / 2 - 160, height / 2 - 120)

end


function title_screen:on_key_pressed(key)

  local handled = true

  if key == "escape" then
    -- stop the program
    sol.main.exit()

  elseif key == "space" or key == "return" then
    -- timer:stop()
     handled = true
     sol.menu.stop(self)

--  Debug.
  elseif key == "left shift" or key == "right shift" then
    sol.menu.stop(self)

  else
    handled = false

  end

  return handled
end

function title_screen:on_joypad_button_pressed(button)

  return title_screen:on_key_pressed("space")

end

return title_screen