----------------------------------
--
-- Pillar entity that can collapse.
-- 
-- Methods : pillar:start_breaking()
-- Events :  pillar:on_collapse_finished()
--
----------------------------------

local pillar = ...
local cinematic_manager = require("scripts/maps/cinematic_manager")
local map_tools = require("scripts/maps/map_tools")

local game = pillar:get_game()
local map = pillar:get_map()
local hero = map:get_hero()
local sprite = pillar:get_sprite()
local sprite_top = pillar:create_sprite("entities/statues/pillar", "top")

-- Initialize the pillar.
pillar:register_event("on_created", function(pillar)

  pillar:set_traversable_by(false)
  
  -- Display the top sprite if the corresponding world savegame doesn't exist, else display the destroyed pillar.
  if not game:get_value(map:get_world() .. "_" .. pillar:get_name()) then
    sprite_top:set_animation("stopped_top")
    sprite_top:set_xy(0, -24)
    -- TODO layer up
  else
    pillar:remove_sprite(sprite_top)
    sprite:set_animation("destroyed")
  end
end)

-- Start a brief effect.
local function start_brief_effect(sprite_name, animation_name, x_offset, y_offset, on_finished_callback)

  -- Create a new sprite with the animation and remove it once animation finished.
  local effect_sprite = pillar:create_sprite(sprite_name)
  effect_sprite:set_xy(x_offset, y_offset)
  effect_sprite:set_ignore_suspend()
  effect_sprite:set_animation(animation_name, function()
    if on_finished_callback then
      on_finished_callback()
    end
    pillar:remove_sprite(effect_sprite)
  end)
end

-- Make hero and all region enemies invincible or vulnerable.
local function make_all_invincible(invincible)
  hero:set_invincible(invincible)
  for entity in map:get_entities_in_region(hero) do
    if entity:get_type() == "enemy" then
      if invincible then
        entity:set_invincible()
      else
        entity:set_default_attack_consequences()
      end
    end
  end
end

-- Make the pillar explode, collapse and then disabled.
function pillar:start_breaking()

  local save_name = map:get_world() .. "_" .. pillar:get_name()
  if game:get_value(save_name) then
    return -- Pillar is already breaking.
  end

  -- Save the pillar state.
  game:set_value(save_name, true)

  -- Start cinematic.
  map_tools.start_earthquake({count = 64, amplitude = 4, speed = 90}) -- Start the earthquake when the hit occurs.
  map:set_cinematic_mode(true, {entities_ignore_suspend = {pillar}}) -- TODO make iron_ball_ignore_suspend
  make_all_invincible(true)
  start_brief_effect("entities/effects/sparkle_small", "default", 0, -16)

  -- Start 3 chained explosions.
  for i = 1, 3 do
    explosion_timer = sol.timer.start((i - 1) * 500, function()
      map_tools.start_chained_explosion_on_entity(pillar, 2000, 32, function()
        -- If this is the last explosion, stop the cinematic and call the collapse finished event.
        if map:get_entities_count("chained_explosion") == 1 then
          make_all_invincible(false)
          map:set_cinematic_mode(false, {entities_ignore_suspend = {pillar}})
          if pillar.on_collapse_finished then
            pillar:on_collapse_finished() -- Call event
          end
        end
      end)
    end)
    explosion_timer:set_suspended_with_map(false)
  end

  -- Start and pause the collapse animation on the pillar and its top entity, then unpause after a delay.
  sprite:set_animation("collapse", function()
    sprite:set_animation("destroyed")
  end)
  sprite_top:set_animation("collapse_top", function()
    pillar:remove_sprite(sprite_top)
  end)
  sprite:set_paused()
  sprite_top:set_paused()
  collapse_timer = sol.timer.start(500, function()
    sprite:set_paused(false)
    sprite_top:set_paused(false)
  end)
  collapse_timer:set_suspended_with_map(false)
end