--[[
  Lua script of item "pegasus shoes".
  
  This newer version uses plainly the new global command overrides as it depends on not triggering the "item" state
   Because of that, it must **NEVER** be triggered using the built-in method or else it will never finish and sftlock your game.
  The reason is that it would end any custon jumping state, which do trigger when jumping when running, with pontential bad consequences, such as falling into a pit while mid-air
  
  Dependencies :
    - Multi-event script;
    - Custon running state script (see below for exact script names)
  
  Addendum: item:on_using() is included regardless to not get softlocked when put in a quest without said combo system. 
  
--]]
-- Variables
local item = ...

-- Include scripts
local audio_manager = require("scripts/audio_manager")
require("scripts/multi_events")
require("scripts/states/running")

-- Event called when the game is initialised.
function item:on_created()
  self:set_savegame_variable("possession_pegasus_shoes")
  self:set_sound_when_brandished(nil)
  self:set_assignable(false)
  local game = self:get_game()
  game:set_ability("jump_over_water", 0) -- Disable auto-jump on water border.
end

local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", function(game)
  game:register_event("on_command_pressed", function(game, command) -- Trigger running with action
    -- Note : there is no "item_X" command check here, since this item has been integrated into the new global command override system.
    if not game:is_suspended() then
      if command == "action" then
        if game:get_command_effect("action") == nil and game:has_item("pegasus_shoes") then
          local hero=game:get_hero()
          local entity=hero:get_facing_entity()

          if entity and entity:get_type()=="custom_entity" and entity:get_model() == "npc" then -- Special case for the custom NPC entity, because it could not interact with
            return
          end

          local offsets = { {1, 0}, {0, -1}, {-1, 0}, {0, 1} }
          local state = hero:get_state()
          if hero:test_obstacles(unpack(offsets[hero:get_direction() + 1])) or state == "frozen" or state == "swimming" or state == "custom" and not hero:get_state_object():get_can_use_item("pegasus_shoes") then
            return
          end
          -- Call custom run script.
          game:get_hero():run()
          return true
        end
      end
    end
  end)

  game:register_event("on_joypad_button_pressed", function(game, button)
    -- Note : there is no "item_X" command check here, since this item has been integrated into the new global command override system.
    if not game:is_suspended() then
      if button == 5 or button == 7 and game:has_item("pegasus_shoes") then
          local hero=game:get_hero()
          local entity=hero:get_facing_entity()

          if entity and entity:get_type()=="custom_entity" and entity:get_model() == "npc" then -- Special case for the custom NPC entity, because it could not interact with
            return
          end

          local offsets = { {1, 0}, {0, -1}, {-1, 0}, {0, 1} }
          local state = hero:get_state()
          if hero:test_obstacles(unpack(offsets[hero:get_direction() + 1])) or state == "frozen" or state == "swimming" or state == "custom" and not hero:get_state_object():get_can_use_item("pegasus_shoes") then
            return
          end
          -- Call custom run script.
          game:get_hero():run()
          return true
      end
    end
  end)
end)

function item:start_using()
  item:get_game():get_hero():run()
end

function item:on_using()
  item:start_using()
  item:set_finished()
end

function item:on_obtaining()
  audio_manager:play_sound("items/major_item")
end

-- initialise the metatable of appropriate entities to work with pegasus shoes.
local function initialise_meta()

  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_thrust_reaction ~= nil then
    return
  end

  enemy_meta.thrust_reaction = 2  -- 2 life points by default.
  enemy_meta.thrust_reaction_sprite = {}

  function enemy_meta:get_thrust_reaction(sprite)
    if sprite ~= nil and self.thrust_reaction_sprite[sprite] ~= nil then
      return self.thrust_reaction_sprite[sprite]
    end
    return self.thrust_reaction
  end

  function enemy_meta:set_thrust_reaction(reaction)
    self.thrust_reaction = reaction
  end

  function enemy_meta:set_thrust_reaction_sprite(sprite, reaction)
    self.thrust_reaction_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also
  -- take into account the thrust.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_thrust_reaction("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_thrust_reaction_sprite(sprite, "ignored")
  end
end

initialise_meta()
