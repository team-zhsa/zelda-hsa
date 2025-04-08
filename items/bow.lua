-- Lua script of item "bow".
-- This script is executed only once for the whole game.

-- Variables
local item = ...
local game = item:get_game()
local audio_manager=require("scripts/audio_manager")

function item:on_created()

  self:set_savegame_variable("possession_bow")
  self:set_amount_savegame_variable("amount_bow")
  self:set_assignable(true)

  self:set_max_amount(30)
end

-- Event called when the hero is using this item.
function item:start_combo(other)

  local map=game:get_map()
--  debug_print ("trying to fire a combined arrow launch (arrows: "..item:get_amount()..", other: "..other:get_amount()..")")
  if item:get_amount() == 0 then

    if other.start_using then
      other:start_using()
    else
      audio_manager:play_sound("common/wrong")  
    end
  else
    -- we remove the arrow from the equipment after a small delay because the hero
    -- does not shoot immediately

    --TODO get rid of this useless timer once the bomb-arrow sprite is ready
    sol.timer.start(300, function()
        item:remove_amount(1)
      end)

    if other:get_name()=="bombs_counter" and other:get_amount()>0 then
      other:remove_amount(1)
--      debug_print "Bomb and arrows!"
      local hero=game:get_hero()
      local x,y,layer=hero:get_position()
      local ox, oy=hero:get_sprite("tunic"):get_xy()
      local direction = hero:get_direction()
      if direction == 0 then
        x = x + 16
        y = y - 7
      elseif direction == 1 then
        y = y - 16
      elseif direction == 2 then
        x = x - 16
        y = y - 7
      elseif direction == 3 then
        y = y + 16
      end

      map:create_custom_entity{
        name="bomb_arrow",
        x = x+ox,
        y = y+oy,
        layer = layer,
        width=8,
        height=8,
        sprite = "entities/bomb_arrow",
        model = "bomb_arrow",
        direction=direction,
      }
    else
      --Trigger normal arrow so we don't break the standard behavior
      item:get_map():get_entity("hero"):start_bow()
    end
  end
end

-- Using the bow.
function item:start_using()


  local map = game:get_map()
  local hero = map:get_hero()

  if self:get_amount() == 0 then
    sol.audio.play_sound("wrong")
--    self:set_finished()
  else
    hero:freeze()
    hero:set_animation("bow") --Hack, fixes invisible hero after firing

    sol.timer.start(hero, 290, function()
        audio_manager:play_sound("items/bow")
        self:remove_amount(1)
--        self:set_finished()
        hero:unfreeze()
        local x, y = hero:get_center_position()
        local ox, oy=hero:get_sprite("tunic"):get_xy()
        local _, _, layer = hero:get_position()
        local arrow = map:create_custom_entity({
            x = x+ox,
            y = y+oy,
            layer = layer,
            width = 16,
            height = 16,
            direction = hero:get_direction(),
            model = "arrow",
          })

        arrow:set_force(self:get_force())
        arrow:set_sprite_id(self:get_arrow_sprite_id())
        arrow:go()
      end)
  end
end

function item:on_using()
  item:start_using()
  item:set_finished()
end

-- Function called when the amount changes.
function item:on_amount_changed(amount)

  if self:get_variant() ~= 0 then
    -- update the icon (with or without arrow).
    if amount == 0 then
      self:set_variant(1)
    else
      self:set_variant(2)
    end
  end
end

function item:on_obtaining(variant, savegame_variable)

  local arrow = game:get_item("arrow")

  if variant > 0 then
    self:set_max_amount(30)
    -- Variant 1: bow without arrow.
    -- Variant 2: bow with arrows.
    if variant > 1 then
      self:set_amount(self:get_max_amount())
    end
    arrow:set_obtainable(true)
  else
    -- Variant 0: no bow and arrows are not obtainable.
    self:set_max_amount(0)
    arrow:set_obtainable(false)
  end
end

function item:get_force()

  return 2
end

function item:get_arrow_sprite_id()

  return "entities/arrow"
end

-- Initialise the metatable of appropriate entities to work with custom arrows.
local function initialise_meta()

  -- Add Lua arrow properties to enemies.
  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_arrow_reaction ~= nil then
    -- Already done.
    return
  end

  enemy_meta.arrow_reaction = "force"
  enemy_meta.arrow_reaction_sprite = {}
  function enemy_meta:get_arrow_reaction(sprite)

    if sprite ~= nil and self.arrow_reaction_sprite[sprite] ~= nil then
      return self.arrow_reaction_sprite[sprite]
    end

    if self.arrow_reaction == "force" then
      -- Replace by the current force value.
      local game = self:get_game()
      return game:get_item("bow"):get_force()
    end

    return self.arrow_reaction
  end

  function enemy_meta:set_arrow_reaction(reaction)

    self.arrow_reaction = reaction
  end

  function enemy_meta:set_arrow_reaction_sprite(sprite, reaction)

    self.arrow_reaction_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also
  -- take into account arrows.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_arrow_reaction("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_arrow_reaction_sprite(sprite, "ignored")
  end
end

initialise_meta()
