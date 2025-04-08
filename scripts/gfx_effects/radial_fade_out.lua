local lib={}
--[[
  Starts a circle effect similar to ALTTP transition from/to interiors.
  Parameters:
    surface : the surface to apply the shader on;
    game : the game object
    mode : the drawing mode of the effect, can be either:
      "in": do the fade-in part
      "out": do the fade-out part
    sfx : The sound to play during the effect
    callback (optional): the function to execute after the effect is finiched playing
--]]
require("scripts/multi_events")
local audio_manager=require "scripts/audio_manager"
local duration=1000
local max_radius=320

function lib.start_effect(surface, game, mode, sfx, callback)

  local shader=sol.shader.create("radial_fade_out")
  if not surface then
    error("Radial fadeout: No surface has been passed")
    return
  end
  if not(mode=="in" or mode=="out") then
    error("Radial fadeout: unknown drawing mode")
    return
  end
  local function lerp(a,b,p)
    return a+p*(b-a)
  end
  if sfx then
    audio_manager:play_sound(sfx)
  end
  local mask=sol.surface.create(game:get_map():get_camera():get_size())
  mask:fill_color({0,0,0})
  mask:set_opacity(0) --make the mask transparent until the fade in part os over

  game:get_map():register_event("on_draw", function(map, dst_surface)
    mask:draw(surface)
  end)
  local radius
  if mode=="in" then
    radius=max_radius
  else
    radius=0
  end
  surface:set_shader(shader) --Attach the shader to the surface
  shader:set_uniform("radius", radius)
  local start_time=sol.main.get_elapsed_time()
  sol.timer.start(game, 10, function()
    local player_x, player_y=game:get_hero():get_position()
    local cam_x, cam_y=game:get_map():get_camera():get_position()
    --print("PLAYER: ("..player_x..";"..player_y.."), CAMERA: ("..cam_x..";"..cam_y..")")
    shader:set_uniform("position", {player_x-cam_x, player_y-cam_y-13})
    
    local elapsed=sol.main.get_elapsed_time()-start_time
    if mode=="in" then
      radius=lerp(max_radius, 0, elapsed/duration)
      if radius<0 then
        mask:set_opacity(255)
        surface:set_shader(nil)
        if callback then
          callback()
        end
        return false
      end
    else
      radius=lerp(0, max_radius, elapsed/duration)
      if radius>max_radius then
        surface:set_shader(nil)
        if callback then
          callback()
        end
        return false
      end
    end
    shader:set_uniform("radius", radius)
    return true
  end) --START DRAWING!
end

return lib