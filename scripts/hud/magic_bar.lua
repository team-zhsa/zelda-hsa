-- The magic bar shown in the game screen.

local audio_manager = require("scripts/audio_manager")

local magic_bar_builder = {}

function magic_bar_builder:new(game, config)

  local magic_bar = {}

  magic_bar.dst_x = config.x
  magic_bar.dst_y = config.y
  magic_bar.surface = sol.surface.create(121, 10)
  magic_bar.magic_bar_img = sol.surface.create("hud/magic_bar.png")
  magic_bar.container_sprite = sol.sprite.create("hud/magic_bar")
  magic_bar.background_sprite = sol.sprite.create("hud/magic_bar")
  magic_bar.magic_displayed = game:get_magic()
  magic_bar.max_magic_displayed = 0

  -- Checks whether the view displays the correct info
  -- and updates it if necessary.
  function magic_bar:check()

    local max_magic = game:get_max_magic()
    local magic = game:get_magic()

    magic_bar.background_sprite:set_animation("background")

    -- Maximum magic.
    if max_magic ~= magic_bar.max_magic_displayed then
      if magic_bar.magic_displayed > max_magic then
        magic_bar.magic_displayed = max_magic
      end
      magic_bar.max_magic_displayed = max_magic
      if max_magic > 0 then
        magic_bar.container_sprite:set_direction((max_magic + 1) / 40 - 1)
        magic_bar.background_sprite:set_direction((max_magic + 1) / 40 - 1)
      end
    end

    -- Current magic.
    if magic ~= magic_bar.magic_displayed then
      local increment
      if magic < magic_bar.magic_displayed then
        increment = -1
      elseif magic > magic_bar.magic_displayed then
        increment = 1
      end
      if increment ~= 0 then
        magic_bar.magic_displayed = magic_bar.magic_displayed + increment

        -- Play the magic bar sound.
        if (magic - magic_bar.magic_displayed) % 10 == 1 then
          audio_manager:play_sound("menus/magic_bar")
        end
      end
    end

    -- Magic decreasing animation.
    if game.is_magic_decreasing ~= nil then
      local sprite = magic_bar.container_sprite
      if game:is_magic_decreasing() and sprite:get_animation() ~= "decreasing" then
        sprite:set_animation("decreasing")
      elseif not game:is_magic_decreasing() and sprite:get_animation() ~= "normal" then
        sprite:set_animation("normal")
      end
    end

    -- Schedule the next check.
    sol.timer.start(magic_bar, 20, function()
      magic_bar:check()
    end)
  end

  function magic_bar:get_surface()
    return magic_bar.surface
  end

  function magic_bar:set_dst_position(x, y)
    magic_bar.dst_x = x
    magic_bar.dst_y = y
  end

  function magic_bar:get_surface()
    return magic_bar.surface
  end

  -- Returns if the icon is transparent or not.
  function magic_bar:is_transparent()
    return magic_bar.hud_icon:set_transparent()
  end

  function magic_bar:on_draw(dst_surface)
    magic_bar.surface:clear()
    -- Is there a magic bar to show?
    if magic_bar.max_magic_displayed > 0 then
      local x, y = magic_bar.dst_x, magic_bar.dst_y
      local width, height = dst_surface:get_size()
      y = magic_bar.dst_y + 8 * (math.ceil(game:get_max_life()/60) - 1)
      if x < 0 then
        x = width + x
      end
      if y < 0 then
        y = height + y
      end

      -- Background sprite (on bottom to see current magic)
      magic_bar.background_sprite:draw(magic_bar.surface, 0, y0)

      -- Current magic (with cross-multiplication to adapt the value to the smaller bar)
      magic_bar.magic_bar_img:draw_region(1, 25, math.floor(magic_bar.magic_displayed), 4,
      magic_bar.surface, 0 + 1, 0 + 1)

      -- Container sprite (on top to see scale)
      magic_bar.container_sprite:draw(magic_bar.surface, 0, y0)

      magic_bar.surface:set_opacity(magic_bar.transparent and 128 or 255)
      magic_bar.surface:draw(dst_surface, x, y)
    end
  end

  function magic_bar:on_started()
    magic_bar:check()
  end

-- Sets if the element is semi-transparent or not.
function magic_bar:set_transparent(transparent)
  if transparent ~= magic_bar.transparent then
    magic_bar.transparent = transparent
  end
end
  return magic_bar
end

return magic_bar_builder