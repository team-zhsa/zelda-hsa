-- Defines the menus displayed when executing the quest,
-- before starting a game.

-- You can edit this file to add, remove or move some pre-game menus.
-- Each element must be the name of a menu script.
-- The last menu is supposed to start a game.

local initial_menus = {
  "scripts/menus/initial_menus/solarus_logo",
  "scripts/menus/initial_menus/team_logo",
  "scripts/menus/initial_menus/copyright_notice", 
  "scripts/menus/initial_menus/language",
  "scripts/menus/initial_menus/title", 
  "scripts/menus/initial_menus/savegames",
}

return initial_menus
