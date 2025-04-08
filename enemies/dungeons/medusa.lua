-- Lua script of enemy face_lamp.
-- This script is executed every time an enemy with this model is created.

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)
require("enemies/lib/weapons").learn(enemy)
require("scripts/multi_events")
local audio_manager=require("scripts/audio_manager")

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local camera = map:get_camera()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local quarter = math.pi * 0.5
local eighth = math.pi * 0.25

-- Configuration variables
local shooting_delay = 5000
local detection_distance = 500

enemy:register_event("on_created", function(enemy)

  enemy:set_life(1)
  enemy:set_damage(0)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:set_can_attack(false)
  enemy:set_optimization_distance(1000)
  enemy:set_invincible()

end)

enemy:register_event("on_restarted", function(enemy)
  local map = enemy:get_map()
  local hero = map:get_hero()
  sol.timer.start(enemy, 5000, function()

    if enemy:get_distance(hero) < detection_distance and enemy:is_in_same_region(hero) then
      enemy:set_can_attack(true)
      if not map.fire_breath_recent_sound then
        audio_manager:play_sound("enemies/zora")
        -- Avoid loudy simultaneous sounds if there are several fire breathing enemies.
        map.fire_breath_recent_sound = true
        sol.timer.start(map, 200, function()
          map.fire_breath_recent_sound = nil
        end)
      end

      local fireball = enemy:create_enemy({
        name = (enemy:get_name() or enemy:get_breed()) .. "_fireball",
        breed = "projectiles/fireball"
      })
      sol.audio.play_sound("enemies/zora")
      enemy:restart()
    end
    return true  -- Repeat the timer.
  end)
end)