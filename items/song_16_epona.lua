local item = ...
local game = item:get_game()

function item:on_created()
  self:set_savegame_variable("possession_song_16")
  self:set_assignable(true)
end

function item:playing_song(music)
		local game = self:get_game()
    local map = self:get_map()
  	local map = game:get_map()
   	local hero = map:get_hero()
  	local x,y,layer = hero:get_position()



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
		sol.audio.play_sound("items/ocarina/song/16_epona")
		sol.timer.start(map, 7000, function()
    	hero:unfreeze()
			hero:set_direction(3)
    	notes:remove()		
  	end)
	end


	function item:on_using()
  	item:playing_song(music)
  	self:set_finished()
	end
