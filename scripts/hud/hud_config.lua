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
    x = 6,
    y = 6,
  },

  -- Magic bar.
  {
    menu_script = "scripts/hud/magic_bar",
    x = 6,
    y = 24,
  },


  -- Rupee counter.
  {
    menu_script = "scripts/hud/rupees",
    x = 8,
    y = -20,
  },

  -- Small key counter.
  {
    menu_script = "scripts/hud/small_keys",
    x = -36,
    y = -18,
  },

  -- Floor view.
  {
    menu_script = "scripts/hud/floor",
    x = 5,
    y = 70,
  },

  -- Pause icon.
  {
    menu_script = "scripts/hud/pause_icon",
    x = -170,
    y = 6,
  },

  -- Item icon for slot 1.
  {
    menu_script = "scripts/hud/item_icon",
    x = -95,
    y = 6,
    slot = 1,  -- Item slot (1 or 2).
  },

  -- Item icon for slot 2.
  {
    menu_script = "scripts/hud/item_icon",
    x = -45,
    y = 6,
    slot = 2,  -- Item slot (1 or 2).
  },

  -- Attack icon.
  {
    menu_script = "scripts/hud/attack_icon",
    x = -94,
    y = 20,
  },

  -- Action icon.
  {
    menu_script = "scripts/hud/action_icon",
    x = -145,
    y = 20,
  },

  -- Clock icon.
  {
    menu_script = "scripts/hud/clock",
    x = -32,
    y = -64,
  },

}

return hud_config
