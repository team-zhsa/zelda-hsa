local lib={}

--[[
  A visual effect that fades the screen to/from a white surface
  Parameters:
    surface : the surface to apply the shader on;
    game : the game object
    mode : how the effect is played, can be either :
      "in": the fading-in part
      "out": the fading-out part
    sfx : The sound to play during the transition
    callback (optional): the function to execute after the effect is finiched playing
--]]
local audio_manager=require "scripts/audio_manager"
require("scripts/multi_events")
function lib.start_effect(surface, game, mode, sfx, callback)
  local map=game:get_map()
  local duration=2000
  local start_time=sol.main.get_elapsed_time()
  local function lerp(a,b,p)
    return a+p*(b-a)
  end
  if sfx then
    audio_manager:play_sound(sfx)
  end
  local mask=sol.surface.create(surface:get_size())
  mask:fill_color({0,0,255})
  local alpha
  map:register_event("on_draw", function(map, dst_surface)
      mask:draw(dst_surface)
  end)
  sol.timer.start(game, 10, function()
    local dt=sol.main.get_elapsed_time()-start_time      
    if mode == "in" then
      alpha = math.floor(lerp(0, 255, dt/duration))
      if alpha > 255 then
        alpha = 255
        if callback then
          callback()
        end
        return false
      end
    else
      alpha = math.floor(lerp (255, 0, dt/duration))
      if alpha < 0 then
        alpha = 0
        if callback then
          callback()
        end
        return false
      end
    end
    mask:set_opacity(alpha)
    return true
  end)
end

return lib