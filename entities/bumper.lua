-- Bumper entity from xavius

local entities = ...
local boingIsReady = true

--TODO: Make it compatible with separator manager script
function entities:on_created()
 
  -- Call a function every 22 milliseconds.
	sol.timer.start(22, function()
		if(boingIsReady == true) then
	 
			-- Get hero position
			local hero_x, hero_y, hero_layer = self:get_map():get_entity("hero"):get_position()
			
			-- When changed in engine, get hero width & height here
			local hero_width = 16
			local hero_height = 16
			
			-- Get entity position
			local ent_x, ent_y, ent_layer = self:get_position()
			local ent_width, ent_height = self:get_size()
			
			--TODO: change this line, I hate it, not clean at all
			if( ( (ent_x - 12) < hero_x) and ( (ent_x + ent_width - 3) > hero_x) and ( (ent_y - 12) < hero_y) and ( (ent_y - 11 + ent_height) > hero_y) ) then
				--self:get_map():get_entity("hero"):set_position(hero_x, hero_y + 1, hero_layer)
				
				self:get_map():get_entity("hero"):freeze()
				
				-- Get center point of entity and hero
				local ent_center_x = ent_x + (ent_width / 2)
				local ent_center_y = ent_y + (ent_height / 2)
				
				local hero_center_x = hero_x + (hero_width / 2)
				local hero_center_y = hero_y + (hero_height / 2)
				
				-- Get delta x and delta y
				local delta_x =  hero_center_x - ent_center_x
				local delta_y =  hero_center_y - ent_center_y
				
				local angle = 0
				
				--Check if value is 0 or else division by 0
				if(delta_x == 0) then
					if(delta_y <= 0) then
						angle = math.pi / 2
					else
						angle = 3 * math.pi / 2
					end
				else
					-- Get angle with arctan
					angle = math.atan(delta_y / delta_x)
					
					-- Check the side of the angle
					if(ent_center_x < hero_center_x) then
						-- reverse angle, for some weird reason, atan start it's angle at pi instead of 0... Correct me if I am wrong
						angle = angle * -1
					elseif(ent_center_x > hero_center_x) then
						-- Substract from pi
						angle = math.pi - angle
					end
				end
				
				-- Set movement stuff
				local m = sol.movement.create("straight")
				m:set_speed(130)
				m:set_max_distance(32)
				m:get_ignore_obstacles(false)
				
				-- Set movement angle
				m:set_angle(angle)
				
				-- Start movement
				m:start(self:get_map():get_entity("hero"))
				
				-- Boing!
				sol.audio.play_sound("bounce")
				
				-- Lock function
				boingIsReady = false
				
				sol.timer.start(300, function()
	
					-- Check if hero is still freezed, if not, do nothing
					if( self:get_map():get_entity("hero"):get_state() == "frozen") then
						self:get_map():get_entity("hero"):unfreeze()
					end
					
					-- Unlock function
					boingIsReady = true
				end)
			end --If position
		end --if(boingIsReady == true)
	return true
	end) --main timer
end

