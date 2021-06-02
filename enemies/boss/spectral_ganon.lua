-- Lua script of enemy boss/spectral_ganon.
-- This script is executed every time an enemy with this model is created.

-- Spectral Ganon - Second Dungeon Boss
--[[

Phase I: Attack Ganon with your bow until he's 40 of life.

Phase II: Ganon is now hiding several times.

Phase III: Ganon will try to freeze the hero. When Link attacks him with his brand new bow, ice cubes will spawn instead and will be thrown at the hero. Lit the four torches that will appear and kill him while he'll be immobilised. You're done!

--]]
local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
local phase = 1
local x, y, layer = enemy:get_position()
local m = sol.movement.create("target")

-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(37)
  enemy:set_damage(2)
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()

	if phase == 1 then
		enemy:set_attack_consequence("sword", "ignored")
		enemy:set_attack_consequence("thrown_item", 2)
		enemy:set_attack_consequence("boomerang", "immobilized")
		enemy:set_attack_consequence("arrow", 5)
		enemy:set_attack_consequence("explosion", 5)
		sol.timer.start(enemy, 50, function()
    	local tx, ty, _ = enemy:get_map():get_hero():get_position()
    	if enemy:get_distance(tx, ty) < max_distance then
     	 self:get_sprite():set_animation("shaking")
     	 sol.timer.start(self, 1000, function() shoot(tx-5, ty) end)
    	  return false -- Stop timer.
  	  end
  	  return true
  	end)
		if enemy:get_life(40) then
			phase = 2		
		end

	elseif phase == 2 then
		enemy:set_attack_consequence("sword", "ignored")
		enemy:set_attack_consequence("thrown_item", "ignored")
		enemy:set_attack_consequence("boomerang", 5)
		enemy:set_attack_consequence("arrow", "ignored")

--[[	elseif phase == 3 then
		enemy:set_attack_consequence("sword", function()
			hero:freeze()
			hero:set_invincible()
			hero:get_sprite():set_animation("frozen")
			sol.audio.play_sound("freeze")
			hero:set_blinking(true, 300)
			sol.timer.start(enemy, 2000, function()
				hero:unfreeze()
			end)		
		end)
		enemy:set_attack_consequence("arrow", function()
			game:remove_life(2)	
		end)
		enemy:set_attack_consequence("boomerang", 5)
--]]
	end
end		

function shoot(tx, ty)
	local properties = {name = "ganon_fireball_triple", breed = "boss/fireball_triple"}
    -- Create new particle.
    local e = enemy:create_enemy(properties)
    sol.audio.play_sound("ennemies/beamos")
    -- Create movement. Destroy enemy when the movement ends.
    local m = sol.movement.create("target")
    m:set_target(tx, ty); m:set_speed(speed)
    function m:on_finished() e:explode() end
    function m:on_obstacle_reached() e:explode() end
    m:start(e)
    -- Stop creating particles if necessary.
    particles = particles - 1
    if particles <= 0 then
      enemy:stop_firing()
      return 
    else
      sol.timer.start(enemy, time_between_particles, function()
        shoot(tx, ty)
      end)
    end
  end