local item = ...

sol.main.load_file("script/ocarina/ocarina")(script)

function item:on_created()
  self:set_savegame_variable("has_ocarina")
  self:set_assignable(true)
end

function item:on_used()

local ocarina = {}

function ocarina:on_key_pressed(key, modifiers)

  local handled = true
  if key == "f" then
  sol.audio.play_sound("secret")
    else
      -- Not a known in-game  key.
      handled = false
    end
  else
    -- Not a known key.
    handled = false
  end

  return handled
end

end