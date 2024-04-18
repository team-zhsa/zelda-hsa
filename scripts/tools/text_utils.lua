local tu = {}

-- make a line wrapping predicate from a max width in pixels, a font id, and a font_size
function tu.sol_text_wrap_predicate(max_width, font, font_size)
  return function(text)
    local prw,prh = sol.text_surface.get_predicted_size(font, font_size, text)
    return prw <= max_width
  end
end

-- make a mono wrapping predicate from a max character_count
function tu.mono_wrap_predicate(character_count)
  return function(text)
    return #text < character_count
  end
end

function tu.sol_text_wrap_with_icons_predicate(max_width, font, font_size, num_spaces)
  num_spaces = num_spaces or 3
  local holder = string.rep(" ", num_spaces)
  return function(text)
    local ttext = text:gsub("%[[^%[%]]*%]", holder)
    local prw,prh = sol.text_surface.get_predicted_size(font, font_size, ttext)
    return prw <= max_width
  end
end

----------------------------------------
-- return an iterator of lines from a single line text

-- example :
-- `tu.word_wrap("long test ... phrase",tu.sol_text_wrap_predicate(300,"font_id",font_size))`
----------------------------------------
function tu.word_wrap(text, predicate)
  local words = text:gmatch("%S+ *[!;:?]*")
  local last = ''
  local space = ''
  return iter(function()
    local line = last
    for w in words do
      w = w:gsub("%s+$", "") -- remove space at word end
      local new_line = line .. space .. w
      if not predicate(new_line) then
        last = w
        return line
      end
      line = new_line
      space = ' '
    end
    --no more words
    if last then
      last = nil
      return line
    end
  end)
end

----------------------------------------------------------------
-- Transform an iterator of line so that blank lines are added
-- to create page break
----------------------------------------------------------------
function tu.page_breaker(iterator, line_base, pattern)
  local pattern = pattern  or "%$pb"
  
  local line_index = 0 --state of the iterator
  local breaking = false
  local last_line
  return function()
    if breaking and line_index % line_base ~= 0 then
      line_index = line_index + 1
      return "" -- yield empty lines as long as we are not on a new page
    end
    
    breaking = false --reset breaking state
    
    local line = iterator()
    
    if line and line:match(pattern) then
      line = line:gsub(pattern, "")
      breaking = true;
    end
    
    line_index = line_index + 1
    return line
  end
end

------------------------------------------------------------------------------------------------
-- Text surface wrapper that adds support for icons in text
------------------------------------------------------------------------------------------------
local text_surface_mt = {}
text_surface_mt.__index = text_surface_mt
local icon_space_width = 4

function text_surface_mt:set_text(text)
  self.text = text
  
  -- first collect all tags
  local tags = {}
  local lastlast = 1
  local position_offset = 0
  
  local holder = string.rep(" ", icon_space_width)
  
  local ttext = text:gsub("%[[^%[%]]*%]", holder)
  
  for tag in text:gmatch("%[([^%[%]]*)%]") do
    
    local start, last = text:find("["..tag.."]", lastlast, true)
    lastlast = last
    
    local until_tag_text = ttext:sub(1, start + position_offset - 1)
    -- substract the width of the tag in text
    position_offset = position_offset - last + start + icon_space_width - 1
    local prw,prh = sol.text_surface.get_predicted_size(self.font, self.font_size, until_tag_text)
    
    table.insert(tags, {
        surface = sol.surface.create(string.format('hud/text_icons/%s_icon.png', tag)),
        tag = tag,
        x = prw
        })
  end
  
  self.inner_text_surface:set_text(ttext)
  self.icons = tags
end

function text_surface_mt:get_text()
  return self.text
end
function text_surface_mt:get_horizontal_alignment()
  return self.horizontal_alignment
end
function text_surface_mt:get_vertical_alignment()
  return self.vertical_alignment
end
function text_surface_mt:get_font()
  return self.font
end
function text_surface_mt:get_font_size()
  return self.font_size
end
function text_surface_mt:get_color()
  return self.color
end

function text_surface_mt:draw(dst, x,y)
  self.inner_text_surface:draw(dst, x, y)
  self.inner_text_surface_x = x
  self.inner_text_surface_y = y
  for _, icon in ipairs(self.icons) do
    icon.surface:draw(dst, x+icon.x, y)
  end
end

function text_surface_mt:get_xy()
  return self.inner_text_surface_x, self.inner_text_surface_y
end

function tu.create_icon_text_surface(params)
  local inner = sol.text_surface.create(params)
  params.inner_text_surface = inner
  return setmetatable(params, text_surface_mt)
end


return tu
