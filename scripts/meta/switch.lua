-- initialise switch behavior specific to this quest.

-- Variables
local switch_meta = sol.main.get_metatable("switch")

-- Include scripts
local audio_manager = require("scripts/audio_manager")

function switch_meta:on_activated()
    
  audio_manager:play_sound("misc/dungeon_switch")

  if self:get_property("is_lever") == "true" then
    self:get_sprite():set_direction(1 - self:get_sprite():get_direction())

    -- Allow to activate it again.
    sol.timer.start(self, 1000, function()
      self:set_activated(false)
    end)
  end

end
