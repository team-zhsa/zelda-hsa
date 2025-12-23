local cinematic_manager = {}
local map_meta = sol.main.get_metatable("map")
require("scripts/multi_events")

local audio_manager = require("scripts/audio_manager")
-- Create the black stripe surface.
local quest_w, quest_h = sol.video.get_quest_size()
local black_stripe_h = 32
local black_stripe_top = sol.surface.create(quest_w, black_stripe_h)
local black_stripe_bottom = sol.surface.create(quest_w, black_stripe_h)
local m_black_stripe_top = sol.movement.create("target")
m_black_stripe_top:set_ignore_suspend(true)
local m_black_stripe_bottom = sol.movement.create("target")
m_black_stripe_bottom:set_ignore_suspend(true)
black_stripe_top:fill_color({0, 0, 0})
black_stripe_bottom:fill_color({0, 0, 0})

local cinematic_menu = {}

-- Enable or disable the cinematic mode
function map_meta:set_cinematic_mode(is_cinematic, options)

  local map = self
  local game = map:get_game()
  local hero = map:get_hero()
  local camera = map:get_camera()
  audio_manager:play_sound("common/bars_npc_dialog")
  local hud_mode = is_cinematic and "dialog" or "normal"
  game:set_hud_enabled(not is_cinematic)
  --game:set_suspended(is_cinematic)

  -- Prevent or allow the player from pausing the game
  game:set_pause_allowed(not is_cinematic)

  -- Entities
  if options and options.entities_ignore_suspend then
    for _, entity in ipairs(options.entities_ignore_suspend ) do
      for _, sprite in entity:get_sprites() do
        sprite:set_ignore_suspend(is_cinematic)
      end
    end
  end
  -- Hero
  if is_cinematic then
    hero:get_sprite():set_ignore_suspend(true)
    hero:freeze()
  else
    hero:get_sprite():set_ignore_suspend(false)
    hero:unfreeze()
  end

  -- Black stripes
  local m_black_stripe_top = sol.movement.create("target")
  local m_black_stripe_bottom = sol.movement.create("target")
  if is_cinematic then
    game.is_cinematic = is_cinematic
    m_black_stripe_top:set_target(0, black_stripe_h)
    m_black_stripe_bottom:set_target(0, -black_stripe_h)
  else
    m_black_stripe_top:set_target(0, 0)
    m_black_stripe_bottom:set_target(0, 0)
  end
  m_black_stripe_top:start(black_stripe_top)
  m_black_stripe_bottom:start(black_stripe_bottom, function()
    if not is_cinematic then
      game.is_cinematic = is_cinematic
      sol.menu.stop(cinematic_menu)
    end
  end)

  -- start and stop the menu displaying the cinematic effect
  if is_cinematic and not sol.menu.is_started(cinematic_menu) then
    sol.menu.start(game, cinematic_menu, false)    
  end
end

-- Retrieve the cinematic status
function map_meta:is_cinematic()
    local game = self:get_game()
    return game.is_cinematic
end

function cinematic_menu:on_draw(dst_surface)
  -- Draw cinematic black stripes.
  black_stripe_top:draw(dst_surface, 0, -black_stripe_h)
  black_stripe_bottom:draw(dst_surface, 0, quest_h)
end

return cinematic_manager