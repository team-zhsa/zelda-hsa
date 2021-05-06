-- Usage :
-- require("scripts/maps/temperature_manager")
--
-- your_map:set_temperature(0)  -- Cold
-- your_map:set_temperature(1)  -- Normal
-- your_map:set_temperature(2)  -- Hot

local temperature_manager = {}

require("scripts/multi_events")

local map_meta = sol.main.get_metatable("map")
local game_meta = sol.main.get_metatable("game")

local function dark_map_on_draw(map, dst_surface)


	if map:get_temperature() == 1 then
      -- Normal temperature: nothing special to do.
    return
	elseif map:get_temperature() == 0 then
		local function hurt_cold()
			if map:get_game():get_ability("tunic") ~= 2 then
				sol.timer.start(map, 2000, function()
					map:get_hero():start_hurt(4)
					hurt_cold()
				end)
			else return
			end
		end
		if map:get_game():get_ability("tunic") ~= 2 then
			hurt_cold()
		end
  end

end

function map_meta:get_temperature()

  return self.temperature
end

function map_meta:set_temperature(temperature)
  
  self.temperature = temperature



  self:register_event("on_started", dark_map_on_draw)
end

-- Function called by the torch script when a torch state has changed.


return temperature_manager
