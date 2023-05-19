local condition_manager = {}
local in_command_pressed = false
local in_command_release = false
local sword_level = 0
local effect_model = require("scripts/gfx_effects/electric")
local audio_manager = require("scripts/audio_manager")

condition_manager.timers = {
  slow = nil,
  frozen = nil,
  poison = nil,
  confusion = nil,
  electrocution = nil,
  drunk = nil
}

function condition_manager:initialise(game)
  local hero = game:get_hero()
  hero.condition = {
    slow = false,
    frozen = false,
    poison = false,
    confusion = false,
    electrocution = false,
    drunk = false
  }

  function hero:is_condition_active(condition)
    return hero.condition[condition]
  end

  function hero:set_condition(condition, active)
    hero.condition[condition] = active
  end


  function hero:start_confusion(delay)
    local aDirectionPressed = {
      right = false,
      left = false,
      up = false,
      down = false
    }
    local bAlreadyConfused = hero:is_condition_active('confusion')

    if hero:is_condition_active('confusion') and condition_manager.timers['confusion'] ~= nil then
      condition_manager.timers['confusion']:stop()
    end

    if not bAlreadyConfused then
      for key, value in pairs(aDirectionPressed) do
        if game:is_command_pressed(key) then
          aDirectionPressed[key] = true
          game:simulate_command_released(key)
        end
      end
    end

    hero:set_condition('confusion', true)
    if not game:get_value("confusion_once") then
      game:start_dialog("_confusion")
      game:set_value("confusion_once", true)
    end

    condition_manager.timers['confusion'] = sol.timer.start(hero, delay, function()
      hero:stop_confusion()
    end)

    if not bAlreadyConfused then
      for key, value in pairs(aDirectionPressed) do
        if value then
          game:simulate_command_pressed(key)
        end
      end
    end
  end

  function hero:start_frozen(delay)
    if hero:is_condition_active('frozen') then
      return
    end

    hero:freeze()
    hero:set_animation("frozen")
    sol.audio.play_sound("freeze")

    hero:set_condition('frozen', true)
    condition_manager.timers['frozen'] = sol.timer.start(hero, delay, function()
      hero:stop_frozen()
    end)
  end

  function hero:start_electrocution(damage)
    if hero:is_condition_active('electrocution') then
      return
    end
    local map = hero:get_map()
    local camera = map:get_camera()
    local surface = camera:get_surface()
    hero:get_sprite():set_ignore_suspend(true)
    game:set_suspended(true)
    audio_manager:play_sound("enemies/bari/b_state_e")
    hero:set_animation("electrocuted")
    effect_model.start_effect(surface, game, 'in', false)
    local shake_config = {
      count = 32,
      amplitude = 4,
      speed = 180,
    }
    camera:shake(shake_config, function()
      game:set_suspended(false)
      hero:unfreeze()
      hero:start_hurt(damage)
    end)
  end

  function hero:start_poison(damage, delay, max_iteration)
    if hero:is_condition_active('poison') and condition_manager.timers['poison'] ~= nil then
      condition_manager.timers['poison']:stop()
    end

    local iteration_poison = 0
    function do_poison()
      if hero:is_condition_active("poison") and iteration_poison < max_iteration then
        sol.audio.play_sound("hero_hurt")
        game:remove_life(damage)
        iteration_poison = iteration_poison + 1
      end

      if iteration_poison == max_iteration then
        hero:set_blinking(false)
        hero:set_condition('poison', false)
      else
        condition_manager.timers['poison'] = sol.timer.start(hero, delay, do_poison)
      end
    end

    hero:set_blinking(true, delay)
    hero:set_condition('poison', true)
    if not game:get_value("poison_once") then
      --game:start_dialog("_poison")
      game:set_value("poison_once", true)
    end
    do_poison()
  end

  function hero:start_slow(delay)
    if hero:is_condition_active('slow') and condition_manager.timers['slow'] ~= nil then
      condition_manager.timers['slow']:stop()
    end

    hero:set_condition('slow', true)
    hero:set_walking_speed(48)
    condition_manager.timers['slow'] = sol.timer.start(hero, delay, function()
      hero:stop_slow()
    end)
  end

  function hero:stop_confusion()
    local aDirectionPressed = {
      right = {"left", false},
      left = {"right", false},
      up = {"down", false},
      down = {"up", false}
    }

    if hero:is_condition_active('confusion') and condition_manager.timers['confusion'] ~= nil then
      condition_manager.timers['confusion']:stop()
    end

    for key, value in pairs(aDirectionPressed) do
      if game:is_command_pressed(key) then
        aDirectionPressed[key][2] = true
        game:simulate_command_released(key)
      end
    end

    hero:set_condition('confusion', false)

    for key, value in pairs(aDirectionPressed) do
      if value[2] then
        game:simulate_command_pressed(value[1])
      end
    end
  end

  function hero:stop_frozen()
    if hero:is_condition_active('frozen') and condition_manager.timers['frozen'] ~= nil then
      condition_manager.timers['frozen']:stop()
    end

    hero:unfreeze()
    hero:set_animation("walking")
    hero:set_condition('frozen', false)
    sol.audio.play_sound("ice_shatter")
  end

  function hero:stop_electrocution()
    if hero:is_condition_active('electrocution') and condition_manager.timers['electrocution'] ~= nil then
      condition_manager.timers['electrocution']:stop()
    end

    hero:unfreeze()
    hero:set_animation("walking")
    hero:set_condition('electrocution', false)
  end

  function hero:stop_slow()
    if hero:is_condition_active('slow') and condition_manager.timers['slow'] ~= nil then
      condition_manager.timers['slow']:stop()
    end

    hero:set_condition('slow', false)
    hero:set_walking_speed(88)
  end

end

return condition_manager