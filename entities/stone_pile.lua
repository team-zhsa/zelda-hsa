local entity = ...
local game = entity:get_game()
local map = game:get_map()
local name = entity:get_name()
local hero = map:get_hero()

-- Stone pile: a pile of stones which can be
-- blown apart by a bomb or the hero running into it.

function entity:on_created()
  local sprite = self:get_sprite()
  self:set_size(32, 32)
  self:set_origin(8, 13)
  self:set_traversable_by(false)
  
  self:add_collision_test("touching", function(self, other)
    if other:get_type() == "hero" and hero:get_state() == "custom" and hero:is_running() then
      sprite:set_animation("destroy")
      self:clear_collision_tests()
    end
  end)

  function sprite:on_animation_finished(animation)
    if animation == "destroy" then
			entity:remove()
      sol.audio.play_sound("common/secret_discover_minor")
			local bg_name = name:match("^rockstack_([a-zA-X0-9_]+)_background")
  		if bg_name ~= nil then
    		local bg = map:get_entity(bg_name)
    			if bg ~= nil then
        		bg:set_enabled(false)
      		end
    	end
		end
  end
end