----------------------------------
--
-- Shield.
--
-- Protect against enemies if the shield collide with a given enemy and the shield variant is high enough for him.
-- Prevent calling the enemy:on_attacking_hero() event if defined and the hero is protected by the shield.
--
-- Methods : item:stop_using()
--           hero:is_shield_protecting(enemy, [enemy_sprite])
--           enemy:get_shield_minimum_level()
--           enemy:set_shield_minimum_level(level)
--           enemy:get_shield_reaction([sprite])
--           enemy:set_shield_reaction(reaction)
--           enemy:set_shield_reaction_sprite(sprite, reaction)
--
----------------------------------

local item = ...
local audio_manager = require("scripts/audio_manager")
local shield_level = 2
require("scripts/multi_events")
require("scripts/ground_effects")

-- Update the sprite z-index regarding the entity depending on direction.
local function update_z_index(entity, sprite)

  if entity:get_direction() == (item.is_used and 1 or 2) then
    entity:bring_sprite_to_back(sprite)
  else
    entity:bring_sprite_to_front(sprite)
  end
end

-- Set grabing abilities level.
local function set_grabing_abilities_level(level)

  local game = item:get_game()
  for _, ability in pairs({"push", "grab", "pull"}) do
    game:set_ability(ability, level)
  end
end

-- Set the shield sprite id
local function set_shield_sprite_id(sprite_id)
  local game = item:get_game()
  local hero = game:get_hero()
  local map = hero:get_map()
    hero:set_shield_sprite_id(sprite_id)


  -- Update z-index on direction changed.
  local sprite = hero:get_sprite("shield")
  function sprite:on_direction_changed()
    update_z_index(hero, sprite)
  end

  update_z_index(hero, sprite)

  -- Move the sprite offset in sideview maps to match the hero sideview offset.
  sprite:set_xy(0, 0)


  return sprite
end

-- Initialize the item.
item:set_savegame_variable("possession_shield_hero")
function item:on_created()

  item:on_variant_changed(item:get_variant())
  item:set_sound_when_brandished(nil)
  item.is_used = false -- Workaround : item:is_being_used() seems buggy when item:set_finished() is called outside item:on_using(), use a flag instead

  -- Setup shield if assigned when the first map starts.
  -- Workaround : No event to do it only when first map starts, do it in on_map_changed.
  local game = item:get_game()
  game:register_event("on_map_changed", function(game, map)

    if game:get_ability("shield") > 0 and not item.is_used then
      set_shield_sprite_id("hero/shield" .. shield_level.. "_assigned")
    end
  end)
end

-- Set the item assignable if possessed.
function item:on_variant_changed(variant)

  item:set_assignable(variant > 0)
end

-- Play sound on obtaining.
function item:on_obtaining()
  local game = item:get_game()
  audio_manager:play_sound("items/fanfare_item_extended")
  game:set_item_assigned(1, item)
  game:set_ability("shield", shield_level)
  set_shield_sprite_id("hero/shield" .. shield_level.. "_assigned")
end

-- Carry the shield when assigned.
function item:on_assigned()
  local game = item:get_game()
  local hero = game:get_hero()
  game:set_ability("shield", shield_level)
  set_shield_sprite_id("hero/shield" .. shield_level.. "_assigned")
  hero:unfreeze() -- Make the shield sprite appear right now.
end

-- Take off the shield when unassigned.
function item:on_unassigned()
  local game = item:get_game()
  local hero = game:get_hero()
  game:set_ability("shield", 0)
  hero:set_shield_sprite_id("")
  item:set_finished()
end

-- Start using the shield.
function item:on_using()

  local game = item:get_game()
  local hero = game:get_hero()
  local map = self:get_map()
  local hero_state_object = hero:get_state_object()
  local hero_sprite = hero:get_sprite()
  local variant = item:get_variant()

  -- Don't continue if the hero have no shield or can't use it.
  local is_shield_usable = hero_state_object and not hero_state_object:get_can_use_item("shield_hero")
  if variant == 0 or is_shield_usable or game:is_suspended() or not map:is_solid_ground(hero:get_ground_position()) then
    return
  end
  item.is_used = true

  -- Initialize the state.
  set_shield_sprite_id("hero/shield" .. shield_level)
  hero:unfreeze() -- Allow the hero to walk.
  set_grabing_abilities_level(0)
  audio_manager:play_sound("items/shield")

  -- Behavior while the shield is brandished.
  local slot = game:get_item_assigned(1) == item and 1 or 2
  local command = "item_" .. slot
  sol.timer.start(item, 10, function()

    -- Check collision with enemies.
    local map = item:get_map() -- Update map in case it changes while holding the shield.
    for enemy in map:get_entities_by_type("enemy") do
      if hero:is_shield_protecting(enemy) then
        enemy:receive_attack_consequence("shield", enemy:get_shield_reaction())
      end
    end

    -- Stop using the shield when the command is released or no more assigned.
    if not game:is_command_pressed(command) or not game:get_item_assigned(slot) == item then
      item:stop_using()
      return
    end
    return true
  end)
end

-- Stop using the shield.
-- Workaround : No event called when the item finished being used, use this method instead of item:set_finished()
function item:stop_using()

  if not item.is_used then
    return
  end
  item.is_used = false

  local game = item:get_game()
  local hero = game:get_hero()
  
  set_shield_sprite_id("hero/shield" .. shield_level.. "_assigned")
  hero:unfreeze() -- Resynchronize hero sprites.
  item:set_finished()
  set_grabing_abilities_level(1)
end
-- Workaround: The built-in method seems to return true even after item:set_finished() is called, return item.is_used instead.
function item:is_being_used()
  return item.is_used
end

-- Initialise the metatable of hero entity.
local function initialise_hero_meta()

  local hero_meta = sol.main.get_metatable("hero")
  if hero_meta.is_shield_protecting then
    return
  end

  -- True if there is a pixel collision between the shield and the given enemy, and if the shield is strong enough and not ignored by the enemy.
  function hero_meta:is_shield_protecting(enemy, enemy_sprite)
    local item = self:get_game():get_item("shield_hero")
    local is_strong_enough = shield_level >= enemy:get_shield_minimum_level()
    local is_not_ignored = enemy:get_shield_reaction(enemy_sprite) ~= "ignored"
    local is_collision = enemy:overlaps(self, enemy:get_attacking_collision_mode(), enemy_sprite, self:get_sprite("shield"))
    return item.is_used and is_strong_enough and is_not_ignored and is_collision
  end

  -- Hide and show the shield during forbidden passive states.
  hero_meta:register_event("on_passive_state_started", function(hero, state_name)
    if state_name == "sideview_swimming" and hero:get_game():get_ability("shield") > 0 then
      hero:get_sprite("shield"):set_opacity(0)
    end
  end)
  hero_meta:register_event("on_passive_state_stopped", function(hero, state_name)
    if state_name == "sideview_swimming" and hero:get_game():get_ability("shield") > 0 then
      hero:get_sprite("shield"):set_opacity(255)
    end
  end)
end

-- Initialise the metatable of enemy entities to be able to set a reaction on protecting shield.
local function initialise_enemy_meta()

  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_shield_reaction then
    return
  end

  -- Minimum level of the shield to trigger reaction on an enemy.
  enemy_meta.shield_minimum_level = 1 -- Sensitive to level 1 shield by default.
  function enemy_meta:get_shield_minimum_level()
    return self.shield_minimum_level
  end

  function enemy_meta:set_shield_minimum_level(level)
    self.shield_minimum_level = level
  end

  -- Shield reactions.
  enemy_meta.shield_reaction = "protected" -- Protected by default.
  enemy_meta.shield_reaction_sprite = {}

  function enemy_meta:get_shield_reaction(sprite)
    if sprite and self.shield_reaction_sprite[sprite] then
      return self.shield_reaction_sprite[sprite]
    end
    return self.shield_reaction
  end

  function enemy_meta:set_shield_reaction(reaction)
    self.shield_reaction = reaction
  end

  function enemy_meta:set_shield_reaction_sprite(sprite, reaction)
    self.shield_reaction_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also
  -- take into account the shield.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_shield_reaction("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_shield_reaction_sprite(sprite, "ignored")
  end
end

initialise_hero_meta()
initialise_enemy_meta()
