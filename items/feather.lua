--[[

  Lua script of item feather.

  This newer version uses plainly the new global command overrides as it depends on not triggering the "item" state.
  Because of that, it must **NEVER** be triggered using the built-in method or else it will never finish and sftlock your game.
  The reason is that it would end any custon jumping state, with bad consequences, such as falling into a pit while mid-air
  v1.0 was made by Diarandor, but had major flaws, such as being overcomplicated.
  v2.0 was my first attempt to handle custom jumps. it woked, was fairly simple, but sword jumping -> hand-free jump chaining was buggy and proved the way it was handled jusr didn't work
  v3.0 (current, experimantal): in top-view maps, we now entirely delegate the jump states management to the jump manager, isntead of lettgin each state decide what to do next.
  
--]]
local hero_meta = sol.main.get_metatable("hero")
local item = ...
local game = item:get_game()

-- Include scripts
local audio_manager = require("scripts/audio_manager")
local jump_manager = require("scripts/maps/jump_manager")
require("scripts/multi_events")

-- Event called when the game is initialized.
function item:on_started()
  
  item:set_savegame_variable("possession_feather")
  item:set_sound_when_brandished(nil)
  item:set_assignable(true)
  
end

local game_meta = sol.main.get_metatable("game")

-- This function is called when the item command is triggered. It is similar to item:on_using, without state changing.
function item:start_using()
  local map = game:get_map()
  local hero = map:get_hero()

  if not hero:is_jumping() then

      jump_manager.start(hero) -- Running jump

  end

end

function item:on_using()
  item:start_using()
  item:set_finished()
end

-- Play fanfare sound on obtaining.
function item:on_obtaining()
  audio_manager:play_sound("common/major_item")
end

-- Initialize the metatable of appropriate entities to be able to set a reaction on jumped on.
local function initialize_meta()

  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_jump_on_reaction then
    return
  end

  enemy_meta.jump_on_reaction = "ignored"  -- Nothing happens by default.
  enemy_meta.jump_on_reaction_sprite = {}

  function enemy_meta:get_jump_on_reaction(sprite)
    if sprite and self.jump_on_reaction_sprite[sprite] then
      return self.jump_on_reaction_sprite[sprite]
    end
    return self.jump_on_reaction
  end

  function enemy_meta:set_jump_on_reaction(reaction, sprite)
    self.jump_on_reaction = reaction
  end

  function enemy_meta:set_jump_on_reaction_sprite(sprite, reaction)
    self.jump_on_reaction_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also
  -- take into account the feather.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_jump_on_reaction("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_jump_on_reaction_sprite(sprite, "ignored")
  end
end
initialize_meta()