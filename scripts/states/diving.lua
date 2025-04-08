-- Custom diving script.

-- Variables
local hero_meta = sol.main.get_metatable("hero")
local map_meta = sol.main.get_metatable("map")
local game_meta = sol.main.get_metatable("game")
-- Sounds:
local diving_sound = "common/item_in_deep_water"

-- Parameters:
local is_hero_diving
local speed_diving = 88

-- Include scripts
require("scripts/multi_events")
local audio_manager = require("scripts/audio_manager")


function hero_meta:is_diving()

  return is_hero_diving

end

function hero_meta:set_diving(diving)

  is_hero_diving = diving

end

-- Restart variables.
game_meta:register_event("on_started", function(game)

    is_hero_diving = false

  end)

hero_meta:register_event("on_position_changed", function(hero, x, y, layer)

  local map = hero:get_map()
  local current_state = hero:get_state()
  local current_state_object = hero:get_state_object()
  if map:get_ground(x, y, layer) ~= "deep_water" and current_state_object ~= nil and current_state_object:get_description() == "diving" then
    hero:unfreeze()
  end
  if current_state_object ~= nil and current_state_object:get_description() == "diving" then
    hero:get_movement():set_speed(speed_diving)
  end

end)

-- initialise diving state.
local state = sol.state.create()
state:set_description("diving")
state:set_can_control_movement(true)
state:set_can_control_direction(true)
state:set_can_use_sword(false)
state:set_can_use_item(false)


function state:on_started(previous_state_name, previous_state)

  local psn = previous_state_name
  local hero = state:get_game():get_hero()
  local hero_sprite = hero:get_sprite()

  local sword_sprite = hero:get_sprite("sword")
  -- Change tunic animations during the diving state.
  --hero:get_sprite("shadow_override"):stop_animation()
  function hero_sprite:on_animation_finished(animation)
    if animation == "plunging" then
      hero_sprite:set_animation("diving")
    end
  end

  hero_sprite:set_animation("plunging")

end

function state:on_finished(next_state_name, next_state)

  local hero = state:get_entity()
  local map=hero:get_map()
  hero:get_sprite("shadow_override"):set_animation("big")
  diving_state = nil

end

-- Start diving
function hero_meta:start_diving()

  local hero = self
  local game = hero:get_game()
  local map = hero:get_map()
  -- Allow to dive only under certain states.
  local hero_state = hero:get_state()
  if hero_state ~= "swimming" then
    return
  end
  -- Play diving sound.
  audio_manager:play_sound(diving_sound)
  -- Start jumping state.
  hero:start_state(state)
  -- Start diving
  sol.timer.start(hero, 2000, function()
      -- Finish diving.
      hero:unfreeze()
    end)

end



