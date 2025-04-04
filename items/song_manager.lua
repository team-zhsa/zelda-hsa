local config = {}

function config:create(item, properties)
  local bird = nil

	function item:on_created()
  	self:set_savegame_variable(properties.savegame_variable)
  	self:set_assignable(true)
	end

	function item:on_using()
  	item:play_song(music)
  	self:set_finished()
	end

	function item:play_song(music)
		local game = self:get_game()
  	local map = game:get_map()
   	local hero = map:get_hero()
  	local x,y,layer = hero:get_position()
    local music_volume = sol.audio.get_music_volume()

		sol.audio.set_music_volume(10)
 	  hero:freeze()
  	hero:set_animation("playing_ocarina")

		-- Wait for the hero animation
		sol.timer.start(map, 800, function()
			local notes = map:create_custom_entity{
				x = x,
				y = y,
				layer = layer + 1,
				width = 24,
				height = 32,
				direction = math.random(0,7),
				sprite = "entities/notes"
			}
			sol.audio.play_sound(properties.music)
			sol.timer.start(map, properties.duration, function()
				sol.audio.set_music_volume(music_volume)
	    	hero:unfreeze()
				hero:set_direction(3)
	    	notes:remove()
				if not game:is_in_dungeon() then
					-- Effect depending on song type
					if properties.type ~= "skip_dialogue" then
						game:start_dialog(properties.dialogue, function(answer)
							if answer == 1 then
								if properties.type == "teleportation" then
									hero:teleport(properties.destination_map, properties.destination)
								else
									properties.effect()
								end
							end
						end)
					elseif properties.type == "skip_dialogue" then
						if properties.type == "teleportation" then
							hero:teleport(properties.destination_map, properties.destination)
						else
							properties.effect()
						end
					end
				end
			end)
  	end)
	end

  function item:summon_bird()
    local game = self:get_game()
  	local map = game:get_map()
   	local hero = map:get_hero()
  	local x,y,layer = hero:get_position()
    local bird = map:create_custom_entity{
      name = "ocarina_bird",
      direction = 0,
      x = x - 160,
      y = y,
      layer = layer,
      width = 16,
      height = 16,
      sprite = "npc/zelda",
    }
    local bird_movement = sol.movement.create("target")
    bird_movement:set_target(hero)
    bird_movement:set_ignore_obstacles(true)
    bird_movement:set_speed(128)
    bird_movement:start(bird, function()
      
    end)
  end


end

return config