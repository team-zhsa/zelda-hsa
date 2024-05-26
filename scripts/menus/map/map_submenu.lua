-- Base class of each submenu.
local submenu = {}
function submenu:new(game)
  local o = { game = game }
  setmetatable(o, self)
  self.__index = self
  return o
end
function submenu:on_command_pressed(command)
  local handled = false
  if self.game:is_dialog_enabled() then
    -- Commands will be applied to the dialog box only.
    return false
  end
  return handled
end
return submenu