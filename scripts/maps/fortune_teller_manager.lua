local fortune_teller = {}

function fortune_teller:talk(map)

	local game = map:get_game()
	local hero = map:get_hero()
	local phone = map:get_entity("phone")
	local phone_sprite = phone:get_sprite()
	local messages = require("scripts/maps/lib/fortune_teller_config")
	local message_key = 1
	-- We go through the list of companions
	for key, params in ipairs(messages) do
		if params.activation_condition ~= nil and params.activation_condition(map) then
			message_key = params.message_key
		end
	end
	game:start_dialog("maps.fortune_teller.fortune_question", function(answer)
		if answer == 1 then
			if game:get_money() < 60 then
				game:start_dialog("maps.houses.fortune_teller.fortune_not_enough_money")
			else
				game:start_dialog("maps.houses.fortune_teller." .. message_key, function() 
					game:start_dialog("maps.houses.fortune_teller.fortune_pay")
				end)  
			end
		else game:start_dialog("maps.houses.fortune_teller.fortune_no")
		end
	end)
end

return fortune_teller