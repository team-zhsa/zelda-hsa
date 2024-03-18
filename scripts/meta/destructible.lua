-- initialise destructible behavior specific to this quest.

-- Variables
local destructible_meta = sol.main.get_metatable("destructible")

-- Include scripts
local audio_manager = require("scripts/audio_manager")
local custom_ground_entity

function destructible_meta:on_created(game)

  -- TODO destruction sounds
  local directory = audio_manager:get_directory()
  if self:get_can_be_cut() then
    --self:set_destruction_sound(directory .. "/misc/bush_cut") -- Todo
  else
    --self:set_destruction_sound(directory .. "/misc/rock_shatter") -- Todo
  end

end

function destructible_meta:on_lifting(carrier, carried_object)
  debug_print("Lifting some destructible")
  carried_object:set_properties(self:get_properties())
end

function destructible_meta:on_looked()

  -- Here, self is the destructible object.
  local game = self:get_game()
  local sprite = self:get_sprite()
  if self:get_weight() > 0 and self:get_weight() > game:get_ability('lift')   then
    if game:get_ability('lift') == 1 then
      game:start_dialog("_cannot_lift_too_heavy");
    else
      game:start_dialog("_cannot_lift_still_too_heavy");
    end
  end

end


function destructible_meta:is_hookable()

  local ground = self:get_modified_ground()
  local sprite = self:get_sprite()
  local sprite_name = sprite:get_animation_set()
  if ground == "traversable" or ground == "grass" or sprite_name == "entities/destructibles/bush" then
    return false
	else
  	return true
	end
end