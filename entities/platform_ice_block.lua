--[[
  A simple ice block.
  
  If you touch it on the side, then you'll be frozen! (only triggers the message the first time per map visit)
  You can melt it using the Fire rod (or any item, actually, since the only thing to do is to call entity:melt())
  
--]]

local entity = ...
local map = entity:get_map()
local game = entity:get_game()
local hero = map:get_hero()
local audio_manager = require("scripts/audio_manager")

local frozen=false
function entity:on_created()
  entity:set_traversable_by(true)
  entity:set_traversable_by("hero", false)
  entity:set_traversable_by("enemy", false)
  self:get_sprite():set_animation("normal")
end

function entity:melt()
  local sprite=entity:get_sprite()
  sprite:set_animation("destroy", function()
      entity:remove()
    end)
end


entity:add_collision_test(
  function(entity, other)
    local x,y,w,h=entity:get_bounding_box()
    local hx, hy, hw, hh=hero:get_bounding_box()
    return other:get_type()=="hero" and hx<x+w+1 and hx+hw>x-1 and hy<=y+h-1 and hy+hh>=y+1 
  end, function(entity, hero)
    --Freeze the hero!
    if not(map.already_been_frozen) then
      hero.frozen = true
      map.already_been_frozen=true
      local sprite = hero:get_sprite("tunic")
      sprite:set_animation("cold_link")
      sprite:set_ignore_suspend(true)
      game:start_dialog("_frozen_by_ice_block", function()
          hero.frozen = false
          sprite:set_ignore_suspend(false)
        end)
    end
  end)
