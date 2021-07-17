local config = {}

function config:create(item, properties)
  local bird = nil

	function item:on_created()
  	self:set_savegame_variable(properties.savegame_variable)
  	self:set_assignable(true)
	end

	function item:playing_song(music)
		local game = self:get_game()
    local map = self:get_map()
  	local map = game:get_map()
   	local hero = map:get_hero()
  	local x,y,layer = hero:get_position()


		sol.audio.set_music_volume(10)
 	  hero:freeze()
  	hero:set_animation("playing_ocarina")
  	local notes = map:create_custom_entity{
    	x = x,
 	   	y = y,
  	  layer = layer + 1,
 		  width = 24,
  	  height = 32,
  	  direction = 0,
  	  sprite = "entities/notes"
	  }
		sol.audio.play_sound(properties.music)
		sol.timer.start(map, properties.duration, function()
			sol.audio.set_music_volume(75)
    	hero:unfreeze()
			hero:set_direction(3)
    	notes:remove()
			if not game:is_in_dungeon() then
				game:start_dialog(properties.dialogue, function(answer)
					if answer == 1 then
            hero:teleport(properties.destination_map, properties.destination)
					else
  					item:set_finished()
					end
				end)
			end			
  	end)
	end

  function item:summon_bird()
    local game = self:get_game()
    local map = self:get_map()
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

	function item:on_using()
  	item:playing_song(music)
  	self:set_finished()
	end
end

return config