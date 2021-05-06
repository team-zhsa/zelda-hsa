local laser_manager = {}
local audio_manager=require("scripts/audio_manager")
local effect_model = require("scripts/gfx_effects/electric")

function laser_manager:start(map, entity, source, callback)

  local direction = 1
  local sound_timer
  local x,y,layer = entity:get_position()
  local camera = map:get_camera()
  local surface = camera:get_surface()
  laser_core = map:create_custom_entity({
    sprite ="entities/effects/lightning_strike_core",
    direction = direction,
    layer = layer,
    x = x,
    y = y,
    width = 16,
    height = 16,
  })
  laser = map:create_custom_entity({
    direction = direction,
    layer = layer,
    x = x,
    y = y,
    width = 16,
    height = 16,
  })
  laser:set_origin(8, 13)
  --laser:set_drawn_in_y_order(true)
  laser_sprite = sol.sprite.create("entities/effects/lightning_strike")
  -- Play a repeated sound.
  sound_timer = sol.timer.start(map, 150, function()
    audio_manager:play_sound("laser")
    return true  -- Repeat the timer.
  end)
  effect_model.start_effect(surface, game, 'in', false)
  local shake_config = {
      count = 80,
      amplitude = 4,
      speed = 90,
  }
  camera:shake(shake_config, function()
    laser_core:remove()
    laser:remove()
    sound_timer:stop()
    if callback ~= nil then
      callback()
    end
  end)
  function laser:on_pre_draw()
      if entity:exists() and entity:is_enabled() then
        -- Draw the links.
        local num_lasers = 5
        local dxy = {
          {0, 0},
          {0, 0},
          {0, 0},
          {0, 0}
        }
        local x,y,layer = entity:get_position()
        laser:set_position(x,y,layer)
        local source_x, source_y = source:get_position()
        local x1 = source_x + dxy[direction + 1][1]
        local y1 = source_y + dxy[direction + 1][2]
        local x2, y2 = laser:get_position()
        y2 = y2 - 5
        for i = 0, num_lasers - 1 do
          local laser_x = x1 + (x2 - x1) * i / num_lasers
          local laser_y = y1 + (y2 - y1) * i / num_lasers
          -- Skip the first one when going to the North because it overlaps
          -- the hero sprite and can be drawn above it sometimes.
          local skip = direction == 1 and laser_x == source_x and i == 0
          if not skip then
            map:draw_visual(laser_sprite, laser_x, laser_y)
          end
        end
    end
  end
 
end


return laser_manager