-- Map menu (now called from debug with F)

require("scripts/multi_events")
local map_menu = {}
local world_map_img = sol.surface.create("maps/minimap.png")
sol.main.load_file("scripts/game_manager")(game)

local game = ...
function map_menu:new(game)
  
  local o = { game = game }
  setmetatable(o, self)
  self.__index = self
  return o
end


function map_menu:on_started(game)
	game:set_suspended(true)
end

function map_menu:on_finished(game)
	self.enabled = false
	game:set_suspended(false)
end

function map_menu:on_draw(dst_surface)
	world_map_img:draw(dst_surface, 0, 0)
	self.enabled = true
	
end

function map_menu:on_key_pressed(key, modifiers)
  if key == "f" and self.enabled then
    sol.menu.stop(self)
	end
end
		


return map_menu