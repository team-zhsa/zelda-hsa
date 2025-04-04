-- Lua script of item "magic powder".
-- This script is executed only once for the whole game.

-- Variables
local item = ...
local audio_manager = require("scripts/audio_manager")
-- Event called when the game is initialized.
function item:on_created()

  self:set_savegame_variable("possession_magic_powder")
  self:set_brandish_when_picked(false)
end

-- Event called when the hero is using this item.
function item:on_using()
  self:set_finished()
end

-- Initialize the metatable of appropriate entities to be able to set a reaction on magic powder.
local function initialize_meta()

  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_magic_powder_reaction then
    return
  end

  enemy_meta.magic_powder_reaction = "ignored"  -- Nothing happens by default.
  enemy_meta.magic_powder_reaction_sprite = {}

  function enemy_meta:get_magic_powder_reaction(sprite)
    if sprite and self.magic_powder_reaction_sprite[sprite] then
      return self.magic_powder_reaction_sprite[sprite]
    end
    return self.magic_powder_reaction
  end

  function enemy_meta:set_magic_powder_reaction(reaction, sprite)
    self.magic_powder_reaction = reaction
  end

  function enemy_meta:set_magic_powder_reaction_sprite(sprite, reaction)
    self.magic_powder_reaction_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also
  -- take into account the feather.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_magic_powder_reaction("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_magic_powder_reaction_sprite(sprite, "ignored")
  end
end
initialize_meta()
