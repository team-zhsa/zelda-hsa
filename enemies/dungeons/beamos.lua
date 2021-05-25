----------------------------------
--
-- Beamos.
--
-- Revolves around itself and fire a laser if facing the hero.
--
-- Methods : enemy:start_firing()
--
----------------------------------

-- Global variables.
local enemy = ...
local map = enemy:get_map()
local hero = map:get_hero()
local audio_manager = require("scripts/audio_manager")

local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local angle_per_frame = 2 * math.pi / sprite:get_num_frames()

-- Configuration variables.
local triggering_angle = angle_per_frame * 1.5
local start_shooting_delay = 200
local pause_duration = 1000
local is_exhausted_duration = 100

-- Function to start firing.
function enemy:start_firing()
	
  -- Pause the animation.
  sprite:set_paused()

  -- Start the laser after some time.
  sol.timer.start(enemy, start_shooting_delay, function()

    enemy.is_exhausted = true 

    -- Create laser projectile.
    local x, y, layer = enemy:get_position()
    map:create_enemy({
      name = (enemy:get_name() or enemy:get_breed()) .. "_laser",
      breed =  "projectiles/laser",
      x = x,
      y = y - 5,
      layer = layer,
      direction = enemy:get_direction4_to(hero)
    })
		sol.audio.play_sound("cane")
    -- Unpause animation after some time.
    sol.timer.start(enemy, pause_duration, function()
      sprite:set_paused(false)

      -- Allow to shoot again after a delay.
      sol.timer.start(enemy, is_exhausted_duration, function()
        enemy.is_exhausted = false 
      end)
    end)
  end)
end

-- Check if the beamos is facing the hero at each frame change, then stop and shoot.
sprite:register_event("on_frame_changed", function(sprite, animation, frame)

  if not enemy.is_exhausted then
    local x, y, _ = enemy:get_position()
    local hero_x, hero_y, _ = hero:get_position()
    local enemy_angle = frame * angle_per_frame - math.pi -- Frame 0 of the sprite faces the south.
    local hero_angle = math.atan2(y - hero_y, hero_x - x)

    if math.abs(enemy_angle - hero_angle) % (2 * math.pi) <= triggering_angle then
      enemy:start_firing()
    end
  end
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = "protected",
  	boomerang = "protected",
  	explosion = "ignored",
  	sword = "protected",
  	thrown_item = "protected",
  	fire = "protected",
  	jump_on = "ignored",
  	hammer = "protected",
  	hookshot = "protected",
  	magic_powder = "ignored",
  	shield = "protected",
  	thrust = "protected"
  })

  enemy:set_size(32, 16)
  enemy:set_origin(8, 13)
  enemy:set_damage(2)
  enemy.is_exhausted = false -- True after a shoot and before a delay.
end)
