local lib={}

--[[
Draws a distorsion effect similar to the Ocarina's Mambo's warp song from Zelda: Link's Awakening
Parameters:
  -surface : the surface the effect is applied on
  -game : the game object
  -mode : the drawing mode of the effect, can be either:
      "in": do the fade-in part
      "out": do the fade-out part
  -sfx : the sound effect to play during the effect
  -callback (optional): the function to play once the effect has completed
--]]
local audio_manager=require("scripts/audio_manager")

function lib.start_effect(surface, game, mode, sfx, callback)
  local min_magnitude = 0.01
  local max_magnitude = 0.2
  local duration = 2400--duration of the effect in seconds
  local start_time=sol.main.get_elapsed_time()
  local shader = sol.shader.create("distorsion")
  local function lerp(a,b,p)
    return a+p*(b-a)
  end
  if sfx then
    sol.audio.play_sound(sfx)
  end
  surface:set_shader(shader)
  sol.timer.start(game, 1, function()
    local current_time=sol.main.get_elapsed_time()-start_time
    if mode == "in"  or mode == "out" then
      if mode == "in" then --we are fading in
        warp_magnitude = lerp(min_magnitude, max_magnitude, current_time/duration)        
        if warp_magnitude > max_magnitude then
          warp_magnitude = max_magnitude
          if callback then
            callback()
          end
          return false
        end
      else -- we are fading out
        warp_magnitude = lerp (max_magnitude, min_magnitude, current_time/duration)
        if warp_magnitude < min_magnitude then
          warp_magnitude = min_magnitude
          mode="finished"
        end
      end
      shader:set_uniform("magnitude", warp_magnitude)
    elseif mode == "finished" then --the full warp effect is over
      surface:set_shader(nil)
      if callback then
        callback()
      end
      return false
    end
    return true
  end)
end

return lib