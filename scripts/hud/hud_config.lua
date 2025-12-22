-- Defines the elements to put in the HUD
-- and their position on the game screen.

-- You can edit this file to add, remove or move some elements of the HUD.

-- Each HUD element script must provide a method new()
-- that creates the element as a menu.
-- See for example scripts/hud/hearts.lua.

-- Negative x or y coordinates mean to measure from the right or bottom
-- of the screen, respectively.

local hud_config = {

	-- Hearts meter.
	{
		menu_script = "scripts/hud/hearts",
		x = 4,
		y = 4,
	},

	-- Magic bar.
	{
		menu_script = "scripts/hud/magic_bar",
		x = 4,
		y = 14,
	},

	-- Rupee counter.
	{
		menu_script = "scripts/hud/rupees",
		x = 4,
		y = -16,
	},

	-- Clock icon.
	{
		menu_script = "scripts/hud/clock",
		x = -30,
		y = -2,
	},

	-- Small key counter.
	{
		menu_script = "scripts/hud/small_keys",
		x = 4,
		y = -28,
	},

	-- Floor view.
	{
		menu_script = "scripts/hud/floor",
		x = 4,
		y = 70,
	},

	--[[ Pause icon.
	{
		menu_script = "scripts/hud/pause_icon",
		x = -126,
		y = 10,
	}, --]]




	-- Item icon for slot 1.
	{
		menu_script = "scripts/hud/item_icon",
		x = -76,
		y = 4,
		slot = 1,  -- Item slot (1 or 2).
	},

	-- Item icon for slot 2.
	{
		menu_script = "scripts/hud/item_icon",
		x = -28,
		y = 4,
		slot = 2,  -- Item slot (1 or 2).
	},

	-- Attack icon.
	{
		menu_script = "scripts/hud/attack_icon",
		x = -52,
		y = 16,
	},
	
		-- Action icon.
	{
		menu_script = "scripts/hud/action_icon",
		x = -102,
		y = 16,
	},

}

return hud_config