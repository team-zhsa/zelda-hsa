-- Script to draw basic text strokes and shadows in pure Lua.
-- Usage:
-- require("scripts/text_fx_helper")

local text_fx_helper = {}
local language_manager = require("scripts/language_manager")
local text_utils = require("scripts/tools/text_utils")
-- Creates a text_surface with all same properties except the color. 
local function copy_text_surface(src_text_surface, new_color, type)
  -- Create a text surface with the shadow color.

  local new_surface
    if type == "dialogue" then
      new_surface = sol.text_surface.create{
        horizontal_alignment = src_text_surface:get_horizontal_alignment(),
        vertical_alignment = src_text_surface:get_vertical_alignment(),
        font = src_text_surface:get_font() .. "_blue",
        font_size = src_text_surface:get_font_size(),
        text = src_text_surface:get_text(),
        color = new_color,
      }
    elseif type == "hud" then
      new_surface = sol.text_surface.create{
        horizontal_alignment = src_text_surface:get_horizontal_alignment(),
        vertical_alignment = src_text_surface:get_vertical_alignment(),
        font = src_text_surface:get_font() .. "_black",
        font_size = src_text_surface:get_font_size(),
        text = src_text_surface:get_text(),
        color = new_color,
      }
    else
      new_surface = sol.text_surface.create{
        horizontal_alignment = src_text_surface:get_horizontal_alignment(),
        vertical_alignment = src_text_surface:get_vertical_alignment(),
        font = src_text_surface:get_font(),
        font_size = src_text_surface:get_font_size(),
        text = src_text_surface:get_text(),
        color = new_color,
      }
    end
  return new_surface
end

-- Draws the 8 components composing the stroke.
local function draw_stroke_components(dst_surface, text_surface, x, y, delta)
  text_surface:draw(dst_surface, x - delta, y)
  text_surface:draw(dst_surface, x - delta, y - delta)
  text_surface:draw(dst_surface, x - delta, y + delta)
  text_surface:draw(dst_surface, x + delta, y)
  text_surface:draw(dst_surface, x + delta, y - delta)
  text_surface:draw(dst_surface, x + delta, y + delta)
  text_surface:draw(dst_surface, x, y - delta)
  text_surface:draw(dst_surface, x, y + delta)
end

-- Draws only the stroke.
function text_fx_helper:draw_text_stroke(dst_surface, text, stroke_color, x, y, type)
  -- Create a text surface with the stroke color.
    local text_stroke = copy_text_surface(text, stroke_color, type)
  -- Draw the 8 texts composing the stroke.
  if x == nil or y == nil then
    local stroke_x, stroke_y = text:get_xy()
    draw_stroke_components(dst_surface, text_stroke, stroke_x, stroke_y, 1)
  else draw_stroke_components(dst_surface, text_stroke, x, y, 1) end
end

-- Draws the text with a stroke.
function text_fx_helper:draw_text_with_stroke(dst_surface, text, stroke_color, x, y, type)
  -- Draw the stroke with the stroke color.
    self:draw_text_stroke(dst_surface, text, stroke_color, x, y, type)

  -- Draw text above the stroke.
  text:draw(dst_surface)
end

-- Draws the text with a shadow.
function text_fx_helper:draw_text_with_shadow(dst_surface, text, shadow_color)
  -- Draw the stroke with the stroke color.
  self:draw_text_shadow(dst_surface, text, shadow_color)

  -- Draw text above the stroke.
  text:draw(dst_surface)
end

-- Draws only the shadow.
function text_fx_helper:draw_text_shadow(dst_surface, text, shadow_color)
  -- Create a text surface with the shadow color.
  local text_shadow = copy_text_surface(text, shadow_color)

  -- Draw the text composing the shadow.
  local x, y = text:get_xy()
  text_shadow:draw(dst_surface, x, y + 1)
end

-- Draws only the stroke and the shadow.
function text_fx_helper:draw_stroke_and_shadow(dst_surface, text, stroke_color, shadow_color)
  local x, y = text:get_xy()

  -- Shadow
  local text_shadow = copy_text_surface(text, shadow_color)
  draw_stroke_components(dst_surface, text_shadow, x, y + 1, 1)

  -- Stroke
  local text_stroke = copy_text_surface(text, stroke_color)
  draw_stroke_components(dst_surface, text_stroke, x, y, 1)

end

-- Draws the text with the stroke and the shadow.
function text_fx_helper:draw_text_with_stroke_and_shadow(dst_surface, text, stroke_color, shadow_color)
  self:draw_stroke_and_shadow(dst_surface, text, stroke_color, shadow_color)
  text:draw(dst_surface)
end

return text_fx_helper